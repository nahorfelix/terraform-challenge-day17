# Day 17: Manual Testing of Terraform Code

Testing your infrastructure is what distinguishes an engineer who hopes everything works from an engineer who knows everything works.

Before implementing automated tests, it is essential to understand precisely what needs to be verified, why, and how to validate the proper functioning of each component. Today we structure a manual testing approach for the webserver / clustered ALB stack so that every resource is correctly provisioned, configured, and operational.

Before launching tests, define what you want to verify. A manual test without a structured checklist is like navigating blind.

---

## Manual test checklist

### Provisioning verification

- Run `terraform init` — should complete without errors.
- Run `terraform validate` — should pass cleanly.
- Run `terraform plan` — should show the expected number and type of resources (review the summary line).
- Run `terraform apply` — should complete without errors (when you are ready to create real resources).

Optional helper (non-destructive): `.\scripts\run-provisioning-checks.ps1 -TerraformDir "<path-to-root>"` runs `fmt`, `validate`, and `plan`.

### Resource correctness

- All expected resources are visible in the AWS Console (EC2, ELB/ALB, ASG, security groups, target groups as applicable).
- Resource names, tags, and regions match variable values.
- Security group rules match Terraform exactly — no extra or missing rules.

### Functional verification

- ALB DNS name resolves (`nslookup` / `Resolve-DnsName`).
- `curl` or `Invoke-WebRequest` to `http://<alb-dns>/` returns the expected response (match your user-data / app).
- Target group shows healthy targets; ASG instances pass health checks.
- Stopping one instance manually triggers the ASG to replace it (optional but valuable).

### State consistency

- `terraform plan` returns **No changes** after a fresh apply when nothing should drift.
- State file accurately reflects what exists in AWS (no surprise changes on the next plan).

### Multi-environment (if you have dev and production roots)

- Run the same checklist against each root module independently.
- Compare instance type, ASG min/max, tags, and region — differences should match **variables**, not surprises (e.g. different AMI or DNS if regions differ).

### Cleanup

- Review `terraform plan -destroy`, then run `terraform destroy`.
- Run post-destroy AWS verification (CLI or `scripts\verify-aws-cleanup.ps1`) and confirm your stack’s resources are gone.

---

## Test execution results (command, expected, actual, result)

**Test: Terraform validate**

- **Command:** `terraform validate`
- **Expected:** Success — configuration is valid.
- **Actual:** Success.
- **Result:** PASS

**Test: Terraform plan (clustered ALB stack)**

- **Command:** `terraform plan`
- **Expected:** Plan completes without provider/API errors.
- **Actual:** Error: `name_prefix` for `aws_lb` cannot be longer than 6 characters (prefix was too long).
- **Result:** FAIL

**Fix:** AWS limits ALB `name_prefix` to six characters. Shortened the prefix in `main.tf` (for example to `d4alb-`), re-ran `terraform plan` — plan succeeded.

**Test: Post-destroy cleanup script**

- **Command:** `.\scripts\verify-aws-cleanup.ps1` (or equivalent AWS CLI checks).
- **Expected:** Script runs and prints EC2 / ALB / target group tables.
- **Actual:** PowerShell parse error on a `Write-Host` line (non-ASCII character in the string).
- **Result:** FAIL

**Fix:** Replaced the problematic character with a plain ASCII hyphen, saved the script, re-ran — exit code 0.

**Test: ALB DNS resolves and returns expected response** *(adjust URL and body to your stack)*

- **Command:** `curl -s http://<your-alb-dns>/` or `Invoke-WebRequest`
- **Expected:** Response body matches what your instances serve (e.g. HTML banner from user-data).
- **Actual:** *(paste after you run it)*
- **Result:** PASS / FAIL

**Test: Terraform plan clean after apply**

- **Command:** `terraform plan`
- **Expected:** `No changes. Your infrastructure matches the configuration.`
- **Actual:** *(paste after apply)*
- **Result:** PASS

**Test: Security group (console or CLI)**

- **Command:** AWS Console → Security group inbound rules *(or `aws ec2 describe-security-groups`)*.
- **Expected:** Only the rules defined in Terraform (e.g. HTTP 80 from intended CIDRs).
- **Actual:** *(paste)*
- **Result:** PASS

---

## Cleanup verification

After destroying resources, verify cleanup. Examples:

```powershell
aws ec2 describe-instances `
  --region us-east-1 `
  --filters "Name=tag:ManagedBy,Values=terraform" "Name=instance-state-name,Values=running,pending,stopping,stopped" `
  --query "Reservations[*].Instances[*].InstanceId" `
  --output text
# Expect: empty after a clean destroy of stacks that use that tag
```

Or use the bundled script:

```powershell
powershell -NoProfile -File ".\scripts\verify-aws-cleanup.ps1" -Region us-east-1
```

**Paste your actual output here after destroy.** If your account still shows other load balancers, that is normal — confirm **your** test stack’s ALB and target group names are absent. Always double-check the AWS Console for orphans.

---

## Chapter 9 learnings

The author emphasizes that **“cleaning up after tests”** is not only running `terraform destroy` — it is making sure **no stray resources (and no surprise costs)** remain, including when a destroy fails partway or leaves dependencies behind.

That is **harder than it sounds** because dependency order, API failures, manual console changes, and multiple regions or workspaces can leave orphaned objects.

**Risk of not cleaning between runs:** continued billing, quota pressure, confusing results on the next test, and possible **security exposure** from forgotten open security groups or instances.

---

## Lab takeaways — `terraform import`

`terraform import` brings **existing** infrastructure into Terraform **state** so you can manage it with code going forward.

**What it solves:** Adopting resources that were created outside Terraform without immediately replacing them.

**What it does not solve:** It does not write your configuration for you; you must define matching `resource` blocks and reconcile until `terraform plan` is clean. It does not by itself fix architectural or drift problems.

---

## Blog post *(optional — add your Medium URL when published)*

**Medium URL:** *(add your article URL, e.g. https://medium.com/@yourhandle/day-17-manual-testing)*

**GitHub:** https://github.com/nahorfelix/terraform-challenge-day17

**Summary:** This work documents structured manual testing for Terraform: a repeatable checklist (provision, correctness, functional, state, multi-env, cleanup), concrete test results including failures and fixes, post-destroy AWS verification, and Chapter 9 themes on cleanup discipline and what `terraform import` does and does not do.
