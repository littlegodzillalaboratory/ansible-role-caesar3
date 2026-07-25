# AGENTS.md

This repository contains an Ansible role project following a unified standard
for tooling, build automation, and coding conventions. All projects share the
same conventions to keep roles consistent and maintainable.

The key components of the standard include:

- Build automation (Cobbler)
- Role implementation (`tasks/`, `defaults/`, `vars/`, and `meta/`)
- Linting (`ansible-lint` + `yamllint`)
- Testing (Molecule + Pytest/Testinfra)
- Tooling dependencies (`pip-tools` + `requirements.in`)

This document outlines the common conventions that apply across the
Ansible role projects.

## Ansible Version & Dependencies

- **Python Version**: 3.12+
- **Dependency Manager**: pip-tools
- **Lock File**: `requirements.txt` (generated via `pip-compile`)
- **Dependency Specification**: `requirements.in`

### Adding Dependencies

```bash
# Add the dependency to requirements.in
make deps-upgrade                 # Regenerate locked dependencies
make deps                         # Install all deps
```

## Project Structure

```text
project/
├── defaults/               # Default role variables
├── examples/               # Example playbooks and ansible.cfg
├── meta/                   # Galaxy metadata
├── molecule/               # Molecule scenarios and tests
├── tasks/                  # Role task entry points
├── vars/                   # Role variables
├── .ansible-lint           # Ansible lint configuration
├── .github/                # GitHub workflows
├── .gitignore              # Git ignore rules
├── .rtk.json               # RTK configuration
├── .yamllint               # YAML lint configuration
├── AGENTS.md               # Agent instructions (this file)
├── CHANGELOG.md            # Changelog file following Keep a Changelog format
├── LICENSE                 # License file
├── Makefile                # Build automation (Cobbler)
├── README.md               # Project README
├── cobbler.yml             # Cobbler configuration
└── requirements*.txt       # Python tooling dependencies
```

## Build Automation (Cobbler)

This Ansible role project uses **Cobbler** as a standard build automation tool that unifies the build pipeline across all Ansible projects.

### Common Commands

```bash
make ci                # Run lint and test
make lint              # Run ansible-lint and yamllint
make test              # Run Molecule tests
make test-examples     # Run example shell scripts
```

### Release Targets

```bash
make release-major     # Create major release using RTK
make release-minor     # Create minor release using RTK
make release-patch     # Create patch release using RTK
```

### Update Targets

```bash
make update-to-latest  # Update Makefile to the latest Cobbler release
make update-to-main    # Update Makefile to the Cobbler main branch
make update-to-version # Update Makefile to a specific Cobbler version
make update-dotfiles   # Refresh project dotfiles from the generator
make update-partials   # Refresh README partial snippets from the generator
```

## Development Environment

This project is designed to be developed in a consistent environment via Docker image `cliffano/studio`.

You can run the container using: `docker run --rm --workdir /opt/workspace -v /var/run/docker.sock:/var/run/docker.sock -v $PWD:/opt/workspace -i -t cliffano/studio` and then run the build commands inside the container.

Alternatively you can run the Cobbler Makefile targets via Docker container entrypoint, e.g. `docker run --rm --workdir /opt/workspace -v /var/run/docker.sock:/var/run/docker.sock -v $PWD:/opt/workspace -i -t cliffano/studio make ci`.

## Code Style and Linting

Applies to: `tasks/**/*.yml`, `defaults/**/*.yml`, `vars/**/*.yml`, `meta/**/*.yml`, `molecule/**/*.yml`, `examples/**/*.yml`, `examples/**/*.yaml`, `cobbler.yml`

### YAML Linting

All YAML files must pass `yamllint`:

```bash
make lint
```

Guidelines:

- Use two-space indentation in YAML files
- Keep task lists and mappings easy to scan
- Quote strings when they contain Jinja expressions or special characters
- Prefer explicit keys and readable task names

### Ansible Lint

All Ansible content must pass `ansible-lint`:

```bash
make lint
```

Guidelines:

- Fix lint issues at the source rather than suppressing rules
- Keep task names explicit for easier troubleshooting
- Prefer module parameters over shell invocations when possible

