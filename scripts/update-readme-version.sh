#!/bin/bash

# Script to update module version strings in README.md
# Usage: ./update-readme-version.sh <module_name> <new_version>

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to log messages
log() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Function to display usage
usage() {
    echo "Usage: $0 <module_name> <new_version>"
    echo ""
    echo "Updates the version string for a specific module in README.md"
    echo ""
    echo "Parameters:"
    echo "  module_name    The name of the module (e.g., 'app-service-plan-function')"
    echo "  new_version    The new version string (e.g., '1.1.81')"
    echo ""
    echo "Examples:"
    echo "  $0 app-service-plan-function 1.1.81"
    echo "  $0 monitoring 1.2.5"
    exit 1
}

# Check if required parameters are provided
if [ $# -ne 2 ]; then
    error "Missing required parameters"
    usage
fi

MODULE_NAME="$1"
NEW_VERSION="$2"
README_FILE="README.md"

# Validate inputs
if [ -z "$MODULE_NAME" ] || [ -z "$NEW_VERSION" ]; then
    error "Module name and version cannot be empty"
    exit 1
fi

# Check if README.md exists
if [ ! -f "$README_FILE" ]; then
    error "README.md file not found in current directory"
    exit 1
fi

log "Updating version for module '$MODULE_NAME' to '$NEW_VERSION' in $README_FILE"

# Create a backup of README.md
cp "$README_FILE" "${README_FILE}.backup"
log "Created backup: ${README_FILE}.backup"

# Function to update version for a specific module
update_module_version() {
    local module="$1"
    local version="$2"
    local file="$3"
    local updated=false
    
    # Use precise patterns to target specific modules
    case "$module" in
        "app-service-plan-function")
            # Match the app-service-plan-function module specifically
            if sed -i.tmp '/azure-policy-cloud\/app-service-plan-function/,/^}/ s/version = "[^"]*"/version = "'"$version"'"/' "$file" 2>/dev/null; then
                if ! cmp -s "$file" "$file.tmp"; then
                    updated=true
                fi
                rm -f "$file.tmp"
            fi
            ;;
        "app-service-plan-web")
            # Match the app-service-plan-web module (uses "app_service" as module name in README)
            # Only update sections with azure-policy-cloud and app-service-plan-web specifically
            if sed -i.tmp '/azure-policy-cloud\/app-service-plan-web/,/^}/ s/version = "[^"]*"/version = "'"$version"'"/' "$file" 2>/dev/null; then
                if ! cmp -s "$file" "$file.tmp"; then
                    updated=true
                fi
                rm -f "$file.tmp"
            fi
            ;;
        "function-app")
            # Match the function-app module
            if sed -i.tmp '/azure-policy-cloud\/function-app/,/^}/ s/version = "[^"]*"/version = "'"$version"'"/' "$file" 2>/dev/null; then
                if ! cmp -s "$file" "$file.tmp"; then
                    updated=true
                fi
                rm -f "$file.tmp"
            fi
            ;;
        "container-instances")
            # Match the container-instances module
            if sed -i.tmp '/azure-policy-cloud\/container-instances/,/^}/ s/version = "[^"]*"/version = "'"$version"'"/' "$file" 2>/dev/null; then
                if ! cmp -s "$file" "$file.tmp"; then
                    updated=true
                fi
                rm -f "$file.tmp"
            fi
            ;;
        "networking")
            # Match the networking module
            if sed -i.tmp '/azure-policy-cloud\/networking/,/^}/ s/version = "[^"]*"/version = "'"$version"'"/' "$file" 2>/dev/null; then
                if ! cmp -s "$file" "$file.tmp"; then
                    updated=true
                fi
                rm -f "$file.tmp"
            fi
            ;;
        "private-endpoint")
            # Match the private-endpoint module
            if sed -i.tmp '/azure-policy-cloud\/private-endpoint/,/^}/ s/version = "[^"]*"/version = "'"$version"'"/' "$file" 2>/dev/null; then
                if ! cmp -s "$file" "$file.tmp"; then
                    updated=true
                fi
                rm -f "$file.tmp"
            fi
            ;;
        "storage-account")
            # Match the storage-account module
            if sed -i.tmp '/azure-policy-cloud\/storage-account/,/^}/ s/version = "[^"]*"/version = "'"$version"'"/' "$file" 2>/dev/null; then
                if ! cmp -s "$file" "$file.tmp"; then
                    updated=true
                fi
                rm -f "$file.tmp"
            fi
            ;;
        "service-bus")
            # Match the service-bus module
            if sed -i.tmp '/azure-policy-cloud\/service-bus/,/^}/ s/version = "[^"]*"/version = "'"$version"'"/' "$file" 2>/dev/null; then
                if ! cmp -s "$file" "$file.tmp"; then
                    updated=true
                fi
                rm -f "$file.tmp"
            fi
            ;;
        "monitoring")
            # Match the monitoring module
            if sed -i.tmp '/azure-policy-cloud\/monitoring/,/^}/ s/version = "[^"]*"/version = "'"$version"'"/' "$file" 2>/dev/null; then
                if ! cmp -s "$file" "$file.tmp"; then
                    updated=true
                fi
                rm -f "$file.tmp"
            fi
            ;;
        "application-insights")
            # Match the application-insights module
            if sed -i.tmp '/azure-policy-cloud\/application-insights[^-]/,/^}/ s/version = "[^"]*"/version = "'"$version"'"/' "$file" 2>/dev/null; then
                if ! cmp -s "$file" "$file.tmp"; then
                    updated=true
                fi
                rm -f "$file.tmp"
            fi
            ;;
        "application-insights-billing")
            # Match the application-insights-billing module
            if sed -i.tmp '/azure-policy-cloud\/application-insights-billing/,/^}/ s/version = "[^"]*"/version = "'"$version"'"/' "$file" 2>/dev/null; then
                if ! cmp -s "$file" "$file.tmp"; then
                    updated=true
                fi
                rm -f "$file.tmp"
            fi
            ;;
        "application-insights-function")
            # Match the application-insights-function module
            if sed -i.tmp '/azure-policy-cloud\/application-insights-function/,/^}/ s/version = "[^"]*"/version = "'"$version"'"/' "$file" 2>/dev/null; then
                if ! cmp -s "$file" "$file.tmp"; then
                    updated=true
                fi
                rm -f "$file.tmp"
            fi
            ;;
        "application-insights-network")
            # Match the application-insights-network module
            if sed -i.tmp '/azure-policy-cloud\/application-insights-network/,/^}/ s/version = "[^"]*"/version = "'"$version"'"/' "$file" 2>/dev/null; then
                if ! cmp -s "$file" "$file.tmp"; then
                    updated=true
                fi
                rm -f "$file.tmp"
            fi
            ;;
        *)
            warn "Unknown module '$module'. Attempting generic update..."
            # Generic fallback - try to match any module with the same name
            if sed -i.tmp '/azure-policy-cloud\/'"$module"'/,/^}/ s/version = "[^"]*"/version = "'"$version"'"/' "$file" 2>/dev/null; then
                if ! cmp -s "$file" "$file.tmp"; then
                    updated=true
                fi
                rm -f "$file.tmp"
            fi
            ;;
    esac
    
    echo "$updated"
}

# Perform the update
log "Searching for module '$MODULE_NAME' in $README_FILE..."

# Update the version
result=$(update_module_version "$MODULE_NAME" "$NEW_VERSION" "$README_FILE")

if [ "$result" = "true" ]; then
    success "Successfully updated version for module '$MODULE_NAME' to '$NEW_VERSION'"
    
    # Show the diff
    log "Changes made:"
    if command -v git >/dev/null 2>&1; then
        git --no-pager diff --no-index "${README_FILE}.backup" "$README_FILE" || true
    else
        diff -u "${README_FILE}.backup" "$README_FILE" || true
    fi
else
    warn "No changes were made. The module '$MODULE_NAME' may not exist in $README_FILE or the version was already '$NEW_VERSION'"
    
    # Restore from backup if no changes were made
    mv "${README_FILE}.backup" "$README_FILE"
    exit 1
fi

# Clean up backup
rm -f "${README_FILE}.backup"

success "README.md version update completed successfully!"