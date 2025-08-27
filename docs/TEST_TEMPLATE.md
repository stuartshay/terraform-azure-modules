# Terraform Test Template

This template provides a standardized approach for adding Terraform tests to new modules. Use this as a guide when implementing tests for additional modules.

## Quick Setup Checklist

- [ ] Create `tests/` directory in module
- [ ] Copy and customize test files from template
- [ ] Update Makefile tasks (if needed)
- [ ] Add testing section to module README
- [ ] Test the implementation
- [ ] Update VS Code tasks (if module-specific tasks needed)

## Directory Structure Template

```
modules/{module-name}/
├── main.tf
├── variables.tf
├── outputs.tf
├── versions.tf
├── README.md
└── tests/
    ├── basic.tftest.hcl      # Copy and customize
    ├── validation.tftest.hcl # Copy and customize
    ├── outputs.tftest.hcl    # Copy and customize
    └── setup.tftest.hcl      # Optional, use if needed
```

## Test File Templates

### 1. Basic Functionality Tests Template

**File: `tests/basic.tftest.hcl`**

```hcl
# Basic functionality tests for {module-name} module
# Tests the core functionality of {module description}

# Provider configuration for tests
provider "azurerm" {
  features {}
  skip_provider_registration = true
}

# Test basic resource creation with default values
run "basic_{resource_type}_creation" {
  command = plan

  variables {
    # Add required variables here
    workload            = "test"
    environment         = "dev"
    resource_group_name = "rg-test-dev-001"
    location            = "East US"
  }

  # Verify the resource is created with correct attributes
  assert {
    condition     = {resource_reference}.name == "expected-name-pattern"
    error_message = "Resource name should follow the naming convention"
  }

  assert {
    condition     = {resource_reference}.resource_group_name == "rg-test-dev-001"
    error_message = "Resource group name should match the input variable"
  }

  assert {
    condition     = {resource_reference}.location == "East US"
    error_message = "Location should match the input variable"
  }

  # Add more assertions for default values
}

# Test with custom configuration
run "custom_{resource_type}_configuration" {
  command = plan

  variables {
    workload            = "custom"
    environment         = "prod"
    resource_group_name = "rg-custom-prod-001"
    location            = "West US 2"
    # Add custom variable values
    tags = {
      Environment = "Production"
      Project     = "Custom Test"
    }
  }

  assert {
    condition     = {resource_reference}.name == "expected-custom-name-pattern"
    error_message = "Resource name should follow the naming convention for custom config"
  }

  # Add assertions for custom configuration
  assert {
    condition     = length({resource_reference}.tags) == 2
    error_message = "Tags should be applied when provided"
  }
}

# Add more test scenarios as needed
```

### 2. Validation Tests Template

**File: `tests/validation.tftest.hcl`**

```hcl
# Validation tests for {module-name} module
# Tests input validation rules and error conditions

# Provider configuration for tests
provider "azurerm" {
  features {}
  skip_provider_registration = true
}

# Test invalid parameter validation
run "invalid_{parameter_name}" {
  command = plan

  variables {
    workload            = "test"
    environment         = "dev"
    resource_group_name = "rg-test-dev-001"
    location            = "East US"
    {parameter_name}    = "invalid_value"
  }

  expect_failures = [
    var.{parameter_name},
  ]
}

# Test boundary conditions
run "{parameter_name}_below_minimum" {
  command = plan

  variables {
    workload            = "test"
    environment         = "dev"
    resource_group_name = "rg-test-dev-001"
    location            = "East US"
    {parameter_name}    = 0  # Below minimum
  }

  expect_failures = [
    var.{parameter_name},
  ]
}

run "{parameter_name}_above_maximum" {
  command = plan

  variables {
    workload            = "test"
    environment         = "dev"
    resource_group_name = "rg-test-dev-001"
    location            = "East US"
    {parameter_name}    = 999  # Above maximum
  }

  expect_failures = [
    var.{parameter_name},
  ]
}

# Test valid parameter values
run "valid_{parameter_name}_values" {
  command = plan

  variables {
    workload            = "test"
    environment         = "dev"
    resource_group_name = "rg-test-dev-001"
    location            = "East US"
    {parameter_name}    = "valid_value"
  }

  assert {
    condition     = {resource_reference}.{parameter_name} == "valid_value"
    error_message = "Valid parameter value should be accepted"
  }
}

# Add more validation tests as needed
```

### 3. Output Tests Template

**File: `tests/outputs.tftest.hcl`**

