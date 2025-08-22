#!/bin/bash

# Script to help set up GitHub Secrets for Terraform Cloud deployment
# This script displays the values that need to be added as GitHub Secrets

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

print_status "GitHub Secrets Setup for Terraform Cloud Deployment"
echo "======================================================="

# Check if .env file exists
if [ ! -f ".env" ]; then
    print_error ".env file not found!"
    print_error "Please create a .env file with your Terraform Cloud configuration."
    exit 1
fi

# Load environment variables
source .env

print_status "Reading configuration from .env file..."

# Check required variables
MISSING_VARS=()

if [ -z "$TF_API_TOKEN" ]; then
    MISSING_VARS+=("TF_API_TOKEN")
fi

if [ -z "$TF_CLOUD_ORGANIZATION" ]; then
    MISSING_VARS+=("TF_CLOUD_ORGANIZATION")
fi

if [ ${#MISSING_VARS[@]} -gt 0 ]; then
    print_error "Missing required environment variables in .env file:"
    for var in "${MISSING_VARS[@]}"; do
        echo "  - $var"
    done
    exit 1
fi

print_success "All required variables found in .env file"

echo ""
print_status "GitHub Secrets Configuration"
echo "=============================="

echo ""
print_warning "⚠️  IMPORTANT: Never commit these values to version control!"
echo ""

print_status "Please add the following secrets to your GitHub repository:"
print_status "Go to: Settings → Secrets and variables → Actions → New repository secret"

echo ""
echo "┌─────────────────────────────────────────────────────────────────────────────┐"
echo "│                           GITHUB SECRETS TO ADD                            │"
echo "├─────────────────────────────────────────────────────────────────────────────┤"
echo "│                                                                             │"
echo "│ Secret Name: TF_API_TOKEN                                                   │"
echo "│ Secret Value: $TF_API_TOKEN"
echo "│                                                                             │"
echo "├─────────────────────────────────────────────────────────────────────────────┤"
echo "│                                                                             │"
echo "│ Secret Name: TF_CLOUD_ORGANIZATION                                          │"
echo "│ Secret Value: $TF_CLOUD_ORGANIZATION"
echo "│                                                                             │"
echo "└─────────────────────────────────────────────────────────────────────────────┘"

echo ""
print_status "Additional Information:"
echo "  Repository: $(git remote get-url origin 2>/dev/null || echo 'Not in a git repository')"
echo "  Organization: $TF_CLOUD_ORGANIZATION"
echo "  Terraform Cloud URL: https://app.terraform.io/$TF_CLOUD_ORGANIZATION"

echo ""
print_status "Steps to configure GitHub Secrets:"
echo "1. Go to your GitHub repository"
echo "2. Click on 'Settings' tab"
echo "3. In the left sidebar, click 'Secrets and variables' → 'Actions'"
echo "4. Click 'New repository secret'"
echo "5. Add each secret with the name and value shown above"

echo ""
print_status "Verification:"
echo "After adding the secrets, you can verify the setup by:"
echo "1. Go to Actions tab in your GitHub repository"
echo "2. Select 'Deploy to Terraform Cloud' workflow"
echo "3. Click 'Run workflow'"
echo "4. Choose a module and version"
echo "5. Enable 'Dry run' for testing"
echo "6. Click 'Run workflow'"

echo ""
print_success "Setup information displayed successfully!"
print_warning "Remember to keep your API tokens secure and rotate them regularly."
