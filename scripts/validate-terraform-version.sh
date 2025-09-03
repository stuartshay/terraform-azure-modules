#!/bin/bash
# Validate .terraform-version consistency with module requirements
# This script ensures the .terraform-version file matches module version requirements

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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

# Find all versions.tf files and check their required_version
inconsistent_modules=()

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

            echo "  ✓ $module_name: $required_version"
        else
            echo -e "  ${YELLOW}⚠️  $module_name: no required_version found${NC}"
        fi
    fi
done

# Report results
if [[ ${#inconsistent_modules[@]} -eq 0 ]]; then
    echo -e "${GREEN}✅ All module version requirements are satisfied by .terraform-version${NC}"
    exit 0
else
    echo -e "${RED}❌ Found inconsistent version requirements:${NC}"
    for issue in "${inconsistent_modules[@]}"; do
        echo -e "  ${RED}• $issue${NC}"
    done
    exit 1
fi
