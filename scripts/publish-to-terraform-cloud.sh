#!/bin/bash

# Script to publish Terraform modules to Terraform Cloud using the API
# Usage: ./scripts/publish-to-terraform-cloud.sh <module-name> <version>

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

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    print_error "jq is required but not installed. Please install jq first."
    exit 1
fi

# Check if curl is installed
if ! command -v curl &> /dev/null; then
    print_error "curl is required but not installed. Please install curl first."
    exit 1
fi

# Check arguments
if [ $# -ne 2 ]; then
    print_error "Usage: $0 <module-name> <version>"
    print_error "Example: $0 app-service-plan-web 1.0.0"
    print_error "Available modules: app-service-plan-web, monitoring"
    exit 1
fi

MODULE_NAME=$1
VERSION=$2
PROVIDER="azurerm"

# Load environment variables
if [ -f ".env" ]; then
    source .env
else
    print_error ".env file not found. Please create it with TF_API_TOKEN."
    exit 1
fi

# Use organization from .env file, fallback to stuartshay
NAMESPACE="${TF_CLOUD_ORGANIZATION:-stuartshay}"

# Check if TF_API_TOKEN is set
if [ -z "$TF_API_TOKEN" ]; then
    print_error "TF_API_TOKEN is not set in .env file"
    exit 1
fi

# Validate module name
if [[ ! "$MODULE_NAME" =~ ^(app-service-plan-web|monitoring)$ ]]; then
    print_error "Invalid module name. Available modules: app-service-plan-web, monitoring"
    exit 1
fi

# Validate version format (semantic versioning)
if [[ ! "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    print_error "Invalid version format. Use semantic versioning (e.g., 1.0.0)"
    exit 1
fi

TARBALL_PATH="/tmp/terraform-$NAMESPACE-$MODULE_NAME-$PROVIDER-$VERSION.tar.gz"

# Check if tarball exists
if [ ! -f "$TARBALL_PATH" ]; then
    print_error "Tarball not found: $TARBALL_PATH"
    print_error "Please run the test script first: ./scripts/test-publish-module.sh $MODULE_NAME $VERSION"
    exit 1
fi

print_status "Publishing module $MODULE_NAME version $VERSION to Terraform Cloud"

# Terraform Cloud API endpoints
TFC_API_URL="https://app.terraform.io/api/v2"
ORG_NAME="$NAMESPACE"

# Step 1: Check if organization exists
print_status "Checking organization: $ORG_NAME"
ORG_RESPONSE=$(curl -s \
  --header "Authorization: Bearer $TF_API_TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  "$TFC_API_URL/organizations/$ORG_NAME")

if echo "$ORG_RESPONSE" | jq -e '.errors' > /dev/null; then
    print_error "Organization $ORG_NAME not found or access denied"
    echo "Response: $ORG_RESPONSE"
    exit 1
fi

print_success "Organization $ORG_NAME found"

# Step 2: Check if module exists, if not create it
MODULE_FULL_NAME="$ORG_NAME/$MODULE_NAME/$PROVIDER"
print_status "Checking if module exists: $MODULE_FULL_NAME"

MODULE_RESPONSE=$(curl -s \
  --header "Authorization: Bearer $TF_API_TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  "$TFC_API_URL/organizations/$ORG_NAME/registry-modules/private/$ORG_NAME/$MODULE_NAME/$PROVIDER")

if echo "$MODULE_RESPONSE" | jq -e '.errors' > /dev/null; then
    print_status "Module doesn't exist, creating new module: $MODULE_FULL_NAME"

    # Create module
    CREATE_MODULE_PAYLOAD=$(cat <<EOF
{
  "data": {
    "type": "registry-modules",
    "attributes": {
      "name": "$MODULE_NAME",
      "provider": "$PROVIDER",
      "registry-name": "private"
    }
  }
}
EOF
)

    CREATE_RESPONSE=$(curl -s \
      --header "Authorization: Bearer $TF_API_TOKEN" \
      --header "Content-Type: application/vnd.api+json" \
      --request POST \
      --data "$CREATE_MODULE_PAYLOAD" \
      "$TFC_API_URL/organizations/$ORG_NAME/registry-modules")

    if echo "$CREATE_RESPONSE" | jq -e '.errors' > /dev/null; then
        print_error "Failed to create module"
        echo "Response: $CREATE_RESPONSE"
        exit 1
    fi

    print_success "Module created successfully"
else
    print_success "Module already exists: $MODULE_FULL_NAME"
fi

# Step 3: Create a new version
print_status "Creating module version $VERSION"

CREATE_VERSION_PAYLOAD=$(cat <<EOF
{
  "data": {
    "type": "registry-module-versions",
    "attributes": {
      "version": "$VERSION"
    }
  }
}
EOF
)

VERSION_RESPONSE=$(curl -s \
  --header "Authorization: Bearer $TF_API_TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  --request POST \
  --data "$CREATE_VERSION_PAYLOAD" \
  "$TFC_API_URL/organizations/$ORG_NAME/registry-modules/private/$ORG_NAME/$MODULE_NAME/$PROVIDER/versions")

if echo "$VERSION_RESPONSE" | jq -e '.errors' > /dev/null; then
    print_error "Failed to create module version"
    echo "Response: $VERSION_RESPONSE"
    exit 1
fi

# Extract upload URL
UPLOAD_URL=$(echo "$VERSION_RESPONSE" | jq -r '.data.links.upload')

if [ "$UPLOAD_URL" = "null" ] || [ -z "$UPLOAD_URL" ]; then
    print_error "Failed to get upload URL from response"
    echo "Response: $VERSION_RESPONSE"
    exit 1
fi

print_success "Module version created, upload URL obtained"

# Step 4: Upload the tarball
print_status "Uploading module tarball..."
print_status "Tarball size: $(du -h $TARBALL_PATH | cut -f1)"

curl -s \
  --request PUT \
  --upload-file "$TARBALL_PATH" \
  "$UPLOAD_URL"

# Check if upload was successful (empty response is success for PUT)
if [ $? -eq 0 ]; then
    print_success "Module tarball uploaded successfully"
else
    print_error "Failed to upload module tarball"
    exit 1
fi

# Step 5: Verify the module version was created
print_status "Verifying module version..."
sleep 5  # Give Terraform Cloud time to process

VERIFY_RESPONSE=$(curl -s \
  --header "Authorization: Bearer $TF_API_TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  "$TFC_API_URL/organizations/$ORG_NAME/registry-modules/private/$ORG_NAME/$MODULE_NAME/$PROVIDER/versions/$VERSION")

if echo "$VERIFY_RESPONSE" | jq -e '.errors' > /dev/null; then
    print_warning "Could not verify module version immediately (this is normal)"
else
    STATUS=$(echo "$VERIFY_RESPONSE" | jq -r '.data.attributes.status')
    print_success "Module version status: $STATUS"
fi

# Success message
print_success "Module published successfully!"
print_status "Module Details:"
echo "  Name: $MODULE_FULL_NAME"
echo "  Version: $VERSION"
echo "  Registry URL: https://app.terraform.io/$ORG_NAME/modules/$MODULE_NAME/$PROVIDER/$VERSION"

print_status "You can now use this module in your Terraform configurations:"
cat << EOF

module "$MODULE_NAME" {
  source  = "app.terraform.io/$ORG_NAME/$MODULE_NAME/$PROVIDER"
  version = "$VERSION"

  # Add your module configuration here
}

EOF

print_status "To view the module in Terraform Cloud:"
echo "https://app.terraform.io/$ORG_NAME/registry/modules/private/$ORG_NAME/$MODULE_NAME/$PROVIDER"
