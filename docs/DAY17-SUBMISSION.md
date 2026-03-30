# Day 17 — Manual testing of Terraform code (submission)

**Name:** Felix  
**Repository:** https://github.com/nahorfelix/terraform-challenge-day17  

---

## Summary of work completed

For Day 17 I structured and ran a **manual test pass** against my **Day 4 clustered ALB** Terraform root (`terraform-challenge-day4/clustered-alb`). I documented provisioning commands, validation results, failures I hit and how I fixed them, and post-change verification. I also used the helper scripts in this repo (`run-provisioning-checks.ps1`, `verify-aws-cleanup.ps1`) and captured terminal evidence for my course portfolio.

---

## Manual tests I performed (by category)

**Provisioning.** I ran `terraform init`, `terraform validate`, and `terraform plan` in the clustered ALB directory. I used `run-provisioning-checks.ps1` once to run `terraform fmt -recursive`, `validate`, and `plan` together for a single consolidated log.

**Resource correctness.** I confirmed in the AWS Console (and via CLI where useful) that the resources my stack defines—EC2 / ASG, application load balancer, target group, security groups—aligned with the names, tags, and region I intended from my variables.

**Functional checks.** I resolved the ALB DNS name and checked HTTP to the load balancer so I could see the response my instances serve (user-data / web server). I verified target health in the target group after instances registered.

**State consistency.** After a successful apply, I re-ran `terraform plan` and confirmed Terraform reported **no changes** when I had not edited configuration—so state matched the live infrastructure for that pass.

**Multi-environment.** Where I compared environments (or separate roots), I ran the same style of checks in each place. Differences I saw matched **different variable values** (for example instance size or ASG bounds), not unexplained drift. I noted that using the wrong region or an old ALB URL from another environment would have produced misleading results, so I always took DNS and URLs from the **current** outputs for the stack under test.

**Cleanup.** I reviewed `terraform plan -destroy`, ran `terraform destroy` when I was finished with the test stack, then ran `verify-aws-cleanup.ps1` (and the console) to confirm my test resources were gone. My account also contains other teams’ load balancers; I specifically looked for **my** stack’s names to disappear rather than expecting an empty account.

---

## Test execution results (structured)

| Command / test | What I expected | What actually happened | Result |
|----------------|-----------------|-------------------------|--------|
| `terraform validate` | Configuration valid | Success | **PASS** |
| `terraform plan` (clustered ALB) | Plan completes | Error: `aws_lb` `name_prefix` exceeded AWS **6-character** limit | **FAIL** |
| `terraform plan` after editing `main.tf` | Plan completes | Plan succeeded (resources to add as designed) | **PASS** |
| `verify-aws-cleanup.ps1` | Script executes | PowerShell parse error due to a non-ASCII character in a `Write-Host` string | **FAIL** |
| `verify-aws-cleanup.ps1` after fix | Script executes | Ran to completion; EC2 / ALB / target group queries printed | **PASS** |
| ALB DNS + HTTP | Reachable ALB and expected body | I resolved the ALB hostname and got the HTML my user-data serves | **PASS** |
| `terraform plan` after apply | No drift | Terraform reported no changes once apply had finished | **PASS** |

**How I resolved the failures**

1. **ALB name_prefix:** AWS only allows six characters for `name_prefix` on an ALB. I shortened the prefix in `main.tf` (for example to `d4alb-`), saved the file, and re-ran `terraform plan` successfully.

2. **Cleanup script:** I replaced the problematic Unicode character with a plain ASCII hyphen in `verify-aws-cleanup.ps1`, saved it, and the script parsed and ran correctly afterward.

---

## Multi-environment comparison (what I found)

Between dev-style and production-style settings (or separate tfvars / roots), the **intentional** differences were larger instance types, different ASG minimums and maximums, and matching tags—exactly what the variables were meant to do. I did **not** see one environment “mysteriously” change rules without a code change; when something looked off, it was traceable to region, capacity, or a stale URL if I had reused an old ALB hostname.

---

## Cleanup verification (post-destroy)

After `terraform destroy` completed for my test stack, I ran:

`powershell -NoProfile -File .\scripts\verify-aws-cleanup.ps1 -Region us-east-1`

**Output from my verification command** is included with my course submission (CLI tables showing no remaining instances for my test tag and confirmation that my stack’s ALB/target group names were gone). In a shared account, other load balancers may still appear; I treated removal of **my** stack’s names as the pass criteria.

I also double-checked the AWS Console for any orphaned security groups or load balancers tied to the exercise.

---

## Chapter 9 — “Cleaning up after tests” (my understanding)

The author is saying that **cleaning up** is more than typing `terraform destroy`. It means **proving** in AWS that the test infrastructure is really gone—no half-deleted dependencies, no leftovers in another region, no manual console objects still billing or exposing ports.

He says it is **harder than it sounds** because destroys can fail partway, dependencies block deletes, people edit resources outside Terraform, and it is easy to use the wrong workspace or region.

The **risk of not cleaning up** between runs is ongoing **cost**, **quota** problems, **confusing** the next `plan` or apply, and leaving **security exposure** (for example open security groups or instances nobody remembers).

---

## Import lab — takeaways

The import exercise showed me that **`terraform import`** brings **existing** infrastructure into Terraform **state** so the resource can be managed by code going forward.

**It solves:** adopting resources that were created manually or by another tool without immediately destroying and recreating them.

**It does not solve:** writing the correct `.tf` configuration for you, fixing bad design, or drift by itself—I still have to write matching `resource` blocks and iterate until `terraform plan` is clean.

---

## Evidence submitted

I attached terminal screenshots (toolchain, init/validate/plan, provisioning helper, cleanup verification) and relevant console views to the course portal alongside this write-up.
