# CI/CD for Industrial Network Template

This repository uses GitHub Actions to ensure quality, security, and reproducibility for all Docker-based industrial network simulations.

## Multi-Network Docker Compose CI

**File:** `.github/workflows/docker-network-ci.yml`

This workflow automatically:

- **Always tests the main `network/` Compose stack** on every push, pull request, or manual run.
- **Conditionally tests other network stacks** (`enterprise/`, `logging/`, `industrial/`, `idmz/`) only if changes are detected in their folders.
- **Auto-creates required external Docker networks** with the correct subnets, so that static IP assignments and inter-network links work in CI.
- **Skips problematic services (e.g., PLC simulators)** in CI to prevent resource-intensive or hardware-dependent components from blocking builds (by temporarily overriding their `entrypoint` or scaling them to zero).
- **Validates, builds, launches, and smoke-tests all services**—and fails fast if any container exits or crashes.

**Key Features:**
- Uses a custom composite action to detect all `external: true` networks and create them as needed.
- Easily extensible: add new network folders and update only one line per job.
- Each job prints which network is being tested and why.

## Docker Lint & Security Scan

**File:** `.github/workflows/docker-lint-security.yml`

This workflow enforces Docker best practices and performs a security scan on every push, pull request, or manual run.

**What it does:**
- **Lints all Dockerfiles** with [Hadolint](https://github.com/hadolint/hadolint), a best-practices linter for Dockerfile syntax and usage.
- **Validates all `docker-compose*.yml` files** with `docker-compose config`, ensuring that YAML is correct and all referenced files exist.
- **Runs [Checkov](https://github.com/bridgecrewio/checkov)** to scan Dockerfiles and Compose files for common security and compliance risks.
- **Uploads a SARIF security report** to GitHub Security tab, allowing you to track, triage, and resolve findings.

**Key Features:**
- Fast feedback on code and infrastructure-as-code quality.
- Works with monorepos and multi-folder setups (finds all Compose and Dockerfiles recursively).
- Lint failures don’t block the build, but all results are visible in the Actions logs.

**How to extend:**
- Add more security scanners (e.g., Trivy, Dockle) as needed.
- Tune `hadolint` and `checkov` configuration to fit your organization’s security policies.


## Running the Workflows

- **Automatic triggers:** Both workflows run on all pushes, pull requests to `main`, and can be started manually.
- **Security findings:** Any issues detected by Checkov will appear in the repository’s Security > Code scanning alerts.
- **Status reporting:** See the Actions tab for job history and logs. Each workflow prints clear logs for every checked folder.