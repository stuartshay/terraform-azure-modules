#!/bin/bash

# Auto-versioning script for Terraform modules
# Usage: ./scripts/auto-version.sh <module-name> [version-type]
# version-type: major, minor, patch (default: patch)

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check arguments
if [ $# -lt 1 ] || [ $# -gt 2 ]; then
    print_error "Usage: $0 <module-name> [version-type]"
    print_error "module-name: app-service, monitoring"
    print_error "version-type: major, minor, patch (default: patch)"
    print_error "Examples:"
    print_error "  $0 app-service patch    # 1.0.0 -> 1.0.1"
    print_error "  $0 monitoring minor     # 1.0.0 -> 1.1.0"
    print_error "  $0 app-service major    # 1.0.0 -> 2.0.0"
    exit 1
fi

MODULE_NAME=$1
VERSION_TYPE=${2:-patch}

# Validate module name
if [[ ! "$MODULE_NAME" =~ ^(app-service|monitoring)$ ]]; then
    print_error "Invalid module name. Available modules: app-service, monitoring"
    exit 1
fi

# Validate version type
if [[ ! "$VERSION_TYPE" =~ ^(major|minor|patch)$ ]]; then
    print_error "Invalid version type. Use: major, minor, patch"
    exit 1
fi

# Load environment variables
if [ -f ".env" ]; then
    # shellcheck source=.env disable=SC1091
    source .env
    ORGANIZATION="${TF_CLOUD_ORGANIZATION:-stuartshay}"
else
    ORGANIZATION="stuartshay"
fi

print_status "Auto-versioning for module: $MODULE_NAME"
print_status "Version bump type: $VERSION_TYPE"
print_status "Organization: $ORGANIZATION"

# Function to get latest version from Terraform Cloud
get_latest_version() {
    local module_name=$1
    local org=$2

    if [ -z "$TF_API_TOKEN" ]; then
        print_warning "TF_API_TOKEN not found, checking Git tags instead" >&2
        # Fallback to Git tags
        LATEST_TAG=$(git tag -l "v*" --sort=-version:refname | head -n1 | sed 's/^v//')
        if [ -z "$LATEST_TAG" ]; then
            echo "0.0.0"
        else
            echo "$LATEST_TAG"
        fi
        return
    fi

    # Query Terraform Cloud API for latest version
    TFC_API_URL="https://app.terraform.io/api/v2"
    PROVIDER="azurerm"

    print_status "Querying Terraform Cloud for latest version..." >&2

    VERSIONS_RESPONSE=$(curl -s \
        --header "Authorization: Bearer $TF_API_TOKEN" \
        --header "Content-Type: application/vnd.api+json" \
        "$TFC_API_URL/organizations/$org/registry-modules/private/$org/$module_name/$PROVIDER/versions")

    if echo "$VERSIONS_RESPONSE" | jq -e '.errors' > /dev/null; then
        print_warning "Could not fetch versions from Terraform Cloud, using 0.0.0" >&2
        echo "0.0.0"
        return
    fi

    # Extract latest version
    LATEST_VERSION=$(echo "$VERSIONS_RESPONSE" | jq -r '.data[0].attributes.version // "0.0.0"')
    echo "$LATEST_VERSION"
}

# Function to increment version
increment_version() {
    local version=$1
    local type=$2

    # Split version into components
    IFS='.' read -ra VERSION_PARTS <<< "$version"
    MAJOR=${VERSION_PARTS[0]:-0}
    MINOR=${VERSION_PARTS[1]:-0}
    PATCH=${VERSION_PARTS[2]:-0}

    case $type in
        major)
            MAJOR=$((MAJOR + 1))
            MINOR=0
            PATCH=0
            ;;
        minor)
            MINOR=$((MINOR + 1))
            PATCH=0
            ;;
        patch)
            PATCH=$((PATCH + 1))
            ;;
    esac

    echo "$MAJOR.$MINOR.$PATCH"
}

# Get current latest version
CURRENT_VERSION=$(get_latest_version "$MODULE_NAME" "$ORGANIZATION")
print_status "Current latest version: $CURRENT_VERSION"

# Calculate new version
NEW_VERSION=$(increment_version "$CURRENT_VERSION" "$VERSION_TYPE")
print_success "New version will be: $NEW_VERSION"

# Validate new version format
if [[ ! "$NEW_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    print_error "Generated version is invalid: $NEW_VERSION"
    exit 1
fi

# Display summary
echo ""
print_status "Version Summary:"
echo "  Module: $MODULE_NAME"
echo "  Current: $CURRENT_VERSION"
echo "  New: $NEW_VERSION"
echo "  Bump Type: $VERSION_TYPE"
echo "  Organization: $ORGANIZATION"

echo ""
print_status "Next steps:"
echo "1. Review the version change above"
echo "2. Run the deployment:"
echo "   ./scripts/test-publish-module.sh $MODULE_NAME $NEW_VERSION"
echo "   ./scripts/publish-to-terraform-cloud.sh $MODULE_NAME $NEW_VERSION"
echo ""
echo "3. Or use GitHub Actions:"
echo "   - Go to Actions → Deploy to Terraform Cloud"
echo "   - Module: $MODULE_NAME"
echo "   - Version: $NEW_VERSION"

# Option to create Git tag
echo ""
read -p "Create Git tag v$NEW_VERSION? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if git tag "v$NEW_VERSION"; then
        print_success "Git tag v$NEW_VERSION created"
        echo "Push tag with: git push origin v$NEW_VERSION"
    else
        print_warning "Failed to create Git tag (tag may already exist)"
    fi
fi

echo ""
print_success "Auto-versioning completed!"
echo "Suggested version: $NEW_VERSION"
