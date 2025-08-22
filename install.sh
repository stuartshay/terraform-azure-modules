#!/usr/bin/env bash
# Terraform Azure Modules - Development Environment Setup
# This script installs tools needed for Terraform module development, testing, and validation
set -e

OS="$(uname)"

# Function to install jq (JSON processor)
install_jq() {
  if command -v jq >/dev/null 2>&1; then
    echo "jq is already installed: $(jq --version)"
    return 0
  fi

  if [[ "$OS" == "Linux" ]]; then
    if command -v apt >/dev/null 2>&1; then
      echo "Installing jq using apt..."
      sudo apt update
      sudo apt install -y jq
    elif command -v yum >/dev/null 2>&1; then
      echo "Installing jq using yum..."
      sudo yum install -y jq
    fi
  elif [[ "$OS" == "Darwin" ]]; then
    echo "Installing jq using Homebrew..."
    brew install jq
  fi

  # Verify installation
  if command -v jq >/dev/null 2>&1; then
    echo "jq version: $(jq --version)"
  else
    echo "Warning: jq installation may have failed." >&2
  fi
}

# Function to install yq (YAML processor)
install_yq() {
  if command -v yq >/dev/null 2>&1; then
    echo "yq is already installed: $(yq --version)"
    return 0
  fi

  if [[ "$OS" == "Linux" ]]; then
    echo "Installing yq..."
    YQ_VERSION=$(curl -s https://api.github.com/repos/mikefarah/yq/releases/latest | grep tag_name | cut -d '"' -f 4)
    wget -O yq "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64"
    chmod +x yq
    sudo mv yq /usr/local/bin/
  elif [[ "$OS" == "Darwin" ]]; then
    echo "Installing yq using Homebrew..."
    brew install yq
  fi

  # Verify installation
  if command -v yq >/dev/null 2>&1; then
    echo "yq version: $(yq --version)"
  else
    echo "Warning: yq installation may have failed." >&2
  fi
}

# Function to install zip/unzip utilities
install_zip_utils() {
  if command -v zip >/dev/null 2>&1 && command -v unzip >/dev/null 2>&1; then
    echo "zip and unzip utilities are already installed"
    return 0
  fi

  if [[ "$OS" == "Linux" ]]; then
    if command -v apt >/dev/null 2>&1; then
      echo "Installing zip and unzip utilities using apt..."
      sudo apt update
      sudo apt install -y zip unzip
    elif command -v yum >/dev/null 2>&1; then
      echo "Installing zip and unzip utilities using yum..."
      sudo yum install -y zip unzip
    fi
  elif [[ "$OS" == "Darwin" ]]; then
    echo "Installing zip and unzip utilities using Homebrew..."
    brew install zip unzip
  fi

  # Verify installation
  if command -v zip >/dev/null 2>&1 && command -v unzip >/dev/null 2>&1; then
    echo "zip and unzip utilities installed successfully"
  else
    echo "Warning: zip/unzip installation may have failed." >&2
  fi
}

# Function to install tfenv (Terraform Version Manager)
install_tfenv() {
  if command -v tfenv >/dev/null 2>&1; then
    echo "tfenv is already installed: $(tfenv --version)"
    return 0
  fi

  echo "Installing tfenv (Terraform Version Manager)..."

  if [[ "$OS" == "Linux" ]]; then
    # Install tfenv via git clone
    if [ ! -d "$HOME/.tfenv" ]; then
      echo "Cloning tfenv repository..."
      git clone --depth=1 https://github.com/tfutils/tfenv.git ~/.tfenv
    else
      echo "tfenv directory already exists, updating..."
      cd ~/.tfenv && git pull
    fi

    # Add tfenv to PATH in shell profiles
    echo "Adding tfenv to PATH..."

    # For bash
    if [ -f "$HOME/.bashrc" ] && ! grep -q "tfenv" "$HOME/.bashrc"; then
      echo 'export PATH="$HOME/.tfenv/bin:$PATH"' >> "$HOME/.bashrc"
    fi

    # For zsh
    if [ -f "$HOME/.zshrc" ] && ! grep -q "tfenv" "$HOME/.zshrc"; then
      echo 'export PATH="$HOME/.tfenv/bin:$PATH"' >> "$HOME/.zshrc"
    fi

    # Add to current session
    export PATH="$HOME/.tfenv/bin:$PATH"

  elif [[ "$OS" == "Darwin" ]]; then
    echo "Installing tfenv using Homebrew..."
    brew install tfenv
  fi

  # Verify installation
  if command -v tfenv >/dev/null 2>&1; then
    echo "tfenv installed successfully: $(tfenv --version)"

    # Install Terraform version specified in .terraform-version or latest
    if [ -f ".terraform-version" ]; then
      TF_VERSION=$(cat .terraform-version)
      echo "Installing Terraform version $TF_VERSION from .terraform-version file..."
      tfenv install "$TF_VERSION"
      tfenv use "$TF_VERSION"
    else
      echo "Installing latest Terraform version..."
      tfenv install latest
      tfenv use latest
    fi

    echo "Terraform installation via tfenv complete."
  else
    echo "Warning: tfenv installation may have failed. You may need to restart your shell." >&2
    echo "After restarting, run: tfenv install latest && tfenv use latest"
  fi
}

# Function to install Terraform (fallback if tfenv fails)
install_terraform() {
  if command -v terraform >/dev/null 2>&1; then
    echo "Terraform is already installed: $(terraform --version | head -n1)"
    return 0
  fi

  echo "Installing Terraform directly (fallback method)..."

  if [[ "$OS" == "Linux" ]]; then
    if command -v apt >/dev/null 2>&1; then
      echo "Installing Terraform using apt..."

      # Check if HashiCorp repository is already configured
      if [ ! -f /usr/share/keyrings/hashicorp-archive-keyring.gpg ]; then
        echo "Adding HashiCorp GPG key..."
        wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
      fi

      # Check if repository is already added
      if [ ! -f /etc/apt/sources.list.d/hashicorp.list ]; then
        echo "Adding HashiCorp repository..."
        echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list > /dev/null
      fi

      sudo apt update
      sudo apt install -y terraform

    elif command -v yum >/dev/null 2>&1; then
      echo "Installing Terraform using yum..."
      sudo yum install -y yum-utils
      sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
      sudo yum install -y terraform
    fi
  elif [[ "$OS" == "Darwin" ]]; then
    echo "Installing Terraform using Homebrew..."
    brew tap hashicorp/tap
    brew install hashicorp/tap/terraform
  fi

  # Verify installation
  if command -v terraform >/dev/null 2>&1; then
    echo "Terraform version: $(terraform --version | head -n1)"
  else
    echo "Warning: Terraform installation may have failed." >&2
  fi
}

# Function to install Terragrunt
install_terragrunt() {
  if command -v terragrunt >/dev/null 2>&1; then
    echo "Terragrunt is already installed: $(terragrunt --version)"
    return 0
  fi

  if [[ "$OS" == "Linux" ]]; then
    echo "Installing Terragrunt..."
    TERRAGRUNT_VERSION=$(curl -s https://api.github.com/repos/gruntwork-io/terragrunt/releases/latest | grep tag_name | cut -d '"' -f 4)
    wget -O terragrunt "https://github.com/gruntwork-io/terragrunt/releases/download/${TERRAGRUNT_VERSION}/terragrunt_linux_amd64"
    chmod +x terragrunt
    sudo mv terragrunt /usr/local/bin/
  elif [[ "$OS" == "Darwin" ]]; then
    echo "Installing Terragrunt using Homebrew..."
    brew install terragrunt
  fi

  # Verify installation
  if command -v terragrunt >/dev/null 2>&1; then
    echo "Terragrunt version: $(terragrunt --version)"
  else
    echo "Warning: Terragrunt installation may have failed." >&2
  fi
}

# Function to install tflint
install_tflint() {
  if command -v tflint >/dev/null 2>&1; then
    echo "tflint is already installed: $(tflint --version)"
    return 0
  fi

  if [[ "$OS" == "Linux" ]]; then
    echo "Installing tflint..."
    if ! command -v unzip >/dev/null 2>&1; then
      echo "unzip is required for tflint installation but not found."
      return 1
    fi

    TFLINT_VERSION=$(curl -s https://api.github.com/repos/terraform-linters/tflint/releases/latest | grep tag_name | cut -d '"' -f 4)
    wget -O tflint.zip "https://github.com/terraform-linters/tflint/releases/download/${TFLINT_VERSION}/tflint_linux_amd64.zip"
    unzip tflint.zip
    chmod +x tflint
    sudo mv tflint /usr/local/bin/
    rm tflint.zip

  elif [[ "$OS" == "Darwin" ]]; then
    echo "Installing tflint using Homebrew..."
    brew install tflint
  fi

  # Verify installation
  if command -v tflint >/dev/null 2>&1; then
    echo "tflint version: $(tflint --version)"
  else
    echo "Warning: tflint installation may have failed." >&2
  fi
}

# Function to install tfsec
install_tfsec() {
  if command -v tfsec >/dev/null 2>&1; then
    echo "tfsec is already installed: $(tfsec --version)"
    return 0
  fi

  if [[ "$OS" == "Linux" ]]; then
    echo "Installing tfsec..."
    TFSEC_VERSION=$(curl -s https://api.github.com/repos/aquasecurity/tfsec/releases/latest | grep tag_name | cut -d '"' -f 4)
    wget -O tfsec "https://github.com/aquasecurity/tfsec/releases/download/${TFSEC_VERSION}/tfsec-linux-amd64"
    chmod +x tfsec
    sudo mv tfsec /usr/local/bin/

  elif [[ "$OS" == "Darwin" ]]; then
    echo "Installing tfsec using Homebrew..."
    brew install tfsec
  fi

  # Verify installation
  if command -v tfsec >/dev/null 2>&1; then
    echo "tfsec version: $(tfsec --version)"
  else
    echo "Warning: tfsec installation may have failed." >&2
  fi
}

# Function to install terraform-docs
install_terraform_docs() {
  if command -v terraform-docs >/dev/null 2>&1; then
    echo "terraform-docs is already installed: $(terraform-docs --version)"
    return 0
  fi

  if [[ "$OS" == "Linux" ]]; then
    echo "Installing terraform-docs..."
    TERRAFORM_DOCS_VERSION=$(curl -s https://api.github.com/repos/terraform-docs/terraform-docs/releases/latest | grep tag_name | cut -d '"' -f 4)
    wget -O terraform-docs.tar.gz "https://github.com/terraform-docs/terraform-docs/releases/download/${TERRAFORM_DOCS_VERSION}/terraform-docs-${TERRAFORM_DOCS_VERSION}-linux-amd64.tar.gz"
    tar -xzf terraform-docs.tar.gz
    chmod +x terraform-docs
    sudo mv terraform-docs /usr/local/bin/
    rm terraform-docs.tar.gz

  elif [[ "$OS" == "Darwin" ]]; then
    echo "Installing terraform-docs using Homebrew..."
    brew install terraform-docs
  fi

  # Verify installation
  if command -v terraform-docs >/dev/null 2>&1; then
    echo "terraform-docs version: $(terraform-docs --version)"
  else
    echo "Warning: terraform-docs installation may have failed." >&2
  fi
}

# Function to install Checkov
install_checkov() {
  if command -v checkov >/dev/null 2>&1; then
    echo "Checkov is already installed: $(checkov --version)"
    return 0
  fi

  echo "Installing Checkov..."

  # Check if Python 3 is available
  if command -v python3 >/dev/null 2>&1; then
    # Install using pip3
    if command -v pip3 >/dev/null 2>&1; then
      pip3 install --user checkov
    else
      python3 -m pip install --user checkov
    fi
  elif [[ "$OS" == "Darwin" ]] && command -v brew >/dev/null 2>&1; then
    # Fallback to Homebrew on macOS
    brew install checkov
  else
    echo "Warning: Python 3 not found. Please install Python 3 and pip3 first." >&2
    return 1
  fi

  # Add user bin to PATH if not already there
  if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc 2>/dev/null || true
    export PATH="$HOME/.local/bin:$PATH"
  fi

  # Verify installation
  if command -v checkov >/dev/null 2>&1; then
    echo "Checkov version: $(checkov --version)"
  else
    echo "Warning: Checkov installation may have failed. You may need to restart your shell." >&2
  fi
}

# Function to install infracost
install_infracost() {
  if command -v infracost >/dev/null 2>&1; then
    echo "infracost is already installed: $(infracost --version)"
    return 0
  fi

  echo "Installing infracost..."

  if [[ "$OS" == "Linux" ]]; then
    # Download and install infracost
    curl -fsSL https://raw.githubusercontent.com/infracost/infracost/master/scripts/install.sh | sh

    # Move to system path
    sudo mv ./infracost /usr/local/bin/

  elif [[ "$OS" == "Darwin" ]]; then
    echo "Installing infracost using Homebrew..."
    brew install infracost
  fi

  # Verify installation
  if command -v infracost >/dev/null 2>&1; then
    echo "infracost version: $(infracost --version)"
  else
    echo "Warning: infracost installation may have failed." >&2
  fi
}

# Function to install GitHub CLI
install_github_cli() {
  if command -v gh >/dev/null 2>&1; then
    echo "GitHub CLI is already installed: $(gh --version | head -n1)"
    return 0
  fi

  if [[ "$OS" == "Linux" ]]; then
    if command -v apt >/dev/null 2>&1; then
      echo "Installing GitHub CLI using apt..."
      sudo mkdir -p -m 755 /etc/apt/keyrings
      wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null
      sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
      sudo apt update
      sudo apt install -y gh

    elif command -v yum >/dev/null 2>&1; then
      echo "Installing GitHub CLI using yum..."
      sudo dnf install -y 'dnf-command(config-manager)'
      sudo dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
      sudo dnf install -y gh
    fi
  elif [[ "$OS" == "Darwin" ]]; then
    echo "Installing GitHub CLI using Homebrew..."
    brew install gh
  fi

  # Verify installation
  if command -v gh >/dev/null 2>&1; then
    echo "GitHub CLI version: $(gh --version | head -n1)"
  else
    echo "Warning: GitHub CLI installation may have failed." >&2
  fi
}

# Function to install actionlint
install_actionlint() {
  if command -v actionlint >/dev/null 2>&1; then
    echo "actionlint is already installed: $(actionlint --version)"
    return 0
  fi

  echo "Installing actionlint (GitHub Actions linter)..."

  if [[ "$OS" == "Linux" ]]; then
    ACTIONLINT_VERSION=$(curl -s https://api.github.com/repos/rhymond/actionlint/releases/latest | grep tag_name | cut -d '"' -f 4)
    wget -O actionlint "https://github.com/rhymond/actionlint/releases/download/${ACTIONLINT_VERSION}/actionlint_${ACTIONLINT_VERSION#v}_linux_amd64"
    chmod +x actionlint
    sudo mv actionlint /usr/local/bin/
  elif [[ "$OS" == "Darwin" ]]; then
    brew install actionlint
  fi

  # Verify installation
  if command -v actionlint >/dev/null 2>&1; then
    echo "actionlint version: $(actionlint --version)"
  else
    echo "Warning: actionlint installation may have failed." >&2
  fi
}

# Function to install shellcheck
install_shellcheck() {
  if command -v shellcheck >/dev/null 2>&1; then
    echo "shellcheck is already installed: $(shellcheck --version | head -1)"
    return 0
  fi

  echo "Installing shellcheck (shell script linter)..."

  if [[ "$OS" == "Linux" ]]; then
    if command -v apt >/dev/null 2>&1; then
      sudo apt install -y shellcheck
    elif command -v yum >/dev/null 2>&1; then
      sudo yum install -y ShellCheck
    fi
  elif [[ "$OS" == "Darwin" ]]; then
    brew install shellcheck
  fi

  # Verify installation
  if command -v shellcheck >/dev/null 2>&1; then
    echo "shellcheck version: $(shellcheck --version | head -1)"
  else
    echo "Warning: shellcheck installation may have failed." >&2
  fi
}

# Function to install pre-commit
install_precommit() {
  if command -v pre-commit >/dev/null 2>&1; then
    echo "pre-commit is already installed: $(pre-commit --version)"
    return 0
  fi

  echo "Installing pre-commit..."

  # Check if Python 3 is available
  if command -v python3 >/dev/null 2>&1; then
    # Install using pip3
    if command -v pip3 >/dev/null 2>&1; then
      pip3 install --user pre-commit
    else
      python3 -m pip install --user pre-commit
    fi
  elif [[ "$OS" == "Darwin" ]] && command -v brew >/dev/null 2>&1; then
    # Fallback to Homebrew on macOS
    brew install pre-commit
  else
    echo "Warning: Python 3 not found. Please install Python 3 and pip3 first." >&2
    return 1
  fi

  # Add user bin to PATH if not already there
  if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc 2>/dev/null || true
    export PATH="$HOME/.local/bin:$PATH"
  fi

  # Verify installation
  if command -v pre-commit >/dev/null 2>&1; then
    echo "pre-commit version: $(pre-commit --version)"
  else
    echo "Warning: pre-commit installation may have failed. You may need to restart your shell." >&2
  fi
}

# Function to setup pre-commit hooks
setup_precommit_hooks() {
  echo "Setting up pre-commit hooks..."

  # Navigate to project root
  cd "$(dirname "$0")"

  # Use the existing .pre-commit-config.yaml
  if [ -f .pre-commit-config.yaml ]; then
    echo "* Using existing .pre-commit-config.yaml configuration"
  else
    echo "ERROR: .pre-commit-config.yaml not found. Please add your configuration file before running this script."
    return 1
  fi

  # Install the git hooks
  echo "Installing pre-commit hooks..."
  pre-commit install

  echo "* Pre-commit hooks installed successfully!"

  # Run hooks on all files to ensure everything is working
  echo "Running pre-commit on all files to verify setup..."
  pre-commit run --all-files || echo "WARNING: Some hooks failed. This is normal for first run - files may have been auto-fixed."

  echo ""
  echo ">> Pre-commit setup complete!"
  echo ""
  echo "Pre-commit will now automatically run on:"
  echo "  - Every git commit (validates staged files)"
  echo "  - Manual execution: pre-commit run --all-files"
  echo ""
  echo "Key hooks configured:"
  echo "  - Terraform: formatting, validation, documentation, linting"
  echo "  - Security: tfsec, Checkov scanning"
  echo "  - General: trailing whitespace, file endings, JSON/YAML validation"
  echo "  - Shell: shellcheck for script validation"
  echo ""
}

# Function to create .terraform-version file
create_terraform_version_file() {
  echo "Setting up Terraform version management..."

  # Navigate to project root
  cd "$(dirname "$0")"

  # Check if .terraform-version already exists
  if [ -f .terraform-version ]; then
    echo "* .terraform-version file already exists: $(cat .terraform-version)"
  else
    # Use version from GitHub Actions workflow or default to 1.5.0
    if [ -f .github/workflows/terraform.yml ] && grep -q "TF_VERSION:" .github/workflows/terraform.yml; then
      TF_VERSION=$(grep "TF_VERSION:" .github/workflows/terraform.yml | sed 's/.*TF_VERSION: *"\([^"]*\)".*/\1/')
      echo "$TF_VERSION" > .terraform-version
      echo "* Created .terraform-version file with version: $TF_VERSION (from GitHub Actions)"
    else
      echo "1.5.0" > .terraform-version
      echo "* Created .terraform-version file with default version: 1.5.0"
    fi
  fi
}

# Function to setup tflint configuration
setup_tflint_config() {
  echo "Setting up tflint configuration..."

  # Navigate to project root
  cd "$(dirname "$0")"

  # Check if .tflint.hcl already exists
  if [ -f .tflint.hcl ]; then
    echo "* .tflint.hcl file already exists"
  else
    echo "Creating .tflint.hcl configuration..."
    cat > .tflint.hcl << 'EOF'
# TFLint configuration for Terraform Azure Modules

config {
  # Enable all rules by default
  disabled_by_default = false

  # Plugin directory
  plugin_dir = "~/.tflint.d/plugins"
}

# Azure provider plugin
plugin "azurerm" {
  enabled = true
  version = "0.25.1"
  source  = "github.com/terraform-linters/tflint-ruleset-azurerm"
}

# Terraform core rules
rule "terraform_deprecated_interpolation" {
  enabled = true
}

rule "terraform_deprecated_index" {
  enabled = true
}

rule "terraform_unused_declarations" {
  enabled = true
}

rule "terraform_comment_syntax" {
  enabled = true
}

rule "terraform_documented_outputs" {
  enabled = true
}

rule "terraform_documented_variables" {
  enabled = true
}

rule "terraform_typed_variables" {
  enabled = true
}

rule "terraform_module_pinned_source" {
  enabled = true
}

rule "terraform_naming_convention" {
  enabled = true
  format  = "snake_case"
}

rule "terraform_required_version" {
  enabled = true
}

rule "terraform_required_providers" {
  enabled = true
}

rule "terraform_standard_module_structure" {
  enabled = true
}
EOF
    echo "* Created .tflint.hcl configuration"
  fi

  # Initialize tflint plugins
  if command -v tflint >/dev/null 2>&1; then
    echo "Initializing tflint plugins..."
    tflint --init || echo "Warning: tflint plugin initialization failed"
  fi
}

# Function to setup checkov configuration
setup_checkov_config() {
  echo "Setting up Checkov configuration..."

  # Navigate to project root
  cd "$(dirname "$0")"

  # Check if .checkov.yaml already exists
  if [ -f .checkov.yaml ]; then
    echo "* .checkov.yaml file already exists"
  else
    echo "Creating .checkov.yaml configuration..."
    cat > .checkov.yaml << 'EOF'
# Checkov configuration for Terraform Azure Modules

# Directories to scan
directory:
  - modules

# File types to scan
framework:
  - terraform

# Skip specific checks (add check IDs to skip)
skip-check:
  # Skip checks that may not be relevant for modules
  - CKV_AZURE_1   # Ensure that 'Secure transfer required' is set to 'Enabled'
  - CKV2_AZURE_1  # Ensure storage for critical data are encrypted with Customer Managed Key
  - CKV2_AZURE_8  # Ensure the storage account containing the container with activity logs is encrypted with BYOK (Use Your Own Key)

# Output format
output: cli

# Quiet mode (reduce verbosity)
quiet: false

# Compact output
compact: true

# Download external modules
download-external-modules: false

# External checks directory
external-checks-dir: []

# Baseline file for suppressing known issues
# baseline: .checkov.baseline

# Soft fail mode (don't exit with error code)
soft-fail: false

# Hard fail on specific severity levels
hard-fail-on:
  - HIGH
  - CRITICAL

# Skip downloading of external modules
skip-download: true
EOF
    echo "* Created .checkov.yaml configuration"
  fi
}

# Main installation sequence
echo "=== Terraform Azure Modules - Development Environment Setup ==="
echo "This script will install tools needed for Terraform module development, testing, and validation"
echo ""

echo "=== Installing Core Utilities ==="
install_jq
echo ""

install_yq
echo ""

install_zip_utils
echo ""

echo "=== Installing Terraform Tools ==="
install_tfenv
echo ""

# Only install Terraform directly if tfenv failed
if ! command -v terraform >/dev/null 2>&1; then
  install_terraform
  echo ""
fi

install_terragrunt
echo ""

install_tflint
echo ""

install_tfsec
echo ""

install_terraform_docs
echo ""

echo "=== Installing Security and Compliance Tools ==="
install_checkov
echo ""

install_infracost
echo ""

echo "=== Installing Development Tools ==="
install_github_cli
echo ""

install_actionlint
echo ""

install_shellcheck
echo ""

install_precommit
echo ""

echo "=== Setting up Configuration Files ==="
create_terraform_version_file
echo ""

setup_tflint_config
echo ""

setup_checkov_config
echo ""

echo "=== Setting up Pre-commit Hooks ==="
setup_precommit_hooks
echo ""

echo "=== Installation Summary ==="
echo "Core Utilities:"
echo "  jq version: $(jq --version 2>/dev/null || echo 'Not found')"
echo "  yq version: $(yq --version 2>/dev/null || echo 'Not found')"
echo "  zip/unzip: $(command -v zip >/dev/null 2>&1 && echo 'Available' || echo 'Not found')"
echo ""
echo "Terraform Tools:"
echo "  tfenv version: $(tfenv --version 2>/dev/null || echo 'Not found')"
echo "  Terraform version: $(terraform --version 2>/dev/null | head -n1 || echo 'Not found')"
echo "  Terragrunt version: $(terragrunt --version 2>/dev/null || echo 'Not found')"
echo "  tflint version: $(tflint --version 2>/dev/null || echo 'Not found')"
echo "  tfsec version: $(tfsec --version 2>/dev/null || echo 'Not found')"
echo "  terraform-docs version: $(terraform-docs --version 2>/dev/null || echo 'Not found')"
echo ""
echo "Security and Compliance:"
echo "  Checkov version: $(checkov --version 2>/dev/null || echo 'Not found')"
echo "  infracost version: $(infracost --version 2>/dev/null || echo 'Not found')"
echo ""
echo "Development Tools:"
echo "  GitHub CLI version: $(gh --version 2>/dev/null | head -n1 || echo 'Not found')"
echo "  actionlint version: $(actionlint --version 2>/dev/null || echo 'Not found')"
echo "  shellcheck version: $(shellcheck --version 2>/dev/null | head -1 || echo 'Not found')"
echo "  pre-commit version: $(pre-commit --version 2>/dev/null || echo 'Not found')"
echo ""
echo "Configuration Files:"
echo "  .terraform-version: $([ -f .terraform-version ] && echo "$(cat .terraform-version)" || echo 'Not created')"
echo "  .tflint.hcl: $([ -f .tflint.hcl ] && echo 'Created' || echo 'Not created')"
echo "  .checkov.yaml: $([ -f .checkov.yaml ] && echo 'Created' || echo 'Not created')"
echo "  .pre-commit-config.yaml: $([ -f .pre-commit-config.yaml ] && echo 'Created' || echo 'Not created')"
echo ""
echo "=== Setup Complete! ==="
echo ""
echo "Your Terraform Azure Modules development environment is ready!"
echo ""
echo ">> Next Steps:"
echo "1. Authenticate with GitHub: gh auth login"
echo "2. Set up infracost API key: infracost auth login"
echo "3. Initialize tflint plugins: tflint --init"
echo "4. Test pre-commit hooks: pre-commit run --all-files"
echo "5. Start developing your Terraform modules!"
echo ""
echo ">> Available Commands:"
echo "  terraform fmt -recursive          # Format all Terraform files"
echo "  terraform validate                # Validate Terraform configuration"
echo "  tflint                           # Lint Terraform files"
echo "  tfsec .                          # Security scan"
echo "  checkov -d modules               # Compliance scan"
echo "  terraform-docs modules/monitoring # Generate documentation"
echo "  infracost breakdown --path .     # Cost estimation"
echo "  pre-commit run --all-files       # Run all quality checks"
echo ""
echo ">> Module Development Workflow:"
echo "1. Create/modify Terraform files in modules/"
echo "2. Run: terraform fmt -recursive"
echo "3. Run: terraform validate"
echo "4. Run: pre-commit run --all-files"
echo "5. Commit changes (pre-commit hooks will run automatically)"
echo "6. Push to GitHub (CI/CD pipeline will validate)"
echo ""
echo ">> Documentation:"
echo "- README.md files are automatically updated by terraform-docs"
echo "- Examples should be placed in modules/<name>/examples/"
echo "- Follow the existing module structure for consistency"
echo ""
echo "Happy Terraform module development! 🚀"
