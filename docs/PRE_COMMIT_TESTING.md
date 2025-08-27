# Pre-commit Terraform Testing

## Overview

Terraform tests have been integrated into the pre-commit hooks to ensure code quality and prevent broken modules from being committed.

## Available Hooks

### 1. `terraform-test` - Test All Modules
- **Triggers**: When any `.tf` or `.tftest.hcl` file changes
- **Action**: Runs `make terraform-test` to test all modules
- **Use case**: Comprehensive testing before major commits

### 2. `terraform-test-changed` - Test Changed Modules Only
- **Triggers**: When files in `modules/` directory change  
- **Action**: Runs tests only for modules with changed files
- **Use case**: Fast feedback during development (recommended for most commits)

## Installation and Setup

1. **Install pre-commit hooks** (one-time setup):
   ```bash
   pre-commit install
   ```

2. **Test the configuration**:
   ```bash
   # Test all hooks
   pre-commit run --all-files
   
   # Test only Terraform tests
   pre-commit run terraform-test --all-files
   pre-commit run terraform-test-changed --all-files
   ```

## How It Works

### Smart Module Detection
The `terraform-test-changed` hook intelligently:
- ✅ Detects which modules have changed files
- ✅ Only runs tests for modules that actually have test files
- ✅ Skips modules without tests (with informative message)
- ✅ Provides clear success/failure feedback

### Example Workflow
```bash
# Make changes to app-service-plan-function module
echo "# comment" >> modules/app-service-plan-function/main.tf

# Commit triggers pre-commit hooks
git add .
git commit -m "Update app service plan function"

# Output will show:
# Terraform Test (Changed Modules Only)....Passed
# ✅ Tests passed for module: app-service-plan-function
```

## Configuration Files

- **`.pre-commit-config.yaml`**: Main pre-commit configuration
- **`scripts/pre-commit-terraform-test.sh`**: Smart module test script
- **`Makefile`**: Contains test targets used by hooks

## Benefits

1. **🚀 Fast Feedback**: Catch issues before they reach CI/CD
2. **🎯 Targeted Testing**: Only test changed modules for speed
3. **🛡️ Quality Gates**: Prevent broken code from being committed  
4. **🔄 Consistent Environment**: All developers run same checks
5. **⚡ Skip Empty Modules**: Smart detection avoids testing modules without tests

## Troubleshooting

### Hook Fails
```bash
# See detailed error output
pre-commit run terraform-test-changed --verbose

# Run tests manually to debug
make terraform-test-module MODULE=your-module-name
```

### Skip Hooks Temporarily
```bash
# Skip all pre-commit hooks
git commit --no-verify -m "Emergency fix"

# Skip specific hook
SKIP=terraform-test-changed git commit -m "Skip terraform tests"
```

### Update Hook Configuration
```bash
# After modifying .pre-commit-config.yaml
pre-commit install --overwrite
```

## Best Practices

1. **Use the targeted hook**: `terraform-test-changed` is faster for development
2. **Run full tests**: Use `terraform-test` before major merges
3. **Keep tests fast**: Mock external dependencies (already configured)
4. **Write comprehensive tests**: Basic, validation, and output tests for each module

## Integration with IDE

The pre-commit hooks work alongside VS Code tasks:
- **Pre-commit**: Runs automatically on commit
- **VS Code Tasks**: Run manually during development
- **Makefile**: Direct command-line testing