```hcl
# Output validation tests for {module-name} module
# Tests that all outputs are correctly populated and formatted

# Provider configuration for tests
provider "azurerm" {
  features {}
  skip_provider_registration = true
}

# Test all outputs are populated correctly
run "verify_all_outputs" {
  command = plan

  variables {
    workload            = "output-test"
    environment         = "dev"
    resource_group_name = "rg-output-test-dev-001"
    location            = "East US"
    # Add any required variables
  }

  # Test each output
  assert {
    condition     = output.{output_name} == {resource_reference}.{attribute}
    error_message = "{output_name} output should match the resource attribute"
  }

  # Test output format validation
  assert {
    condition     = can(regex("^expected-pattern.*", output.{output_name}))
    error_message = "{output_name} should match expected format"
  }

  # Test outputs are not null or empty
  assert {
    condition     = output.{output_name} != null && output.{output_name} != ""
    error_message = "{output_name} should not be null or empty"
  }
}

# Test outputs with different configurations
run "verify_outputs_with_custom_config" {
  command = plan

  variables {
    workload            = "custom-test"
    environment         = "prod"
    resource_group_name = "rg-custom-test-prod-001"
    location            = "West US 2"
    # Add custom configuration variables
  }

  # Test outputs reflect custom configuration
  assert {
    condition     = output.{output_name} == "expected-custom-value"
    error_message = "{output_name} should reflect custom configuration"
  }
}

# Add more output tests as needed
```

## Makefile Integration

The existing Makefile targets will automatically discover and run tests for new modules. No changes needed unless you want module-specific targets.

### Optional: Add Module-Specific Makefile Targets

```makefile
# Add to Makefile if needed
terraform-test-{module-name}: ## Run Terraform tests for {module-name} module
	@echo "$(YELLOW)Running Terraform tests for {module-name}...$(RESET)"
	@cd $(MODULES_PATH)/{module-name} && terraform test
	@echo "$(GREEN)Terraform tests completed for {module-name}$(RESET)"
```

## VS Code Tasks Integration

### Optional: Add Module-Specific VS Code Tasks

Add to `.vscode/tasks.json` if you want module-specific tasks:

```json
{
  "label": "Terraform: Test {Module Name}",
  "type": "shell",
  "command": "make",
  "args": ["terraform-test-module", "MODULE={module-name}"],
  "group": "test",
  "presentation": {
    "echo": true,
    "reveal": "always",
    "focus": false,
    "panel": "shared",
    "showReuseMessage": true,
    "clear": false
  },
  "problemMatcher": [],
  "detail": "Run Terraform tests for {module-name} module"
}
```

## Module README Template Addition

Add this section to your module's README.md:

```markdown
## Testing

This module includes comprehensive Terraform tests to ensure reliability and correctness. The tests are located in the `tests/` directory and use Terraform's native testing framework.

### Test Structure

```
tests/
├── basic.tftest.hcl      # Basic functionality tests
├── validation.tftest.hcl # Input validation tests
└── outputs.tftest.hcl    # Output validation tests
```

### Running Tests

#### Run All Tests for This Module
```bash
# From the project root
make terraform-test-module MODULE={module-name}

# Or from the module directory
cd modules/{module-name}
terraform test
```

#### Run Specific Test Files
```bash
# Run only basic functionality tests
make terraform-test-file MODULE={module-name} FILE=basic.tftest.hcl

# Run only validation tests
make terraform-test-file MODULE={module-name} FILE=validation.tftest.hcl

# Run only output tests
make terraform-test-file MODULE={module-name} FILE=outputs.tftest.hcl
```

### Test Coverage

#### Basic Functionality Tests (`basic.tftest.hcl`)
- ✅ {Resource} creation with default values
- ✅ Custom configuration testing
- ✅ Tag application and validation
- ✅ Naming convention compliance

#### Validation Tests (`validation.tftest.hcl`)
- ✅ Invalid parameter rejection
- ✅ Boundary condition testing
- ✅ Valid parameter acceptance

#### Output Tests (`outputs.tftest.hcl`)
- ✅ All outputs populated correctly
- ✅ Output format validation
- ✅ Non-null/non-empty verification
```

## Customization Checklist

When using this template for a new module:

### 1. Replace Placeholders
- [ ] `{module-name}` → actual module name
- [ ] `{module description}` → brief module description
- [ ] `{resource_type}` → main resource type (e.g., "storage_account")
- [ ] `{resource_reference}` → Terraform resource reference (e.g., "azurerm_storage_account.main")
- [ ] `{parameter_name}` → actual parameter names
- [ ] `{output_name}` → actual output names
- [ ] `{attribute}` → actual resource attributes

### 2. Customize Variables
- [ ] Update required variables list
- [ ] Add module-specific variables
- [ ] Set appropriate default values for testing
- [ ] Use realistic test data

### 3. Customize Assertions
- [ ] Update naming convention patterns
- [ ] Add module-specific validation rules
- [ ] Test all important resource attributes
- [ ] Verify all outputs

### 4. Add Module-Specific Tests
- [ ] Test different configuration scenarios
- [ ] Test edge cases specific to the module
- [ ] Test integration points if applicable
- [ ] Test error conditions

## Best Practices Reminder

1. **Test Names**: Use descriptive names that explain what is being tested
2. **Test Data**: Use consistent, realistic test data patterns
3. **Assertions**: Write clear, specific error messages
4. **Coverage**: Test all parameters, outputs, and major functionality
5. **Documentation**: Keep test documentation updated

## Example Implementation

See `modules/app-service-plan-function/tests/` for a complete example implementation following this template.
