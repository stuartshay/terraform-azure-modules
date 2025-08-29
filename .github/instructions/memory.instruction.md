---
applyTo: '**'
---

# User Memory

## User Preferences
- Programming languages: Terraform, HCL, Bash, YAML
- Code style preferences: Follows Terraform best practices, uses variables and outputs, prefers modular design, explicit version pinning, robust error handling, clear comments
- Development environment: VS Code on Linux, zsh shell, uses recommended extensions for Azure and Terraform, GitHub Actions, pre-commit, Terraform Cloud
- Communication style: Concise, actionable, prefers clear recommendations, step-by-step, prefers root-cause analysis

## Project Context
- Current project type: Terraform Azure modules (infrastructure as code)
- Tech stack: Terraform, AzureRM provider, VS Code, GitHub Actions, pre-commit, Checkov, TFLint, tfsec, shellcheck
- Architecture patterns: Modular Terraform, reusable modules, example-driven, CI/CD with pre-commit and GitHub Actions
- Key requirements: Output documentation, CI/CD validation, secure secrets, Azure integration, CI reproducibility, security scanning, documentation automation, robust error handling
	- Enforce Checkov checks: CKV_AZURE_213, CKV_AZURE_16, CKV_AZURE_13, CKV_AZURE_88 for App Service modules

## Coding Patterns
- Uses variables.tf, outputs.tf, main.tf for each module
- Validates inputs and outputs, uses sensitive flags for secrets
- Documents modules and examples
- Uses .env and .env.template for secrets and environment variables
- Preferred patterns and practices: Pin tool versions in CI, auto-commit doc changes, validate configs before running checks
- Code organization preferences: Modular, clear separation of concerns, comments for rationale
- Testing approaches: Pre-commit hooks, CI validation, local/CI parity
- Documentation style: Inline comments, auto-generated docs, summary reports

## Context7 Research History
- Terraform CLI credentials and GitHub Actions: Confirmed from hashicorp/setup-terraform README that `cli_config_credentials_token` configures HCP Terraform credentials; environment variable alternative `TF_TOKEN_app_terraform_io` supported (Terraform >=1.2) per CLI config docs.
- Connection guidance: HashiCorp docs recommend providing credentials then running non-interactive commands; private module registry access requires valid user/team token (not org token).
- Libraries researched on Context7: Checkov, pre-commit, GitHub Actions best practices
- Best practices discovered: Pinning Checkov to avoid version drift/bugs, auto-committing terraform-docs changes, robust error handling in workflows
- Implementation patterns used: Version pinning, config validation, auto-commit/push for doc changes
- Version-specific findings: Checkov 3.2.456 is stable; newer versions may have breaking changes

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
 - Pre-commit workflow parity: Updated `.github/workflows/pre-commit.yml` to configure HCP Terraform auth with `hashicorp/setup-terraform@v3` using `cli_config_credentials_token: ${{ secrets.TF_API_TOKEN }}`, added a verification step using curl against the organizations endpoint, and exported `TF_TOKEN_app_terraform_io` into `$GITHUB_ENV` so hooks like terraform-docs, tflint, and any terraform init during docs generation can access private modules. Avoided using `secrets` in `if:` conditions to satisfy actionlint; used script-level checks instead.
- Pre-commit workflow CI failure: Checkov bug/version drift caused CI failures; root cause was unpinned Checkov version. Solution: Pin Checkov to 3.2.456 in workflow, add comments for maintainers, robustify workflow. Fix is committed, pushed, and in open PR. Workflow is robust, up to date, and follows best practices for reproducibility and error handling.

## Dependabot & Private Registry (Aug 2025)
- Dependabot now configured to access HCP Terraform private registry via `registries`:
	- Added `tfc-private` with `type: terraform-registry`, `url: https://app.terraform.io`, and `token: ${{secrets.DEPENDABOT_TF_API_TOKEN}}`.
	- Each Terraform `updates` entry for module directories includes `registries: [tfc-private]` so private modules/providers can be resolved.
- Required secret: Create repository secret `DEPENDABOT_TF_API_TOKEN` with a valid HCP Terraform user/team token that has access to the private modules used by the modules in this repo (e.g., app-service-plan-function depends on storage-account).

## Conversation History
- Important decisions made: Pin Checkov to 3.2.456, add comments for maintainers, robustify workflow
- Recurring questions or topics: CI failures due to tool version drift, local vs CI parity, workflow robustness
- Solutions that worked well: Pinning tool versions, auto-commit for doc changes, explicit config validation
- Things to avoid or that didn't work: Unpinned tool versions, relying on latest Checkov in CI

## Function App Module Security/Compliance Fixes (Aug 2025)
- Issue: Lint error due to incorrect placement of azurerm_private_endpoint resource (was nested inside azurerm_storage_account block)
- Fix: Moved azurerm_private_endpoint "storage" resource to the top level of main.tf, referencing the storage account and subnet correctly, and conditioned on enable_storage_network_rules and subnet presence
- Outcome: All validation and linting checks now pass; configuration is valid and secure
- Note: This pattern should be followed for all future private endpoint resources—never nest resource blocks inside other resource blocks in Terraform

