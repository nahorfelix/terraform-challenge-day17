# Day 17 submission — paste into workspace (≤5000 chars)

## 1. Test checklist (by category)

**Prerequisites:** `aws sts get-caller-identity`; set region (`AWS_DEFAULT_REGION` or `-Region`); note Terraform root path.

**Provisioning:** `terraform init` → `validate` → `plan`. Optional: `.\scripts\run-provisioning-checks.ps1 -TerraformDir "<root path>"`.

**Apply:** `terraform apply` if required. Console: EC2, ALB, ASG, SG, TG exist; tags match variables.

**Functional:** Resolve ALB DNS; HTTP to ALB matches user-data; target group shows **healthy** targets.

**State:** Post-apply `terraform plan` = no changes. Optional: one tag change → plan only that → apply → plan clean.

**Multi-environment:** Repeat provisioning + functional + state per root (dev vs prod). Compare instance type, ASG min/max, tags, region.

**Cleanup:** `terraform plan -destroy` → `destroy` → `powershell -NoProfile -File .\scripts\verify-aws-cleanup.ps1 -Region <region>`. Confirm your stack’s instances (ManagedBy tag) and ALB/TG names are gone.

---

## 2. Test execution results

| Command | Expected | Actual | Result |
|---------|----------|--------|--------|
| `terraform validate` | Valid | Success | PASS |
| `terraform plan` (clustered ALB) | No error | Error: ALB `name_prefix` > 6 chars | **FAIL** |
| `terraform plan` (after fix) | Plan OK | Exit 0 | PASS |
| `verify-aws-cleanup.ps1` | Runs | Parse error (Unicode in string) | **FAIL** |
| Same after ASCII fix | Exit 0 | Tables print | PASS |

**Fixes:** (1) AWS ALB `name_prefix` max 6 characters—shorten prefix in `main.tf`. (2) Replace em dash in `Write-Host` with `-`; re-run script.

---

## 3. Multi-environment comparison

Dev vs prod differed by **variables** (smaller instance / lower ASG in dev)—expected. Different **regions** change AMI IDs and ALB DNS—always use **current outputs** per env, not a URL from the other stack. Unexpected: prod failing capacity while dev passes (quotas/AZ), or prod SG stricter → unhealthy targets if ports/paths differ—document if seen.

---

## 4. Cleanup verification (post-destroy)

```powershell
powershell -NoProfile -File ".\scripts\verify-aws-cleanup.ps1" -Region us-east-1
```

**Paste your CLI output below.** After a clean destroy of your test stack: EC2 filter for `ManagedBy=terraform` should be **empty** (for that stack); your ALB/TG **names** must not appear (note: script lists account-wide ALBs—only yours should vanish).

```
=== EC2 instances with tag ManagedBy=terraform ===
(empty)

=== Application Load Balancers ===
[your test ALB absent]

=== Target groups ===
[your test TGs absent]
Done.
```

---

## 5. Chapter 9 — “cleaning up after tests”

**Meaning:** Destroy test infra **and** verify in AWS nothing is left—no orphans or wrong region/workspace.

**Harder than it sounds:** Partial applies, drift, console edits, forgotten workspaces, name collisions.

**Risk of not cleaning:** Ongoing **cost**, **quota** use, **stale** resources confusing the next run, **name conflicts** on re-apply.

---

## 6. Lab takeaways — `terraform import`

**Taught:** Existing resources can be **brought into state** so Terraform manages them next.

**Solves:** “We built it outside Terraform; we want it managed without recreating.”

**Does not solve:** Auto-generating matching config; fixing bad design; drift—you still write correct `resource` blocks and reconcile with `plan`.

---

## 7. Challenges and fixes

| Issue | Cause | Fix |
|-------|--------|-----|
| Plan failed on ALB name | `name_prefix` > 6 chars (AWS limit) | Shorten to ≤6 chars |
| Cleanup script parse error | Non-ASCII character in `Write-Host` | ASCII hyphen only |
| Drift after console edit | Change not in `.tf` | Revert console or apply Terraform |

*Fill Section 4 with your real post-destroy output.*
