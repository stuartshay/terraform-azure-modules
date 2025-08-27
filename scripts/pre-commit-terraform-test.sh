#!/bin/bash
# Pre-commit hook script for running Terraform tests on changed modules
# This script identifies which modules have changed files and runs tests only for those modules

set -e

# Get the list of changed files
changed_files=("$@")

# Extract unique module directories from changed files
modules_to_test=()

for file in "${changed_files[@]}"; do
    # Check if file is in a module directory
    if [[ $file == modules/*/main.tf || $file == modules/*/variables.tf || $file == modules/*/outputs.tf || $file == modules/*/*.tf || $file == modules/*/tests/*.tftest.hcl ]]; then
        # Extract module name
        module_path=$(echo "$file" | grep -o 'modules/[^/]*' | head -1)
        module_name=$(basename "$module_path")

        # Check if module has tests directory with .tftest.hcl files
        if [[ -d "modules/$module_name/tests" ]] && find "modules/$module_name/tests" -name "*.tftest.hcl" -type f | grep -q .; then
            # Add to array if not already present
            if [[ -z "${modules_seen[$module_name]}" ]]; then
                modules_to_test+=("$module_name")
                modules_seen[$module_name]=1
            fi
        else
            echo "ℹ️  Module $module_name has no tests, skipping."
        fi
    fi
done

# If no modules changed, exit successfully
if [ ${#modules_to_test[@]} -eq 0 ]; then
    echo "No Terraform modules with tests changed, skipping tests."
    exit 0
fi

# Run tests for each changed module
echo "Running Terraform tests for changed modules: ${modules_to_test[*]}"

for module in "${modules_to_test[@]}"; do
    echo "Testing module: $module"
    if ! make terraform-test-module MODULE="$module"; then
        echo "❌ Tests failed for module: $module"
        exit 1
    fi
    echo "✅ Tests passed for module: $module"
done

echo "🎉 All Terraform tests passed for changed modules!"