## Notes
	- .vscode/settings.json is well-configured for Terraform and Azure development
	- No MCP Server-specific files found in the repo; MCP Server context is via environment variables and language server integration
	- All module outputs are well-documented and follow Terraform conventions
	- Recommend keeping .env out of version control and using .env.template for sharing config structure
	- CKV_AZURE_213, CKV_AZURE_16, CKV_AZURE_13, and CKV_AZURE_88 are required and must not be skipped in .checkov.yaml for App Service modules. This compliance documentation should be preserved in future changes.
	- The fix for the pre-commit workflow CI failure is committed, pushed, and in an open PR. The workflow is robust, up to date, and follows best practices for reproducibility and error handling. Checkov is now configured to fail on any finding (not just HIGH/CRITICAL). Next steps: User to review and merge the PR, monitor CI for any further issues.

## Storage Account Requirements (Issue #34 - Aug 2025)
- Goal: Refine requirements for the `storage-account` module to enforce diagnostics (StorageRead/Write/Delete) for Blob, File, Queue, Table; enable Blob versioning; and integrate SAS token management with Azure Key Vault.
- Diagnostics: Use `azurerm_monitor_diagnostic_setting` against subresources `blobServices/default`, `fileServices/default`, `queueServices/default`, and `tableServices/default` with categories `StorageRead`, `StorageWrite`, `StorageDelete`; destinations parameterized (Log Analytics workspace ID, Event Hub auth rule ID, archive storage ID) with retention days.
- Versioning: Enable `blob_properties.versioning_enabled = true`; recommend `change_feed_enabled = true` and soft delete retention for blobs and containers.
- Immutability: Support optional container-level immutability via `azurerm_storage_container_immutability_policy` for version-level immutability when requested.
- SAS & Key Vault: Optionally generate SAS via `data.azurerm_storage_account_sas` with configurable services/resource types/permissions/expiry and store in Key Vault as `azurerm_key_vault_secret` when `key_vault_id` provided.
- References (Microsoft Docs):
	- Blob logs categories: https://learn.microsoft.com/azure/azure-monitor/reference/supported-logs/microsoft-storage-storageaccounts-blobservices-logs
	- File logs categories: https://learn.microsoft.com/azure/azure-monitor/reference/supported-logs/microsoft-storage-storageaccounts-fileservices-logs
	- Queue logs categories: https://learn.microsoft.com/azure/azure-monitor/reference/supported-logs/microsoft-storage-storageaccounts-queueservices-logs
	- Table logs categories: https://learn.microsoft.com/azure/azure-monitor/reference/supported-logs/microsoft-storage-storageaccounts-tableservices-logs
	- Service monitoring overviews: Blob https://learn.microsoft.com/azure/storage/blobs/monitor-blob-storage, Queue https://learn.microsoft.com/azure/storage/queues/monitor-queue-storage, Table https://learn.microsoft.com/azure/storage/tables/monitor-table-storage, Files https://learn.microsoft.com/azure/storage/files/storage-files-monitoring
	- Classic logging note retained for context: https://learn.microsoft.com/azure/storage/common/manage-storage-analytics-logs

	### Outcome
	- Updated GitHub Issue #34 with a comprehensive specification: diagnostics categories and destinations, blob versioning + change feed + soft-delete, optional container immutability, and SAS → Key Vault integration with secure defaults.
	- Added proposed module inputs/outputs and explicit acceptance criteria to guide implementation and testing.
	- Linked to relevant Microsoft docs for categories and monitoring references to ensure accuracy.

## Pre-commit/Makefile Path Issue (Aug 2025)
- Issue: 'make terraform-test' and pre-commit fail with '/bin/sh: 5: cd: can't cd to modules/function-app', but the directory exists and is accessible in direct shell.
- Investigation:
  - All direct shell and absolute path checks confirm the directory exists and is accessible.
  - Permissions, casing, and .gitignore are not the cause; directory is not ignored or deleted.
  - Makefile logic is correct and works for other modules.
  - The error is reproducible in both Makefile and pre-commit, but not in direct shell.
  - No symlinks, hidden files, or special characters found in the path.
  - No evidence of parallelism or race conditions in Makefile or pre-commit config.
- Hypothesis: The error is likely due to an ephemeral or environmental issue in the pre-commit/Makefile context (e.g., race condition, file lock, or transient FS state). It may also be related to the working directory context or shell environment used by pre-commit or Makefile.
- Next steps: Consider adding debug output to Makefile/test logic to capture environment state at failure point, or check for parallelism/race conditions in pre-commit or Makefile logic. If the issue persists, try running with 'SHELL=bash make terraform-test' or adding 'pwd' and 'ls' debug lines before the failing 'cd' command in the Makefile.