### Ansible Conventions

- Use fully qualified collection names such as `ansible.builtin.copy`
- Keep tasks idempotent
- Prefer clear, descriptive `name` fields for every task
- Store role defaults in `defaults/main.yml`
- Store role overrides in `vars/main.yml`
- Keep `meta/main.yml` minimal and accurate

#### Idempotency and Safety

- Avoid tasks that change state on every run
- Use explicit file modes when writing files
- Use `changed_when` only when default behavior is not accurate
- Avoid shell commands for operations already covered by Ansible modules

#### Variables and Templating

- Keep role variables consistently named (for example `ans_*` prefix)
- Put user-overridable values in `defaults/main.yml`
- Reserve `vars/main.yml` for fixed role internals
- Keep Jinja expressions readable and minimal inside YAML values

#### Naming Conventions

- **Role variables**: `snake_case` (for example `ans_transformation`)
- **Task names**: imperative, action-oriented phrases
- **Files**: standard role paths (`main.yml` under each role directory)

### File Organization

Typical generated role layout:

```text
role/
├── defaults/main.yml
├── vars/main.yml
├── tasks/main.yml
├── meta/main.yml
├── molecule/default/
└── examples/
```

Guidelines:

- Keep role behavior in `tasks/main.yml`
- Keep dependency and role metadata in `meta/main.yml`
- Keep realistic usage examples in `examples/`

### Molecule and Examples

- Keep Molecule scenario files deterministic and easy to understand
- Use `converge.yml` for role application and `tests/` for verification logic
- Keep example playbooks simple and representative

#### Molecule Conventions

- Keep scenario setup focused on one role behavior set
- Keep converge playbooks minimal and explicit
- Ensure scenario tests verify observable end state, not internals

### Error Handling

- Prefer module-level validation and clear task naming over hidden failures
- Fail early when required variables are missing
- Keep role outputs predictable across repeated runs

### Validation

- Treat `ansible-lint` and `yamllint` errors as build failures
- When changing role behavior, update both the Molecule scenario and the
  example playbooks if needed
- Keep role README usage aligned with default variable definitions

## Testing

Applies to: `molecule/**/*.py`

- Molecule scenarios live in `molecule/`
- Python verification tests live in `molecule/default/tests/`
- Run tests with `make test`

### Test Structure

- Keep verification tests under `molecule/default/tests/`
- Use `pytest` with the `testinfra` host fixture
- Name tests after the behavior they verify

#### Test Files

```text
molecule/default/tests/
  conftest.py
  test_defaults.py
```

Guidelines:

- Keep tests grouped by role behavior domain
- Keep each test file focused on one logical area

### Test Style

- Assert on observable system state such as files, packages, services, and
  file contents
- Keep tests deterministic and independent of external network access
- Prefer direct assertions over complex helper abstractions

#### Naming Conventions

- **Files**: `test_<behaviour>.py`
- **Functions**: `test_<scenario>_<expected_result>`
- Prefer explicit scenario names (`test_upper_reverse_content_file_created`)

#### Testinfra Pattern

Use host-based assertions for infrastructure state:

```python
content_file = host.file("/tmp/output.txt")
assert content_file.exists
assert content_file.is_file
assert content_file.mode == 0o644
```

### Test Assertions

- Check file existence, type, permissions, and content explicitly
- Verify role side effects exactly as the scenario expects them
- Keep each test focused on one behavior or output artifact

#### Assertion Pattern

- Assert file attributes before asserting file contents
- Use exact string assertions for deterministic generated content
- Keep one primary expected outcome per test when possible

### Pytest Execution

Run the full suite:

```bash
make test
```

For focused troubleshooting, run a specific test file:

```bash
pytest molecule/default/tests/test_defaults.py -q
```

- If the generated project needs a git repository for Molecule, initialize it
  before running the test target

### Scenario Coverage Guidelines

- Cover default variable behavior
- Cover transformed output behavior and generated artifacts
- Cover idempotent second-run behavior when feasible

### CI Integration

Tests are run as part of `make ci`:

```bash
make lint
make test
```

All tests must pass before merging.

### Common Pitfalls

