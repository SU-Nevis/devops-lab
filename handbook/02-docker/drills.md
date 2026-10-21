# Docker break/fix drill

Working directory: `handbook/02-docker`.

1. Confirm `./check.sh` passes.
2. Run `./break.sh`. It plants exactly one fault and prints no cause.
3. Run `./check.sh` and diagnose the failed criteria with `docker inspect`, `docker network ls`, and other read-only queries. One fault can surface as several FAILs.
4. Repair the observed state without editing the grader.
5. Re-run `./check.sh` until all 10 criteria pass.

Read `answers.md` only after you pass or after 15 minutes stuck.
