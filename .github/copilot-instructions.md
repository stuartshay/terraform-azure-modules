# Terraform Azure Modules Development Instructions

**Always reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.**

## Working Effectively

### Bootstrap and Environment Setup
Run these commands in sequence to set up the complete development environment:

```bash
# Bootstrap the development environment (installs all tools)
./install.sh
# TIMING: 3-5 minutes - NEVER CANCEL. Set timeout to 10+ minutes.
# NOTE: Some tool installations may fail due to network limitations. This is expected.

# Authenticate with external services (required for full functionality)
gh auth login
infracost auth login

# Initialize tools
tflint --init
pre-commit install
```

**CRITICAL ENVIRONMENT SETUP:**
- **tfenv and Terraform**: Version 1.13.1 (specified in `.terraform-version`)
- **PATH requirement**: Add `export PATH="$HOME/.tfenv/bin:$PATH"` to your shell profile
- **Essential tools**: tfsec, checkov (3.2.456), pre-commit, jq, yq

### Core Development Commands

#### Format and Validate (Fast - under 1 second each)
```bash
# Format Terraform code
terraform fmt -recursive .
make terraform-fmt

# Check formatting without changes  
terraform fmt -check -recursive .
make terraform-fmt-check
```

#### Module Validation (3-4 seconds per module)
```bash
# Validate all modules - NEVER CANCEL. Set timeout to 5+ minutes.
make validate-all

# Validate specific module
make module-validate MODULE=storage-account

# Initialize and validate single module
cd modules/storage-account
terraform init -backend=false  # 3-4 seconds
terraform validate              # <1 second
```

#### Testing Infrastructure
```bash
# Run Terraform native tests - NEVER CANCEL. Set timeout to 10+ minutes.
make terraform-test

# Test specific module with tests
make terraform-test-module MODULE=monitoring

# Test specific test file
make terraform-test-file MODULE=monitoring FILE=basic.tftest.hcl
```

#### Security and Quality Checks (1-8 seconds per scan)
```bash
# Security scanning
tfsec modules/storage-account --soft-fail  # <1 second
checkov -d modules/storage-account --framework terraform --quiet  # 5-8 seconds

# All quality checks - NEVER CANCEL. Set timeout to 15+ minutes.
make pre-commit
pre-commit run --all-files
```

## Module Structure and Navigation

