# Day 17 — Manual testing write-up (Felix)

This note is my own workflow for the **30-day Terraform challenge**, not a copy of someone else’s submission. I use a **checklist** so I know *what* to prove (provision, behavior, state, teardown) before I trust automation later.

---

## Why bother with a checklist?

Manual testing is where you decide what “healthy” means: which command proves the ALB exists, which proves traffic works, and what “clean” means after `destroy`. If you skip that design step, automated tests just encode confusion faster.

---

## My test checklist (by category)

| Category | What I verify |
|----------|----------------|
| **Provisioning** | `terraform init` → `validate` → `plan` with no surprises; then `apply` when I want real AWS objects. |
| **AWS reality** | In the console: EC2, ALB, ASG, SG, TG line up with names, tags, and region from variables. |
| **Behavior** | ALB DNS resolves; HTTP returns the page my user-data serves; targets show **healthy** in the TG. |
| **State** | Right after apply, `terraform plan` shows **no changes** (until I intentionally change code). |
| **Multi-env** | If I have separate roots (e.g. dev vs prod), I run the same steps in each and compare: instance size, ASG bounds, tags — differences should match tfvars, not random drift. |
| **Cleanup** | `plan -destroy` → `destroy` → AWS CLI (or `verify-aws-cleanup.ps1`) to prove **my** test resources are gone. |

---

## Execution log (command → expected → actual → result)

| Step | Expected | Actual | Result |
|------|----------|--------|--------|
| `terraform validate` | Valid config | Valid | PASS |
| `terraform plan` (Day 4 clustered ALB) | Clean plan | Error: ALB `name_prefix` over 6 characters | **FAIL** |
| After shortening `name_prefix` in `main.tf` | Plan runs | Plan succeeds | PASS |
| `verify-aws-cleanup.ps1` | Script runs | Parse error (bad character in a string) | **FAIL** |
| After fixing the string to plain ASCII | Exit 0 | Tables print | PASS |

**Root causes:** (1) AWS enforces a **six-character** limit on ALB `name_prefix`. (2) A Unicode dash in PowerShell broke parsing — stick to ASCII in scripts.

Fill in from your own runs: ALB HTTP check, SG review, and **No changes** after apply.

---

## Dev vs production (when both exist)

I expect **different variable values** (bigger instances in prod, different min/max ASG). What I watch for: **unexpected** differences — e.g. prod plan failing on instance capacity while dev passes, or health checks failing in one region because of wrong port/path. Those get a line in the log, not a silent “it works somewhere.”

---

## Cleanup verification

After destroy, I run the CLI checks bundled in this repo (`scripts\verify-aws-cleanup.ps1`) and paste the output. In a **shared** AWS account, you may still see **other** load balancers; the important part is that **your** stack’s names are gone. I still glance at the console for stragglers.

---

## Chapter 9 — “Cleaning up after tests”

In my own words: **cleanup** is not “I ran `terraform destroy` once.” It is **confirming** in AWS that what you created for the test is actually gone — including when destroy is partial or something was created outside Terraform.

It is **harder than it sounds** because dependencies fail in order, people edit things in the console, and you might use the wrong region or workspace.

If you do not clean up between runs, you pay for leftovers, burn **quotas**, get **confusing** plans next time, and can leave **security groups or instances** exposed.

---

## Import lab — what I took away

`terraform import` puts an **existing** resource into **state** so Terraform can manage it. It **does not** invent your `.tf` code — you still write matching resources and reconcile until `plan` is clean. It does **not** fix bad architecture by itself.

---

## Repo

**GitHub:** https://github.com/nahorfelix/terraform-challenge-day17  

**Medium / blog:** *(add your link when you publish)*

---

## Screenshot helper

Run `scripts\run-day17-screenshot-session.ps1` from this repo (see comments in that file for the full one-liner). It pauses between steps so you can capture each screen in order.
