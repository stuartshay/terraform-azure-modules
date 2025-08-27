# Terraform Testing Guide

This document provides comprehensive guidance on using Terraform's native testing framework with the Azure modules in this repository.

## Overview

We have integrated Terraform's native testing framework (available in Terraform 1.6+) to provide comprehensive testing for our modules. This approach offers several advantages:

- **Native Integration**: Uses Terraform's built-in test framework
- **Fast Execution**: Tests run in plan mode without creating real resources
- **No Azure Credentials Required**: Tests validate logic without requiring Azure access
- **CI/CD Ready**: Can be integrated into automated pipelines
- **Comprehensive Coverage**: Tests functionality, validation, and outputs

## Test Structure

Each module with tests follows this structure:

```
modules/{module-name}/
├── tests/
│   ├── basic.tftest.hcl      # Basic functionality tests
│   ├── validation.tftest.hcl # Input validation tests
│   ├── outputs.tftest.hcl    # Output validation tests
│   └── setup.tftest.hcl      # Optional, for documentation
```

## Running Tests

### Prerequisites

- Terraform >= 1.6.0
- No Azure credentials required (tests run in plan mode)
- VS Code with recommended extensions (optional but recommended)

### VS Code Test Runner Integration

#### Setup
1. **Install Recommended Extensions**: VS Code will prompt to install recommended extensions when you open the project
2. **Key Extensions**:
   - `hashicorp.terraform` - Terraform language support
   - `hbenl.vscode-test-explorer` - Test Explorer UI
   - `ms-vscode.makefile-tools` - Makefile support

#### Running Tests in VS Code

**Using Command Palette (Ctrl+Shift+P / Cmd+Shift+P):**
- `Tasks: Run Task` → Select from available Terraform test tasks
- `Test: Run All Tests` → Run all configured tests
- `Test: Run Test at Cursor` → Run test at current cursor position

**Using Test Explorer:**
1. Open Test Explorer panel (View → Test)
2. Tests will be automatically discovered
3. Click play button next to any test or test suite
4. View results with detailed output

**Using Tasks:**
- `Ctrl+Shift+P` → `Tasks: Run Task` → Choose:
  - `Terraform: Test All Modules`
  - `Terraform: Test App Service Plan Function`
  - `Terraform: Test Basic Functionality`
  - `Terraform: Test Validation`
  - `Terraform: Test Outputs`
  - `Terraform: Test Current File`

**Keyboard Shortcuts:**
- `Ctrl+Shift+T` (Windows/Linux) or `Cmd+Shift+T` (Mac) - Run default test task
- `F5` - Debug current test file
- `Ctrl+F5` - Run current test file without debugging

#### VS Code Features

**Test Discovery:**
- Automatic discovery of `.tftest.hcl` files
- Test hierarchy in Test Explorer
- Real-time test status indicators

**Debugging:**
- Set breakpoints in test files
- Step through test execution
- Inspect variables and assertions
- Debug launch configurations included

**IntelliSense:**
- Terraform syntax highlighting for test files
- Auto-completion for Terraform functions
- Validation and error highlighting
- Hover documentation

### Available Commands

#### Run All Tests for All Modules
```bash
make terraform-test
```

#### Run Tests for a Specific Module
```bash
make terraform-test-module MODULE=app-service-plan-function
```

#### Run a Specific Test File
```bash
make terraform-test-file MODULE=app-service-plan-function FILE=basic.tftest.hcl
```

#### Direct Terraform Commands
```bash
# From module directory
cd modules/app-service-plan-function
terraform test

# Run specific test file
terraform test tests/basic.tftest.hcl
```

## Test Types

### 1. Basic Functionality Tests (`basic.tftest.hcl`)

Tests core module functionality with various configurations:

- Default parameter values
- Different configuration combinations
- Resource naming conventions
- Tag application
- Cross-platform compatibility

Example:
```hcl
run "basic_app_service_plan_creation" {
  command = plan

  variables {
    workload            = "test"
    environment         = "dev"
    resource_group_name = "rg-test-dev-001"
    location            = "East US"
  }

  assert {
    condition     = azurerm_service_plan.functions.name == "asp-test-functions-dev-001"
    error_message = "App Service Plan name should follow the naming convention"
  }
}
```

### 2. Validation Tests (`validation.tftest.hcl`)

Tests input validation rules and error conditions:

- Invalid parameter values
- Boundary conditions
- Required parameter validation
- Custom validation rules

Example:
```hcl
run "invalid_os_type" {
  command = plan

  variables {
    workload            = "test"
    environment         = "dev"
    resource_group_name = "rg-test-dev-001"
    location            = "East US"
    os_type             = "MacOS"
  }

  expect_failures = [
    var.os_type,
  ]
}
```

### 3. Output Tests (`outputs.tftest.hcl`)

Tests that outputs are correctly populated and formatted:

- Output value correctness
- Output format validation
- Non-null/non-empty checks
- Cross-reference with resource attributes

Example:
```hcl
run "verify_all_outputs" {
  command = plan

  variables {
    workload            = "output-test"
    environment         = "dev"
    resource_group_name = "rg-output-test-dev-001"
    location            = "East US"
  }

  assert {
    condition     = output.app_service_plan_id == azurerm_service_plan.functions.id
    error_message = "app_service_plan_id output should match the resource ID"
  }
}
```

## Test Framework Features

