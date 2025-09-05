#!/bin/bash
# Validate .terraform-version consistency with module requirements and GitHub Actions workflows
# This script ensures the .terraform-version file matches module version requirements
# and is consistent with GitHub Actions workflow configurations

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if .terraform-version exists
if [[ ! -f .terraform-version ]]; then
    echo -e "${RED}❌ .terraform-version file not found${NC}"
    exit 1
fi

# Read the version from .terraform-version
TF_VERSION=$(cat .terraform-version | tr -d '\n\r ')

echo -e "${YELLOW}🔍 Validating .terraform-version consistency${NC}"
echo -e "Project Terraform version: ${GREEN}${TF_VERSION}${NC}"

# Validate consistency with GitHub Actions workflows
workflow_inconsistencies=()
for workflow_file in .github/workflows/*.yml; do
    if [[ -f "$workflow_file" ]]; then
        workflow_name=$(basename "$workflow_file" .yml)

        # Extract TF_VERSION from workflow files
        workflow_tf_version=$(grep -o "TF_VERSION: '[^']*'" "$workflow_file" 2>/dev/null | cut -d"'" -f2 || true)

        if [[ -n "$workflow_tf_version" ]]; then
            if [[ "$workflow_tf_version" != "$TF_VERSION" ]]; then
                workflow_inconsistencies+=("$workflow_name: TF_VERSION is '$workflow_tf_version', but .terraform-version is '$TF_VERSION'")
            else
                echo -e "  ${BLUE}✓ GitHub Actions ($workflow_name): $workflow_tf_version${NC}"
            fi
        fi

        # Also check terraform_version in setup-terraform actions
        setup_tf_version=$(grep -A 2 "uses: hashicorp/setup-terraform" "$workflow_file" | grep -o "terraform_version: [^$]*" | cut -d' ' -f2 | tr -d '${}' | head -1 || true)
        if [[ -n "$setup_tf_version" && "$setup_tf_version" != "env.TF_VERSION" && "$setup_tf_version" != "\${{ env.TF_VERSION }}" ]]; then
            # Direct version specified instead of using env var
            setup_tf_version_clean=$(echo "$setup_tf_version" | tr -d "'\"")
            if [[ "$setup_tf_version_clean" != "$TF_VERSION" ]]; then
                workflow_inconsistencies+=("$workflow_name: setup-terraform uses '$setup_tf_version_clean', but .terraform-version is '$TF_VERSION'")
            fi
        fi
    fi
done

# Find all versions.tf files and check their required_version and provider versions
inconsistent_modules=()
inconsistent_examples=()
REQUIRED_TERRAFORM_VERSION=">= 1.13.1"
REQUIRED_AZURERM_VERSION=">= 4.42.0"

for versions_file in modules/*/versions.tf; do
    if [[ -f "$versions_file" ]]; then
        module_dir=$(dirname "$versions_file")
        module_name=$(basename "$module_dir")

        # Extract required_version from the file
        required_version=$(grep -o 'required_version = "[^"]*"' "$versions_file" | cut -d'"' -f2)

        if [[ -n "$required_version" ]]; then
            # Check if the .terraform-version satisfies the requirement
            # For simplicity, we check if the versions match for >= constraints
            if [[ "$required_version" =~ ^">= "(.+)$ ]]; then
                min_version="${BASH_REMATCH[1]}"

                # Simple version comparison (works for semantic versioning)
                if [[ "$TF_VERSION" < "$min_version" ]]; then
                    inconsistent_modules+=("$module_name: requires >= $min_version, but .terraform-version is $TF_VERSION")
                fi
            fi

            echo -e "  ${GREEN}✓ $module_name: Terraform $required_version${NC}"
        else
            echo -e "  ${YELLOW}⚠️  $module_name: no required_version found${NC}"
        fi

        # Check azurerm provider version
        azurerm_version=$(grep -A 10 'azurerm = {' "$versions_file" | grep -o 'version = "[^"]*"' | head -1 | cut -d'"' -f2)

        if [[ -n "$azurerm_version" ]]; then
            if [[ "$azurerm_version" == "$REQUIRED_AZURERM_VERSION" ]]; then
                echo -e "  ${GREEN}✓ $module_name: azurerm $azurerm_version${NC}"
            else
                inconsistent_modules+=("$module_name: azurerm version '$azurerm_version', expected '$REQUIRED_AZURERM_VERSION'")
            fi
        else
            # Check if azurerm provider exists at all
            if grep -q "azurerm = {" "$versions_file"; then
                inconsistent_modules+=("$module_name: azurerm provider missing version")
            else
                inconsistent_modules+=("$module_name: missing azurerm provider")
            fi
        fi
    fi
