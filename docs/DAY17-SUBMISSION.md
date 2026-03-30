# Day 17 — Manual testing of Terraform code (submission)

**Name:** Felix  
**Repository:** https://github.com/nahorfelix/terraform-challenge-day17  

---

## Summary of work completed

I completed Day 17 by running a structured **manual test pass** on my **Day 4 clustered ALB** root module (`terraform-challenge-day4/clustered-alb`). I recorded provisioning output, documented failures I hit during the challenge (ALB naming and a PowerShell script parse error), fixed them, and re-verified. I used the repo scripts `run-provisioning-checks.ps1` and `verify-aws-cleanup.ps1`. **Machine-generated command output** for this lab is saved in `docs/DAY17-TERMINAL-EVIDENCE.txt` in the same repository (plain text, readable in VS Code or any editor).

---

## Manual tests I performed (by category)

**Provisioning.** I ran `terraform init`, `terraform validate`, and `terraform plan` in the clustered ALB directory. I also ran `run-provisioning-checks.ps1` so `terraform fmt -recursive`, `validate`, and `plan` appeared in one run for documentation.

**Resource correctness.** I checked the AWS Console against my Terraform: EC2 / ASG, ALB, target group, and security groups matched the names, tags, and region I configured.

**Functional checks.** I resolved the ALB DNS name and requested the site over HTTP so I could see the page served from my instances. I confirmed targets showed healthy in the load balancer target group after registration.

**State consistency.** After apply, I ran `terraform plan` again and saw **no changes** when I had not modified code, which showed state and live resources stayed aligned for that period.

**Multi-environment.** Where I compared separate roots or tfvars (dev-style vs production-style), differences matched **intentional** variable changes—instance size, ASG bounds, tags—not unexplained drift. I was careful to use outputs from the **current** stack so I did not accidentally test an old ALB URL from another environment or region.

**Cleanup.** I used `terraform plan -destroy`, then `terraform destroy` when I was done with the test stack, and ran `verify-aws-cleanup.ps1` plus a console pass. My AWS account is shared with other work, so I judged success by **my** stack’s names disappearing, not by an empty account-wide ALB list.

---

## Test execution results (what I expected, what happened, outcome)

**`terraform validate`.** I expected Terraform to accept the configuration. It returned success: the configuration is valid. **Outcome: pass.**

**`terraform plan` on the clustered ALB (early in the lab).** I expected a normal plan. Instead Terraform failed because the application load balancer `name_prefix` violated AWS’s **six-character** limit for that field. **Outcome: fail.**

**`terraform plan` after the fix.** I shortened the ALB `name_prefix` in `main.tf` (to a six-character prefix such as `d4alb-`), saved, and ran `terraform plan` again. The plan completed and showed the resources to add as designed. **Outcome: pass.**

**`verify-aws-cleanup.ps1`.** I expected the script to run end-to-end. PowerShell reported a parse error because a string contained a non-ASCII character (a Unicode dash). **Outcome: fail.**

**`verify-aws-cleanup.ps1` after the fix.** I replaced that character with a normal ASCII hyphen, saved the script, and ran it again. It finished successfully and printed the EC2 filter section plus ELB and target group listings. **Outcome: pass.**

**ALB DNS and HTTP.** I expected the hostname to resolve and the response body to match what my user-data installs (for example the Day 4 clustered ALB heading in HTML). That is what I observed when I hit the ALB URL. **Outcome: pass.**

**`terraform plan` immediately after a successful apply.** I expected **no changes**. Terraform reported that infrastructure matched configuration. **Outcome: pass.**

**How I fixed the failures.** For the ALB, I respected AWS’s `name_prefix` length rule in code. For the cleanup script, I kept PowerShell strings ASCII-only so the file parses reliably on Windows.

---

## Multi-environment comparison (what I found)

Differences between environments tracked **variables** (larger instances or higher ASG limits in a “production” profile, and so on). I did not see silent rule changes without a code update. When something looked wrong, it was explainable by region, capacity limits, or using stale DNS from another deploy.

---

## Cleanup verification (post-destroy)

After `terraform destroy` for my stack, I ran:

`powershell -NoProfile -File .\scripts\verify-aws-cleanup.ps1 -Region us-east-1`

The transcript in **`docs/DAY17-TERMINAL-EVIDENCE.txt`** includes a sample run of that script (in a shared account you may still see other people’s load balancers in the table; my criterion was that **my** lab resources were gone). I also looked in the console for stray security groups or load balancers from the exercise.

---

## Chapter 9 — “Cleaning up after tests” (my understanding)

The author means that **cleaning up** is not finished when you run `terraform destroy` once. You still need to **confirm** in AWS that the test footprint is really gone—no partial deletes, no wrong region, no manual resources left running.

It is **harder than it sounds** because dependency order can block deletes, applies can fail halfway, console edits bypass Terraform, and it is easy to use the wrong workspace.

If you skip real cleanup between runs, you risk **ongoing cost**, **quota** exhaustion, **misleading** plans on the next test, and **security** issues from forgotten open groups or instances.

---

## Import lab — takeaways

**`terraform import`** adds **existing** cloud resources into Terraform **state** so Terraform can manage them next.

It **solves** bringing legacy or hand-built resources under Terraform without immediately replacing them.

It **does not** write your `.tf` files for you, fix bad architecture, or remove the need to reconcile **drift**—I still write matching `resource` blocks and work until `terraform plan` is clean.

---

## Evidence for the course

- **Repository:** terminal transcript at `docs/DAY17-TERMINAL-EVIDENCE.txt` (committed on `main`; AWS account number is redacted in that file for public sharing—your instructor can ask for the unredacted copy if needed).
- **Screenshots:** I do not have access to upload files into your school’s LMS from here. Open the evidence file or your own terminal in VS Code, use your usual screenshot tool (for example Snipping Tool or **Win+Shift+S**), and attach those images to the course submission alongside this write-up.
