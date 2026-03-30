# Day 17 — Manual Testing of Terraform Code

**30-Day Terraform Challenge** · *Terraform: Up & Running* — **Chapter 9** (Manual Tests, Manual Testing Basics, Cleaning Up After Tests)

## Why manual testing first?

Automated tests only work when you **know what “correct” means**. Manual runs teach you which assertions matter (DNS, health checks, SG rules, drift) before you encode them in Terratest or CI. Manual testing also catches **human-intent** issues (wrong tag in console, wrong region) that pure plan output might not flag.

## What’s in this repo

| Item | Purpose |
|------|--------|
| [`CHECKLIST.md`](CHECKLIST.md) | Structured checklist — provisioning, resources, functional, state, regression |
| [`SAMPLE-TEST-LOG.md`](SAMPLE-TEST-LOG.md) | Example of how to log command / expected / actual / result |
| [`docs/MULTI-ENV-TESTING.md`](docs/MULTI-ENV-TESTING.md) | Run the same suite against **dev** and **production** roots |
| [`scripts/verify-aws-cleanup.ps1`](scripts/verify-aws-cleanup.ps1) | Post-`destroy` verification (EC2 + ALB empty or listed) |
| [`scripts/run-provisioning-checks.ps1`](scripts/run-provisioning-checks.ps1) | `terraform fmt` / `validate` / `plan` in a stack directory you choose |

## Suggested stacks to test (your Days 3–16 work)

Use any webserver cluster root; these match the challenge layout:

| Stack | Path (local workspace) |
|-------|-------------------------|
| Small cluster (ALB + ASG) | `terraform-challenge-day4/clustered-alb` |
| Module + dev | `terraform-challenge-day11/live/dev/services/webserver-cluster` |
| Module + production | `terraform-challenge-day11/live/production/services/webserver-cluster` |
| Production-grade (Day 16) | `terraform-challenge-day16/live/dev` |

**Free Tier:** use **dev** first; keep **`terraform destroy`** as the last step of every session.

## Recommended order

1. Fill in **`CHECKLIST.md`** (or copy to your journal).
2. Pick one root module directory → run **`.\scripts\run-provisioning-checks.ps1 -TerraformDir '...'`**.
3. After **`apply`**, run functional checks (browser, or `curl.exe -s http://...`, or `Invoke-WebRequest` in PowerShell).
4. Run **state** checks: `terraform plan` should show **No changes**.
5. Do a **small tag change** → `plan` → `apply` → `plan` again.
6. **`terraform plan -destroy`** (review) → **`terraform destroy`**.
7. Run **`.\scripts\verify-aws-cleanup.ps1`** and confirm in the **AWS Console**.

## Hands-on labs (course)

- Lab 1: State Migration  
- Lab 2: Import Existing Infrastructure  

Complete those in the provider’s lab environment or against a throwaway stack; log results in your test log.

## Cleanup discipline

Never skip **`terraform plan -destroy`** before destroy. After destroy, **always** run the cleanup script and spot-check **EC2**, **ELB**, **Target groups**, **Security groups** for stragglers.

---

*This repository is documentation and scripts — it does not deploy AWS resources by itself.*
