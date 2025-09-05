---
applyTo: '**'
---


# PR #71 Review Memory (Container and App Insights Module)

## Review Date
- 2025-09-05

## Summary
- Reviewing PR #71 for unresolved Copilot comments and general code quality.
- Focus: container-instances module (volumes, volume_mounts, outputs, version constraints, example consistency).

## Key Issues (from Copilot and manual review)
- Volumes and volume_mounts referenced in variables/examples but not implemented in main.tf.
- Examples and outputs reference non-existent volumes output.
- Some example version constraints do not match module requirements.
- TODOs in code about implementing/removing volume support.


## Plan (Updated for Feature Implementation)
1. Research latest AzureRM provider documentation and best practices for implementing volumes and volume_mounts in azurerm_container_group and containers.
2. Review and update variables.tf for volume/volume_mounts definitions as needed.
3. Update main.tf to implement support for volumes and volume_mounts in the container group and containers.
4. Update outputs.tf to expose relevant volume/volume_mounts outputs if needed.
5. Update examples to demonstrate usage of the new feature.
6. Update tests to cover the new functionality.
7. Run all tests to ensure correctness and robustness.
8. Update this memory file after each step.


## Progress Log (Feature Implementation)
- [ ] Step 1: Research AzureRM provider docs for volumes/volume_mounts best practices
- [ ] Step 2: Update variables.tf for volume/volume_mounts definitions
- [ ] Step 3: Update main.tf to implement volumes/volume_mounts
- [ ] Step 4: Update outputs.tf for new outputs if needed
- [ ] Step 5: Update examples to demonstrate feature
- [ ] Step 6: Update tests for new feature
- [ ] Step 7: Run all tests for container-instances module
- [ ] Step 8: Update memory file after each step
