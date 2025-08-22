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

## Coding Patterns
- Uses variables.tf, outputs.tf, main.tf for each module
- Validates inputs and outputs, uses sensitive flags for secrets
- Documents modules and examples
- Uses .env and .env.template for secrets and environment variables

## Context7 Research History
- No Context7 research performed yet for this project

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
