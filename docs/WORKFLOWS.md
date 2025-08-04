# CI/CD for Industrial Network Template

This repository uses GitHub Actions to provide **automated validation, security, and reproducibility** for all Docker-based industrial network simulations.


## Multi-Network Docker Compose CI

**File:** `.github/workflows/docker-network-ci.yml`

This workflow:

- **Always tests the main `network/` Compose stack** on every push, pull request, or manual run.
- **Conditionally tests other network stacks** (`enterprise/`, `logging/`, `industrial/`, `idmz/`) if changes are detected in those folders.
- **Auto-creates all required external Docker networks with the correct subnets** *before* any containers are started, using a composite action that parses `network/docker-compose.yml` and generates a mapping file (`subnets.txt`) via Bash.  
    - **No more manual network setup:** All stacks reference networks using `external: true`, and all static IP assignments are guaranteed to work.
- **Skips problematic services (e.g., PLC simulators, VPN, or HMI)** in CI to prevent hardware-dependent, resource-intensive, or kernel-dependent containers from blocking builds. This is achieved by using a CI-only override file to disable or scale down specific services.
- **Validates, builds, launches, and smoke-tests all services:** If any container exits or fails, the workflow fails fast, and logs are printed.
- **Uses `docker compose build --parallel` and up/down to maximize speed and cleanliness.**

**Key Features:**

- **Custom network setup action:**  
  Uses a Bash script (`get_subnets.sh`) to extract all subnets from `network/docker-compose.yml` and a Python helper to pre-create all `external: true` Docker networks using these subnets, ensuring no IP overlap or startup errors.
- **CI-friendly VPN/PLC setup:**  
  For network services like VPN (WireGuard, OpenVPN) that require host kernel modules or external volumes, the workflow uses CI overrides to skip or “pause” these services during automated runs.
- **Modular and extensible:**  
  Adding a new network stack is as simple as adding another job that references the correct directory and network(s).
- **Clear change detection:**  
  Each job prints which folder triggered the check (e.g., "Testing IDMZ network because of changes in idmz/") for fast diagnosis.


## Docker Lint & Security Scan

**File:** `.github/workflows/docker-lint-security.yml`

This workflow provides **quality and security enforcement** for your Docker infrastructure:

- **Lints all Dockerfiles** with [Hadolint](https://github.com/hadolint/hadolint) for best-practices and syntax issues.
- **Validates all Compose files** (`docker-compose*.yml`) using `docker-compose config`, ensuring that YAML is correct and services are well-formed.
- **Runs [Checkov](https://github.com/bridgecrewio/checkov)** to scan Dockerfiles and Compose files for common security/compliance issues.
- **Uploads a SARIF report** to GitHub’s Security tab, enabling code scanning alerts for any discovered issues.

**Key Features:**

- **Monorepo-friendly:** Recursively finds all Compose and Dockerfiles across folders.
- **Non-blocking lint:** Hadolint errors/warnings do **not** fail the build, but are visible in workflow logs.
- **Security report integration:** Track, triage, and resolve findings in the GitHub Security tab.

**Possibilities to add more:**

- Add additional scanners (e.g., [Trivy](https://github.com/aquasecurity/trivy), [Dockle](https://github.com/goodwithtech/dockle)) as needed.
- Tune `hadolint` and `checkov` configuration files for your policies.


## Workflow Implementation Details

### Network Creation

- **Source of truth:** All Docker network subnets are defined in `network/docker-compose.yml`.
- **Automated mapping:** The action’s Bash script parses this file and generates `subnets.txt` mapping network names to subnets.
- **Pre-creation:** Python reads this file and runs `docker network create --subnet` for every required network before Compose brings up services.


## Running the Workflows

- **Automatic triggers:** All workflows run on pushes, pull requests, and manual dispatches (`workflow_dispatch`).
- **Status reporting:** See the Actions tab for job logs/history. Each job prints clear, actionable output.
- **Security findings:** Appear in GitHub’s Security tab for easy remediation.
- **Manual runs:** You can always start the workflow from the GitHub Actions UI for branch or tag testing.


## Notes

- **When adding new network folders:**  
  - Update `network/docker-compose.yml` with the new network and subnet.
  - Regenerate `subnets.txt` by running the workflow (or manually via `get_subnets.sh`).
  - Reference the new network as `external: true` in your new compose stack.
- **For VPN or PLC containers:**  
  - If needed for CI, add a CI override file to disable or scale them to zero during builds.
  - For real deployments, make sure to properly initialize volumes or bake configs as needed.


Let me know if you want code snippets for any part of the workflow, or a section about how to test locally!
