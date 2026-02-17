# GitHub Workflows Rule

## Documentation Requirement

**When modifying, adding, or removing any workflow file in this directory, you MUST update the workflow documentation.**

### What to update:

1. **File location**: `.github/WORKFLOWS.md`
2. **Update the following information**:
   - Add new workflows to the appropriate section (Testing, Package Preparation, Publishing, etc.)
   - Update workflow descriptions if behavior changes
   - Update trigger conditions (PR paths, schedules, manual triggers)
   - Update Flutter/Dart versions if changed
   - Update the "Schedule Summary" section for scheduled workflows
   - Remove entries for deleted workflows

### Why this matters:

- Helps team members understand the CI/CD pipeline
- Documents which workflows run when and why
- Makes it easier to debug and maintain workflows
- Provides visibility into testing coverage and deployment processes

### Example workflow table entry:


| Workflow name | Workflow file | Runs on | Flutter version | Description |
|--------------|--------------|---------|----------------|-------------|
| test android device | `test-android-device.yaml` | Schedule (every 12h), manual | Flutter 3.32.x (stable) | Runs E2E tests on Firebase Test Lab physical devices. |

### Before submitting PR:

- [ ] Updated `.github/WORKFLOWS.md` with workflow changes
- [ ] Verified all information is accurate (schedules, versions, descriptions)
- [ ] Checked that the table formatting is correct

---

This rule ensures that workflow documentation stays synchronized with actual workflow files.