### Key Module Locations
- **modules/**: All Terraform modules (13 modules total)
  - `storage-account/`: Azure Storage with containers, queues, tables
  - `monitoring/`: Log Analytics, Application Insights, alerting  
  - `networking/`: VNet, subnets, NSGs, flow logs
  - `app-service-plan-function/`: Function App service plans
  - `container-instances/`: Azure Container Instances
  - `service-bus/`: Service Bus namespace and messaging

### Module Standard Structure
Each module follows this structure:
```
modules/[module-name]/
├── main.tf              # Main resource definitions
├── variables.tf         # Input variables  
├── outputs.tf           # Output values
├── versions.tf          # Provider requirements
├── README.md            # Generated documentation
├── examples/            # Usage examples
│   ├── basic/          # Minimal example
│   └── complete/       # Full-featured example
└── tests/              # Terraform native tests
    ├── basic.tftest.hcl
    ├── validation.tftest.hcl
    └── outputs.tftest.hcl
```

### Testing Approach
- **Terraform Native Tests**: `*.tftest.hcl` files in `tests/` directories
- **Mock-Based Testing**: Tests use `command = plan` to avoid real Azure resources
- **Validation Tests**: Check variable validation rules and constraints
- **Output Tests**: Verify module outputs match expected values

## Common Development Workflows

### Making Changes to Modules
1. **Edit module files** in `modules/[module-name]/`
2. **Format code**: `terraform fmt -recursive .` (required - <1 second)
3. **Validate changes**: `cd modules/[module-name] && terraform init -backend=false && terraform validate`
4. **Run security scans**: `tfsec modules/[module-name] --soft-fail`
5. **Test changes**: `make terraform-test-module MODULE=[module-name]`
6. **Run pre-commit**: `pre-commit run --all-files` - NEVER CANCEL. Set timeout to 15+ minutes.
7. **Commit changes**: Pre-commit hooks run automatically

### Validation Pipeline Commands
Always run these commands in sequence for complete validation:
```bash
# 1. Format check (required by CI)
make terraform-fmt-check

# 2. Validate all modules - NEVER CANCEL. Set timeout to 5+ minutes.
make validate-all  

# 3. Security scanning - NEVER CANCEL. Set timeout to 10+ minutes.
make security-scan

# 4. Run tests - NEVER CANCEL. Set timeout to 10+ minutes.
make terraform-test
```

**TIMING EXPECTATIONS:**
- **Format checking**: <1 second
- **Module validation**: 3-4 seconds per module (13 modules = ~45 seconds)
- **Security scanning**: 1-8 seconds per module  
- **Terraform tests**: 1-5 seconds per test file
- **Full pre-commit run**: 2-15 minutes depending on changes

## CI/CD Integration

### GitHub Actions Workflows
- **pre-commit.yml**: Comprehensive validation, formatting, testing
- **terraform.yml**: Module validation and security scanning
- **terraform-cloud-deploy.yml**: Publishes modules to Terraform Cloud registry

### Local Development Validation  
Before pushing changes, always run:
```bash
# Quick development validation - NEVER CANCEL. Set timeout to 10+ minutes.
make dev-validate

# Complete validation (matches CI) - NEVER CANCEL. Set timeout to 20+ minutes.
make ci-validate
```

## Configuration Files Reference

### Key Configuration Files
- **`.terraform-version`**: Terraform version (1.13.1)  
- **`.tflint.hcl`**: TFLint rules and Azure provider configuration
- **`.checkov.yaml`**: Checkov security scanning configuration (version 3.2.456)
- **`.pre-commit-config.yaml`**: Pre-commit hooks configuration
- **`Makefile`**: Development workflow automation

### Pre-commit Hook Functionality
The repository uses comprehensive pre-commit hooks that run automatically:
- Terraform formatting and validation
- Security scanning (tfsec, checkov)
- Documentation generation (terraform-docs)
- Linting (tflint for Terraform, shellcheck for scripts)
- File formatting (trailing whitespace, end-of-file)

## Troubleshooting Common Issues

### Installation Problems
```bash
# If tfenv PATH issues
export PATH="$HOME/.tfenv/bin:$PATH"
echo 'export PATH="$HOME/.tfenv/bin:$PATH"' >> ~/.bashrc

# If checkov installation fails  
pip install --user checkov==3.2.456

# If tfsec not found
wget -O /tmp/tfsec https://github.com/aquasecurity/tfsec/releases/latest/download/tfsec-linux-amd64
sudo chmod +x /tmp/tfsec
sudo mv /tmp/tfsec /usr/local/bin/tfsec
```

### Module Initialization Issues
```bash
# For modules with external dependencies that require authentication
cd modules/[module-name]
terraform init -backend=false  # Use -backend=false to skip remote state

# If getting registry errors, some modules reference private Terraform Cloud modules
# These require TF_API_TOKEN environment variable for authentication
```

### Pre-commit Hook Failures
```bash
# Update and reinstall hooks
pre-commit autoupdate
pre-commit install --overwrite

# Skip hooks temporarily (emergency only)  
git commit --no-verify -m "Emergency commit"

# Run specific hook
pre-commit run terraform_fmt --all-files
```

## Repository-Specific Information

### Module Dependencies
- **External dependencies**: Some modules reference Terraform Cloud private registry
- **Provider requirements**: Azure provider >= 4.40 (varies by module)
- **Network requirements**: Module initialization may require internet access

### Testing Limitations
- **No real Azure resources**: Tests use `command = plan` to avoid costs
- **Network dependent**: Some module initialization requires internet connectivity  
- **Mock-based validation**: Tests validate configuration correctness, not runtime behavior

### Documentation Generation
- **terraform-docs**: Automatically updates README.md files
- **Pre-commit integration**: Documentation updates happen automatically
- **CI automation**: README files may be auto-committed by CI if outdated

## Validated Scenarios and Examples

### Scenario 1: New Developer Setup
```bash
# Complete setup from scratch (tested timing)
./install.sh                    # 3-5 minutes
export PATH="$HOME/.tfenv/bin:$PATH"
terraform --version            # Verify: v1.13.1
make status                    # Check tool installation
```

### Scenario 2: Making Module Changes  
```bash
# Edit module files, then validate
terraform fmt -recursive .     # <1 second - REQUIRED
cd modules/storage-account
terraform init -backend=false  # 3-4 seconds  
terraform validate             # <1 second
cd ../..
tfsec modules/storage-account --soft-fail  # <1 second
checkov -d modules/storage-account --framework terraform --quiet  # 5-8 seconds
```

### Scenario 3: Running Module Tests
```bash
# Test a module with comprehensive test suite
cd modules/container-instances
terraform init -backend=false  # First time: 3-4 seconds
terraform test                 # 31 tests in ~15 seconds
# Expected output: "Success! 31 passed, 0 failed."
```

### Scenario 4: Pre-commit Validation
```bash
# Complete quality gate validation
pre-commit validate-config     # <1 second
pre-commit run --all-files     # 2-15 minutes - NEVER CANCEL
```

**CRITICAL REMINDERS:**
- **NEVER CANCEL** long-running commands (setup, validation, tests)  
- **Always set appropriate timeouts** (10+ minutes for setup, 5+ for validation, 15+ for pre-commit)
- **PATH setup is required** for tfenv/terraform commands
- **Format before validate** - formatting is enforced and required by CI
- **Security scans are mandatory** - tfsec and checkov must pass
- **Test results are deterministic** - expect specific pass/fail counts per module