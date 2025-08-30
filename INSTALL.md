# Terraform Azure Modules - Development Environment Setup

This document describes the installation script for setting up a complete development environment for Terraform Azure modules.

## Overview

The `install.sh` script automates the installation of all tools needed for Terraform module development, testing, validation, and security scanning. It's specifically tailored for Azure Terraform module development and follows best practices for infrastructure as code.

## Quick Start

```bash
# Clone the repository
git clone https://github.com/stuartshay/terraform-azure-modules.git
cd terraform-azure-modules

# Run the installation script
./install.sh

# Follow the post-installation steps
gh auth login
infracost auth login
tflint --init
pre-commit run --all-files
```

## What Gets Installed

### Core Utilities
- **jq** - JSON processor for parsing CLI outputs
- **yq** - YAML processor for configuration files
- **zip/unzip** - Archive utilities for package management

### Terraform Tools
- **tfenv** - Terraform version manager for consistent versioning
- **Terraform** - Infrastructure as Code tool (version managed by tfenv)
- **Terragrunt** - DRY Terraform configurations and orchestration
- **tflint** - Terraform linter with Azure provider rules
- **tfsec** - Security scanner for Terraform code
- **terraform-docs** - Documentation generator for modules

### Security and Compliance
- **Checkov** - Infrastructure security and compliance scanner
- **infracost** - Cost estimation for infrastructure changes

### Development Tools
- **GitHub CLI** - Command-line interface for GitHub operations
- **actionlint** - GitHub Actions workflow linter
- **shellcheck** - Shell script linter
- **pre-commit** - Git hooks framework for code quality

### Configuration Files Created
- `.terraform-version` - Terraform version specification
- `.tflint.hcl` - TFLint configuration with Azure rules
- `.checkov.yaml` - Checkov security scanning configuration
- `.pre-commit-config.yaml` - Pre-commit hooks configuration

## System Requirements

### Supported Operating Systems
- **Linux** (Ubuntu/Debian with apt, RHEL/CentOS with yum)
- **macOS** (with Homebrew)

### Prerequisites
- **Git** - Version control system
- **curl/wget** - For downloading packages
- **sudo access** - For system package installation
- **Python 3** - Required for Checkov and pre-commit
- **Homebrew** (macOS only) - Package manager for macOS

## Installation Process

The script follows this sequence:

1. **Core Utilities Installation**
   - Installs jq, yq, and zip utilities
   - Sets up basic tools needed by other components

2. **Terraform Ecosystem Setup**
   - Installs tfenv for version management
   - Installs Terraform using the version specified in `.terraform-version`
   - Sets up Terragrunt, tflint, tfsec, and terraform-docs

3. **Security Tools Installation**
   - Installs Checkov for compliance scanning
   - Sets up infracost for cost analysis

4. **Development Environment**
   - Installs GitHub CLI for repository management
   - Sets up actionlint and shellcheck for code quality
   - Configures pre-commit framework

5. **Configuration Setup**
   - Creates `.terraform-version` file
   - Sets up tflint configuration with Azure provider
   - Configures Checkov for module scanning
   - Installs and configures pre-commit hooks

## Post-Installation Steps

After running the install script, complete these steps:

### 1. Authenticate with Services
```bash
# GitHub authentication (required for private repos and API access)
gh auth login

# Infracost authentication (required for cost estimation)
infracost auth login
```

### 2. Initialize Tools
```bash
# Initialize tflint plugins
tflint --init

# Test pre-commit hooks
pre-commit run --all-files
```

### 3. Verify Installation
```bash
# Check tool versions
terraform --version
tflint --version
tfsec --version
checkov --version
pre-commit --version
```

## Development Workflow

### Module Development Process
1. **Create/modify Terraform files** in `modules/`
2. **Format code**: `terraform fmt -recursive`
3. **Validate syntax**: `terraform validate`
4. **Run quality checks**: `pre-commit run --all-files`
5. **Commit changes** (pre-commit hooks run automatically)
6. **Push to GitHub** (CI/CD pipeline validates)

### Available Commands

#### Terraform Operations
```bash
terraform fmt -recursive          # Format all Terraform files
terraform validate                # Validate configuration
terraform init                    # Initialize modules
terraform plan                    # Preview changes
```

