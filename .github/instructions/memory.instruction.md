---
applyTo: '**'
---

# User Memory

## User Preferences
- Programming languages: Terraform, HCL
- Code style preferences: Follows Terraform best practices, uses variables and outputs, prefers modular design
- Development environment: VS Code on Linux, zsh shell, uses recommended extensions for Azure and Terraform
- Communication style: Concise, actionable, prefers clear recommendations

## Project Context
- Current project type: Terraform Azure modules (infrastructure as code)
- Tech stack: Terraform, AzureRM provider, VS Code, GitHub Actions
- Architecture patterns: Modular Terraform, reusable modules, example-driven
- Key requirements: Output documentation, CI/CD validation, secure secrets, Azure integration
	- Enforce Checkov checks: CKV_AZURE_213, CKV_AZURE_16, CKV_AZURE_13, CKV_AZURE_88 for App Service modules

## Coding Patterns
- Uses variables.tf, outputs.tf, main.tf for each module
- Validates inputs and outputs, uses sensitive flags for secrets
- Documents modules and examples
- Uses .env and .env.template for secrets and environment variables

## Context7 Research History
- Terraform CLI credentials and GitHub Actions: Confirmed from hashicorp/setup-terraform README that `cli_config_credentials_token` configures HCP Terraform credentials; environment variable alternative `TF_TOKEN_app_terraform_io` supported (Terraform >=1.2) per CLI config docs.
- Connection guidance: HashiCorp docs recommend providing credentials then running non-interactive commands; private module registry access requires valid user/team token (not org token).

## Shellcheck Issues and Fixes (Aug 2025)
- SC2086: Added double quotes to all variable expansions in .github/workflows/terraform-cloud-deploy.yml to prevent globbing and word splitting.
- SC2034: Removed unused TEMP_DIR assignment in the 'Create module package' step; used the value inline instead.
- Fixed context access for VERSION in shell scripts: replaced ${{ env.VERSION }} with $VERSION inside run blocks to avoid invalid context access errors.

## GitHub Actions CI/CD Troubleshooting (Aug 2025)
- Issue: GitHub Action failed with 'Resource not accessible by integration' and SARIF upload errors.
- Root cause: Missing explicit permissions for GITHUB_TOKEN (security-events: write) in workflow YAML.
- Solution: Added permissions: contents: read and security-events: write to pre-commit.yml.
- No additional custom secrets or tokens required for current workflows; only GITHUB_TOKEN is used.
- Confirmed workflows now pass permission checks; any remaining errors are unrelated to secrets/env.
- Terraform Cloud auth failure: Observed 401 Unauthorized when fetching private registry module during `terraform init` in modules. Root cause is missing CLI credentials in runner.
- Fix implemented: In `.github/workflows/terraform.yml`, added `cli_config_credentials_token: ${{ secrets.TF_API_TOKEN }}` to setup-terraform step, plus an explicit verification step hitting `https://app.terraform.io/api/v2/organizations/$TF_CLOUD_ORGANIZATION` with the token to fail fast if invalid. Also enforced `-input=false` during init.
- Manual trigger: Added `workflow_dispatch` to the workflow so runs can be started manually from the Actions tab for on-demand validation.

## Conversation History
- Investigated VS Code settings for Terraform MCP Server
- Analyzed VS Code Output integration (no custom output channel, relies on Terraform language server)
- Reviewed monitoring module structure, outputs, and variables
- Confirmed best practices for outputs, secrets, and documentation

## Notes
	- .vscode/settings.json is well-configured for Terraform and Azure development
	- No MCP Server-specific files found in the repo; MCP Server context is via environment variables and language server integration
	- All module outputs are well-documented and follow Terraform conventions
	- Recommend keeping .env out of version control and using .env.template for sharing config structure
	- CKV_AZURE_213, CKV_AZURE_16, CKV_AZURE_13, and CKV_AZURE_88 are required and must not be skipped in .checkov.yaml for App Service modules. This compliance documentation should be preserved in future changes.