### Provider Configuration

Each test file requires its own provider configuration. Use the modern `mock_provider` syntax for clean, authentication-free testing:

```hcl
# Mock the AzureRM provider to avoid authentication requirements
mock_provider "azurerm" {}
```

**Key Benefits of mock_provider:**
- ✅ No Azure authentication required
- ✅ Clean, modern syntax  
- ✅ Avoids deprecated configuration options
- ✅ Fast test execution
- ✅ Works consistently across environments

**Note**: Terraform's test framework requires each test file to have its own provider configuration. Attempts to centralize provider configuration in a shared setup file are not currently supported by the framework.

### Test Commands

- `command = plan`: Runs terraform plan (most common)
- `command = apply`: Runs terraform apply (use sparingly)
- `command = validate`: Runs terraform validate

### Assertions

```hcl
assert {
  condition     = # Boolean expression
  error_message = "Descriptive error message"
}
```

### Expected Failures

```hcl
expect_failures = [
  var.parameter_name,
  resource.resource_name,
]
```

## Current Test Coverage

### app-service-plan-function Module

✅ **Implemented and Tested**

**Basic Functionality Tests:**
- App Service Plan creation with default values
- Windows OS type configuration
- Premium SKU (EP3) with custom worker count
- All supported SKU types (EP1, EP2, EP3)
- Tag application and validation
- Naming convention compliance

**Validation Tests:**
- Invalid OS type rejection (e.g., "MacOS")
- Invalid SKU name rejection (e.g., "S1")
- Worker count boundary validation (min: 1, max: 20)
- Valid OS type acceptance (Linux, Windows)
- Valid SKU acceptance (EP1, EP2, EP3)

**Output Tests:**
- All outputs populated correctly
- Output values match resource attributes
- Output format validation (Azure resource ID format)
- Non-null/non-empty output verification
- Cross-platform output consistency

### Other Modules

🔄 **Planned for Future Implementation**
- app-service-web
- monitoring
- networking
- storage-account

## Adding Tests to New Modules

### 1. Create Test Directory Structure

```bash
mkdir -p modules/{module-name}/tests
```

### 2. Create Test Files

Create the test files using the mock provider pattern:
- `basic.tftest.hcl` (basic functionality)
- `validation.tftest.hcl` (input validation) 
- `outputs.tftest.hcl` (output validation)
- `setup.tftest.hcl` (optional, for documentation)

### 3. Add Provider Configuration

Include in each test file:
```hcl
# Mock the AzureRM provider to avoid authentication requirements
mock_provider "azurerm" {}
```

### 4. Write Test Cases

Follow the patterns established in the app-service-plan-function module.

### 5. Update Documentation

Add testing information to the module's README.md.

## Best Practices

### Test Naming

- Use descriptive test names that explain what is being tested
- Group related tests in the same file
- Use consistent naming patterns

### Test Coverage

- Test default values
- Test all parameter combinations
- Test validation rules
- Test edge cases and boundaries
- Test all outputs

### Assertions

- Write clear, descriptive error messages
- Test one concept per assertion
- Use specific conditions rather than generic ones

### Variables

- Use realistic but clearly test-related values
- Follow naming conventions in test data
- Use consistent test data patterns

## Troubleshooting

### Common Issues

1. **Provider Configuration Missing**
   - Ensure each test file has `mock_provider "azurerm" {}` at the top
   - Each test file must have its own provider configuration

2. **Test Failures**
   - Check assertion conditions carefully
   - Verify variable names and values
   - Ensure resource references are correct

3. **Terraform Version**
   - Ensure Terraform >= 1.6.0 for test framework support
   - Update module version requirements if needed

### Debugging Tests

1. **Run Individual Tests**
   ```bash
   terraform test tests/basic.tftest.hcl
   ```

2. **Check Module Validation**
   ```bash
   terraform validate
   ```

3. **Review Test Output**
   - Look for specific assertion failures
   - Check variable values and resource attributes

## Integration with CI/CD

### GitHub Actions Example

```yaml
name: Terraform Tests

on:
  pull_request:
    paths:
      - 'modules/**'

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: 1.6.0
          
      - name: Run Terraform Tests
        run: make terraform-test
```

### Benefits in CI/CD

- **Fast Feedback**: Tests run quickly without Azure resources
- **No Credentials**: No need for Azure service principals in CI
- **Comprehensive**: Validates logic, inputs, and outputs
- **Reliable**: Consistent results across environments

## Future Enhancements

### Planned Improvements

1. **Extended Test Coverage**
   - Add tests to remaining modules
   - Increase test scenarios for existing modules

2. **Integration Tests**
   - Add tests that verify module interactions
   - Test complete infrastructure scenarios

3. **Performance Tests**
   - Measure test execution time
   - Optimize test performance

4. **Test Reporting**
   - Generate test coverage reports
   - Integrate with CI/CD reporting

### Contributing

When adding new features or modules:

1. **Always Add Tests**: New functionality should include corresponding tests
2. **Follow Patterns**: Use established test patterns and structures
3. **Update Documentation**: Keep this guide and module READMEs updated
4. **Test Locally**: Run tests locally before submitting PRs

## Resources

- [Terraform Testing Documentation](https://developer.hashicorp.com/terraform/language/tests)
- [Terraform Test Framework](https://developer.hashicorp.com/terraform/cli/commands/test)
- [Azure Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