1. Asserting only file existence without verifying contents
2. Using non-deterministic values in expected output assertions
3. Coupling tests to internal implementation details
4. Forgetting that Molecule may require a git repository for proper execution

## Continuous Integration Pipeline

The Makefile (Cobbler) orchestrates standard build targets, with `make ci` running the following steps in sequence:

- clean             # 1. Clean temp files
- lint              # 2. Static analysis (ansible-lint + yamllint)
- test              # 3. Molecule tests

All steps must pass before code is merged. Developers should run `make ci` locally before pushing to ensure the CI pipeline will pass.

After the code is merged, the CI pipeline will run as GitHub CI workflow.

## Git Workflow: Branches, Commits, and Pull Requests

**Note**: These instructions apply to **local machine development only**. When working with GitHub Actions or other CI/CD environments, the git configuration and pakkunbot identity setup is not available. These steps assume you are developing on your local machine where `~/.gitconfig-pakkunbot` exists.

### Creating and Working with Feature Branches

```bash
# Create a feature branch from main
git checkout -b feature/your-feature-name

# Make your code changes, run tests locally
make ci

# Stage ALL changes (critical: never forget this step)
git -c include.path=~/.gitconfig-pakkunbot add -A

# Commit with Pakkun Pakkun identity (pakkunbot) via gitconfig override
git -c include.path=~/.gitconfig-pakkunbot commit -m "Your clear commit message"

# Push to remote
git -c include.path=~/.gitconfig-pakkunbot push
```

### Why `git add -A`

The `-A` flag ensures **all modified and new files** are staged for commit. Without it, changes can be missed (as discovered during development), causing incomplete commits and failed CI runs. Always explicitly run `git add -A` before committing.

### Pakkunbot Identity

The `git -c include.path=~/.gitconfig-pakkunbot` flag uses a separate Git configuration file (`~/.gitconfig-pakkunbot`) containing the Pakkun Pakkun bot identity (email: pakkunbot@users.noreply.github.com). This avoids modifying the repository's git configuration and keeps commits attributed to the bot account rather than your personal account.

**Always include this flag for all git operations** (add, commit, push, pull):

```bash
git -c include.path=~/.gitconfig-pakkunbot add -A
git -c include.path=~/.gitconfig-pakkunbot commit -m "message"
git -c include.path=~/.gitconfig-pakkunbot push
```

### Pull Request Process

1. **Push your feature branch** to the remote using the pakkunbot identity (see above).
2. **Open a pull request** on GitHub targeting `main`.
3. **Ensure all CI checks pass** (lint, tests, coverage, etc.). If any check fails, fix the issue locally and re-run `make ci`, then stage/commit/push again.
4. **Request review** from project maintainers.
5. **Merge** once approved and all checks pass.

### Common Commit Message Patterns

Use clear, imperative commit messages:

- `Fix test patch paths by avoiding command/module name collisions`
- `Add unit tests for blur-plates module`
- `Update README and example script to use categorise-orientation`
- `Remove deprecated blur-plates module and related code`

## GitHub Workflows

This repository defines the following workflows under `.github/workflows/`:

- **CI** (`ci-workflow.yaml`): Trigger: `push`, `pull_request`, and manual `workflow_dispatch`. Purpose: Runs the main quality pipeline (`make deps` then `make ci`) and publishes generated docs to GitHub Pages.

- **Release Major** (`release-major-workflow.yaml`): Trigger: Manual `workflow_dispatch`. Purpose: Creates a major release via `cliffano/release-action` (`release_type: major`).

- **Release Minor** (`release-minor-workflow.yaml`): Trigger: Manual `workflow_dispatch`. Purpose: Creates a minor release via `cliffano/release-action` (`release_type: minor`).

- **Release Patch** (`release-patch-workflow.yaml`): Trigger: Manual `workflow_dispatch`. Purpose: Creates a patch release via `cliffano/release-action` (`release_type: patch`).

- **Upgrade Deps** (`upgrade-deps-workflow.yaml`): Trigger: Manual `workflow_dispatch`. Purpose: Upgrades dependencies, runs validation targets, commits dependency updates, and pushes changes back to the current branch.