#### Code Quality
```bash
tflint                           # Lint Terraform files
tfsec .                          # Security scan
checkov -d modules               # Compliance scan
terraform-docs modules/monitoring # Generate documentation
```

#### Cost Analysis
```bash
infracost breakdown --path .     # Cost estimation
infracost diff --path .          # Cost difference analysis
```

#### Pre-commit Operations
```bash
pre-commit run --all-files       # Run all hooks
pre-commit run terraform_fmt     # Run specific hook
pre-commit autoupdate           # Update hook versions
```

## Configuration Details

### Terraform Version Management
The script uses tfenv to manage Terraform versions:
- Version specified in `.terraform-version` file
- Automatically installs and uses the specified version
- Consistent across development and CI/CD environments

### TFLint Configuration
Located in `.tflint.hcl`:
- Azure provider plugin enabled
- Comprehensive rule set for best practices
- Documentation and naming convention enforcement

### Checkov Configuration
Located in `.checkov.yaml`:
- Scans `modules/` directory
- Configured for Terraform framework
- Excludes irrelevant checks for modules
- Hard fails on HIGH and CRITICAL issues
- **Version pinned to 3.2.456** for consistency between local and CI environments

### Pre-commit Hooks
Located in `.pre-commit-config.yaml`:
- **Terraform**: formatting, validation, documentation, linting
- **Security**: tfsec and Checkov scanning
- **General**: file formatting, JSON/YAML validation
- **GitHub Actions**: workflow validation
- **Shell**: script linting

## Troubleshooting

### Common Issues

#### Permission Errors
```bash
# If you get permission errors, ensure sudo access
sudo -v

# For user-installed tools, ensure PATH includes ~/.local/bin
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

#### Python/pip Issues
```bash
# Install Python 3 and pip if missing
# Ubuntu/Debian:
sudo apt update && sudo apt install python3 python3-pip

# RHEL/CentOS:
sudo yum install python3 python3-pip

# macOS:
brew install python3
```

#### tfenv PATH Issues
```bash
# Restart shell or source profile
source ~/.bashrc  # or ~/.zshrc

# Manually add to PATH if needed
export PATH="$HOME/.tfenv/bin:$PATH"
```

#### Pre-commit Hook Failures
```bash
# Update hooks to latest versions
pre-commit autoupdate

# Clear cache and reinstall
pre-commit clean
pre-commit install
```

### Tool-Specific Issues

#### Checkov Installation
```bash
# If Checkov fails to install
pip3 install --user --upgrade pip
pip3 install --user checkov
```

#### Infracost Setup
```bash
# Register for free API key
infracost register

# Or set API key manually
export INFRACOST_API_KEY="your-api-key"
```

#### GitHub CLI Authentication
```bash
# Use token authentication if browser auth fails
gh auth login --with-token < token.txt
```

## Advanced Configuration

### Custom Tool Versions
Edit the script to specify different versions:
```bash
# Example: Use specific Terraform version
echo "1.6.0" > .terraform-version
tfenv install 1.6.0
tfenv use 1.6.0
```

### Additional Pre-commit Hooks
Add to `.pre-commit-config.yaml`:
```yaml
- repo: https://github.com/pre-commit/pre-commit-hooks
  rev: v4.6.0
  hooks:
    - id: check-merge-conflict
    - id: check-case-conflict
```

### Custom TFLint Rules
Modify `.tflint.hcl`:
```hcl
rule "terraform_naming_convention" {
  enabled = true
  format  = "snake_case"
  custom_formats = {
    module_name = "^[a-z][a-z0-9_]*[a-z0-9]$"
  }
}
```

## Contributing

When contributing to this project:

1. **Follow the development workflow** outlined above
2. **Ensure all pre-commit hooks pass** before submitting PRs
3. **Update documentation** for any new tools or configurations
4. **Test the install script** on clean environments

## Support

For issues with the installation script:

1. **Check the troubleshooting section** above
2. **Review tool-specific documentation** for detailed configuration
3. **Open an issue** on GitHub with:
   - Operating system and version
   - Error messages and logs
   - Steps to reproduce

## License

This project is licensed under the Apache License 2.0. See the [LICENSE](LICENSE) file for details.
