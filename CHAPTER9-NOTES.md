# Chapter 9 — short notes (Manual testing)

## Why manual tests before automation?

- You learn **what** to assert (DNS, HTTP status, health, ASG behavior).
- Some issues need **eyes on the console** (wrong subnet, accidental rule).
- Cleanup mistakes cost **real money** — manual discipline builds the habit **`plan -destroy` → `destroy` → verify**.

## What manual tests cover that automation can miss

- Subjective **UX** (wrong page content, SSL mixed content).
- **Console-only** misconfigurations until next plan.
- **Quotas** and account-level limits (API errors on apply).

## Cleaning up after tests

- Always **`terraform plan -destroy`** first.
- **`terraform destroy`**, then **AWS Console** + **`verify-aws-cleanup.ps1`**.
- If destroy fails mid-way, fix state or delete orphans, then re-run destroy.
