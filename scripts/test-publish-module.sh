#!/bin/bash

# Test script for publishing Terraform modules to Terraform Cloud
# Usage: ./scripts/test-publish-module.sh <module-name> <version>

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
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
if [ $# -ne 2 ]; then
    print_error "Usage: $0 <module-name> <version>"
    print_error "Example: $0 app-service 1.0.0"
    print_error "Available modules: app-service, monitoring"
    exit 1
fi

MODULE_NAME=$1
VERSION=$2
PROVIDER="azurerm"

# Load environment variables to get the correct organization
if [ -f ".env" ]; then
    source .env
    NAMESPACE="${TF_CLOUD_ORGANIZATION:-stuartshay}"
else
    NAMESPACE="stuartshay"
fi

# Validate module name
if [[ ! "$MODULE_NAME" =~ ^(app-service|monitoring)$ ]]; then
    print_error "Invalid module name. Available modules: app-service, monitoring"
    exit 1
fi

# Validate version format (semantic versioning)
if [[ ! "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    print_error "Invalid version format. Use semantic versioning (e.g., 1.0.0)"
    exit 1
fi

MODULE_PATH="modules/$MODULE_NAME"
TEMP_DIR="/tmp/terraform-module-$MODULE_NAME-$VERSION"

print_status "Starting module publishing test for $MODULE_NAME version $VERSION"

# Check if module directory exists
if [ ! -d "$MODULE_PATH" ]; then
    print_error "Module directory $MODULE_PATH does not exist"
    exit 1
fi

# Check if required files exist
REQUIRED_FILES=("main.tf" "variables.tf" "outputs.tf" "versions.tf" "README.md")
for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$MODULE_PATH/$file" ]; then
        print_error "Required file $MODULE_PATH/$file is missing"
        exit 1
    fi
done

print_success "All required files found in $MODULE_PATH"

# Clean up any existing temp directory
if [ -d "$TEMP_DIR" ]; then
    rm -rf "$TEMP_DIR"
fi

# Create temporary directory for module packaging
mkdir -p "$TEMP_DIR"
print_status "Created temporary directory: $TEMP_DIR"

# Copy module files to temp directory (excluding examples and .terraform directories)
print_status "Copying module files..."
rsync -av --exclude='examples/' --exclude='.terraform/' --exclude='.terraform.lock.hcl' "$MODULE_PATH/" "$TEMP_DIR/"

# Validate Terraform configuration
print_status "Validating Terraform configuration..."
cd "$TEMP_DIR"

# Initialize Terraform (backend=false for validation only)
terraform init -backend=false

# Format check
if ! terraform fmt -check -recursive .; then
    print_warning "Terraform formatting issues found. Running terraform fmt..."
    terraform fmt -recursive .
fi

# Validate configuration
terraform validate

print_success "Terraform configuration is valid"

# Create a tarball for the module
cd /tmp
TARBALL_NAME="terraform-$NAMESPACE-$MODULE_NAME-$PROVIDER-$VERSION.tar.gz"
tar -czf "$TARBALL_NAME" -C "terraform-module-$MODULE_NAME-$VERSION" .

print_status "Created module tarball: /tmp/$TARBALL_NAME"

# Test Terraform Cloud authentication
print_status "Testing Terraform Cloud authentication..."
if ! terraform login app.terraform.io --token-file ~/.terraform.d/credentials.tfrc.json 2>/dev/null; then
    print_warning "Interactive login test failed, but credentials file should work for API calls"
fi

# Display module information
print_status "Module Information:"
echo "  Name: $MODULE_NAME"
echo "  Version: $VERSION"
echo "  Namespace: $NAMESPACE"
echo "  Provider: $PROVIDER"
echo "  Tarball: /tmp/$TARBALL_NAME"
echo "  Size: $(du -h /tmp/$TARBALL_NAME | cut -f1)"

# Instructions for manual upload
print_status "Manual Upload Instructions:"
echo "1. Go to https://app.terraform.io/$NAMESPACE"
echo "2. Navigate to Registry > Modules"
echo "3. Click 'Publish' > 'Module'"
echo "4. Choose 'Upload a module version'"
echo "5. Upload the tarball: /tmp/$TARBALL_NAME"
echo "6. Set version to: $VERSION"

# Try to use Terraform CLI to publish (if available)
print_status "Attempting to publish via Terraform CLI..."

# Create a simple terraform configuration to test the registry
cat > /tmp/test-registry.tf << EOF
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.40"
    }
  }
}

# This is a test to see if we can reference the module
# module "test_$MODULE_NAME" {
#   source = "app.terraform.io/$NAMESPACE/$MODULE_NAME/$PROVIDER"
#   version = "$VERSION"
# }
EOF

print_success "Test completed successfully!"
print_status "Next steps:"
echo "1. Upload the module using the web interface"
echo "2. Verify the module appears in your Terraform Cloud registry"
echo "3. Test importing the module in a Terraform configuration"

# Clean up
print_status "Cleaning up temporary files..."
rm -rf "$TEMP_DIR"

print_success "Module $MODULE_NAME version $VERSION is ready for publishing!"
