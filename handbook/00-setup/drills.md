# Setup break/fix drill

Working directory: `handbook/00-setup`.

1. Confirm `./check.sh` passes.
2. Run `./break.sh`. It deliberately prints no diagnosis.
3. Run `./check.sh` again and use only its failed criterion plus read-only inspection commands to diagnose the changed state.
4. Repair the state without editing `check.sh`.
5. Re-run `./check.sh` until every criterion passes.

Read `answers.md` only after you pass or after 15 minutes stuck.