done

# Find all example main.tf files and check their required_version and provider versions
echo -e "${YELLOW}🔍 Validating example files${NC}"

for example_file in modules/*/examples/*/main.tf; do
    if [[ -f "$example_file" ]]; then
        # Extract module and example names from path
        # Path format: modules/MODULE_NAME/examples/EXAMPLE_NAME/main.tf
        module_name=$(echo "$example_file" | cut -d'/' -f2)
        example_name=$(echo "$example_file" | cut -d'/' -f4)
        example_path="$module_name/examples/$example_name"

        # Extract required_version from the file
        required_version=$(grep -o 'required_version = "[^"]*"' "$example_file" | cut -d'"' -f2)

        if [[ -n "$required_version" ]]; then
            if [[ "$required_version" == "$REQUIRED_TERRAFORM_VERSION" ]]; then
                echo -e "  ${GREEN}✓ $example_path: Terraform $required_version${NC}"
            else
                inconsistent_examples+=("$example_path: terraform version '$required_version', expected '$REQUIRED_TERRAFORM_VERSION'")
            fi
        else
            # Check if terraform block exists at all
            if grep -q "terraform {" "$example_file"; then
                inconsistent_examples+=("$example_path: terraform block missing required_version")
            else
                echo -e "  ${YELLOW}⚠️  $example_path: no terraform block found${NC}"
            fi
        fi

        # Check azurerm provider version
        azurerm_version=$(grep -A 10 'azurerm = {' "$example_file" | grep -o 'version = "[^"]*"' | head -1 | cut -d'"' -f2)

        if [[ -n "$azurerm_version" ]]; then
            if [[ "$azurerm_version" == "$REQUIRED_AZURERM_VERSION" ]]; then
                echo -e "  ${GREEN}✓ $example_path: azurerm $azurerm_version${NC}"
            else
                inconsistent_examples+=("$example_path: azurerm version '$azurerm_version', expected '$REQUIRED_AZURERM_VERSION'")
            fi
        else
            # Check if azurerm provider exists at all
            if grep -q "azurerm = {" "$example_file"; then
                inconsistent_examples+=("$example_path: azurerm provider missing version")
            else
                inconsistent_examples+=("$example_path: missing azurerm provider")
            fi
        fi
    fi
done

# Report results
if [[ ${#inconsistent_modules[@]} -eq 0 && ${#inconsistent_examples[@]} -eq 0 && ${#workflow_inconsistencies[@]} -eq 0 ]]; then
    echo -e "${GREEN}✅ All version requirements are consistent with .terraform-version${NC}"
    exit 0
else
    has_errors=false

    if [[ ${#inconsistent_modules[@]} -gt 0 ]]; then
        echo -e "${RED}❌ Found inconsistent module version requirements:${NC}"
        for issue in "${inconsistent_modules[@]}"; do
            echo -e "  ${RED}• $issue${NC}"
        done
        has_errors=true
    fi

    if [[ ${#inconsistent_examples[@]} -gt 0 ]]; then
        echo -e "${RED}❌ Found inconsistent example version requirements:${NC}"
        for issue in "${inconsistent_examples[@]}"; do
            echo -e "  ${RED}• $issue${NC}"
        done
        has_errors=true
    fi

    if [[ ${#workflow_inconsistencies[@]} -gt 0 ]]; then
        echo -e "${RED}❌ Found inconsistent GitHub Actions workflow versions:${NC}"
        for issue in "${workflow_inconsistencies[@]}"; do
            echo -e "  ${RED}• $issue${NC}"
        done
        has_errors=true
    fi

    if [[ "$has_errors" == "true" ]]; then
        echo -e "${YELLOW}💡 To fix: Update version requirements in modules, examples, and/or workflow files to match project standards${NC}"
        exit 1
    fi
fi
