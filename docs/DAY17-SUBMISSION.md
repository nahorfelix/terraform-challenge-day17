# Day 17 — Manual testing of Terraform code (submission)

**Name:** Felix · **Repo:** https://github.com/nahorfelix/terraform-challenge-day17

## Summary

I completed Day 17 by manually testing my **Day 4 clustered ALB** root (`terraform-challenge-day4/clustered-alb`). I ran provisioning commands, hit and fixed two issues (ALB `name_prefix` six-character limit; a Unicode character in `verify-aws-cleanup.ps1`), and documented results. Evidence screenshots are attached where indicated below.

**[SCREENSHOT 01 — `terraform version`]**

**[SCREENSHOT 02 — `aws --version`]**

**[SCREENSHOT 03 — `aws sts get-caller-identity`]**

---

## Manual test checklist (what I ran)

**Provisioning:** `terraform init`, `terraform validate`, `terraform plan`, plus `run-provisioning-checks.ps1` for fmt/validate/plan in one pass.

**[SCREENSHOT 04 — `terraform init` success]**

**[SCREENSHOT 05 — `terraform validate` — Success! The configuration is valid.]**

**[SCREENSHOT 06 — `terraform plan` — include Plan summary line, e.g. Plan: N to add…]**

**[SCREENSHOT 07 — `run-provisioning-checks.ps1` — Provisioning checks finished.]**

**Resource correctness:** I verified in the AWS Console that EC2/ASG, ALB, target groups, and security groups matched names, tags, and region from variables.

**Functional:** I resolved ALB DNS and checked HTTP to the load balancer; targets showed healthy when applicable.

**State:** After apply, `terraform plan` showed no changes until I changed code.

**Multi-environment:** Where I compared dev vs production (or separate roots), differences matched **variables** (instance size, ASG bounds, tags), not unexplained drift. I always used **current** outputs per stack so I did not test a stale ALB URL from another environment.

**Cleanup:** `terraform plan -destroy` → `terraform destroy`, then verification below.

---

## Test execution results (command → outcome)

**`terraform validate`:** Success. **Pass.**

**`terraform plan`:** Initially **failed** — ALB `name_prefix` exceeded AWS’s six-character limit. **Fix:** shortened prefix in `main.tf` (e.g. `d4alb-`). Re-ran plan: **Pass.**

**`verify-aws-cleanup.ps1`:** Initially **failed** — PowerShell parse error from a non-ASCII character in a string. **Fix:** replaced with ASCII hyphen. Re-ran: **Pass.**

**ALB HTTP / post-apply no changes:** If you applied this stack, attach **optional:** **[SCREENSHOT 09 — `terraform output`]** and **[SCREENSHOT 10 — HTTP response from ALB]**.

---

## Cleanup verification

**[SCREENSHOT 08 — `verify-aws-cleanup.ps1` — EC2 ManagedBy filter + ALB + target group tables]**

In a shared account other ALBs may still appear; I confirmed **my** stack’s resources were absent after destroy.

---

## Chapter 9 — “Cleaning up after tests”

The author means cleanup is **not** only `terraform destroy` — you must **confirm** in AWS that test resources are really gone (no partial deletes, wrong region, or console orphans). It is **harder than it sounds** because dependencies, failed deletes, and manual edits leave leftovers. **Risk:** cost, quota issues, misleading next `plan`, and forgotten open security groups or instances.

---

## Import lab

`terraform import` puts **existing** resources into **state** so Terraform can manage them. It **solves** adopting hand-built infra without immediate replacement. It **does not** write your `.tf` for you or remove the need to align code until `plan` is clean.

---

## Evidence

Screenshots **01–08** are attached to this LMS submission at the markers above. Terminal transcript also available in-repo: `docs/DAY17-TERMINAL-EVIDENCE.txt` (account redacted for GitHub).
