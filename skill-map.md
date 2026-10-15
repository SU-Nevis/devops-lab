# DevOps skill map and lab workflow

## Recommended order

Keep the proposed order: **Linux and shell → Docker → Git and GitHub Actions → Terraform → Kubernetes → observability**. Each step supplies concepts used by the next one: shell skills make automation understandable; containers make CI artifacts concrete; CI establishes repeatability; Terraform introduces declarative infrastructure; Kubernetes builds on containers and declarative state; observability is most useful after there is a distributed system to measure. Learn basic Git alongside Linux from day one, but place the dedicated CI/CD lab after Docker so the pipeline has a real artifact to build and test.

## 1. Linux and shell

- **Why it matters:** Most DevOps tooling runs on Linux, and shell commands are the glue between build, deployment, diagnosis, and teardown steps.
- **What the lab proves:** The learner can inspect processes and ports, manage files and permissions, write a strict-mode script, handle exit codes, and make setup/teardown repeatable.
- **Interview questions:** How do permissions and ownership work? How would you find the process listening on a port? What are stdout, stderr, pipes, signals, and shell exit codes? Why use `set -eu`?

## 2. Docker

- **Why it matters:** Containers package an application and its runtime into a consistent, portable unit and are the foundation for modern CI and Kubernetes work.
- **What the lab proves:** The learner can build or select a pinned image, run a least-complex service, add a health check, expose a port, verify behaviour, and remove containers, networks, and volumes.
- **Interview questions:** How are images different from containers? What makes an image layer cacheable? What is the difference between `EXPOSE` and a published port? How do health checks, bind mounts, volumes, and container networks work?

## 3. Git and GitHub Actions (CI/CD)

- **Why it matters:** Git makes infrastructure changes reviewable, while CI/CD applies the same build, test, security, and deployment rules to every change.
- **What the lab proves:** The learner can use a branch and pull-request workflow and create a pipeline that lints, builds, verifies, and cleans up a container lab without storing credentials in the repository.
- **Interview questions:** When would you rebase versus merge? How do workflow triggers, jobs, runners, artifacts, caches, environments, and protected secrets differ? How would you prevent an untrusted pull request from accessing credentials?

## 4. Terraform

- **Why it matters:** Infrastructure as code makes cloud resources declarative, reviewable, reproducible, and explicitly destroyable.
- **What the lab proves:** The learner can format and validate configuration, explain a plan, create resources from variables, manage state safely, verify the deployed result, and run `terraform destroy` plus a provider query proving nothing billable remains.
- **Interview questions:** What is stored in state, and why protect it? How do plan and apply differ? What causes resource replacement? How do modules, providers, variables, outputs, drift, imports, and remote state work?

## 5. Kubernetes

- **Why it matters:** Kubernetes schedules and reconciles containerized workloads and is common in platforms that need scaling, rollout control, and self-healing.
- **What the lab proves:** The learner can deploy an image, use labels and Services correctly, configure readiness/liveness probes, inspect events and logs, perform a rollout, verify traffic, and delete the namespace or cluster completely.
- **Interview questions:** How do Pods, Deployments, ReplicaSets, and Services relate? How do readiness and liveness probes differ? What happens during a rolling update? How do requests/limits, ConfigMaps, Secrets, ingress, and namespaces work?

## 6. Observability (Prometheus and Grafana)

- **Why it matters:** Operators need metrics and visual context to detect failures, diagnose causes, and confirm that a change improved the system.
- **What the lab proves:** The learner can expose and scrape a useful metric, query it with PromQL, build a reproducible dashboard, define an actionable alert, create a failure, observe it, and remove the complete stack afterward.
- **Interview questions:** How do metrics, logs, and traces differ? What are labels and time series? What causes high cardinality? How do counters, gauges, histograms, scrape intervals, PromQL rates, alert thresholds, and SLOs work?

## How to use the template

1. Copy `lab-template/` to a new, clearly named lab directory.
2. Replace the goal, Mermaid diagram, learning notes, Compose service, and verification assertion with lab-specific content.
3. Keep safe defaults in `.env.example`; put local overrides in ignored `.env`; never store credentials in either file.
4. Run `make up`, `make verify`, and `make down` in that order. Save the output as portfolio evidence.
5. Treat teardown as a test. For a cloud lab, add deterministic destroy commands and a provider/API absence query to `scripts/down.sh`; `make down` must exit non-zero if any resource remains.
6. Read the three bullets in `speaking-notes.md` aloud, then replace them with a short explanation of the goal, request flow, verification, and teardown.

## Included example

`example-static-page/` runs one pinned nginx container, mounts a static page read-only, checks readiness, verifies the returned page text, and checks after teardown that no container or Compose network carrying the lab project label remains. It creates no cloud resources, so it cannot leave a billable resource behind.
