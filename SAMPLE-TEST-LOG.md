# Sample manual test log (copy this structure for your submission)

## Test: ALB DNS resolves and returns expected response

**Command:**
```text
curl -s http://my-app-alb-123456789.us-east-1.elb.amazonaws.com/
```

**Expected:** HTML containing `Hello` or your app banner (match what user-data serves).

**Actual:**
```text
<h1>Day 4 clustered ALB</h1>
```

**Result:** PASS

---

## Test: terraform plan clean after apply

**Command:**
```text
terraform plan
```

**Expected:** `No changes. Your infrastructure matches the configuration.`

**Actual:** `No changes.`

**Result:** PASS

---

## Test: terraform plan after drift (example failure)

**Command:**
```text
terraform plan
```

**Expected:** No changes.

**Actual:** One change — tag on `aws_security_group.instance` differs from console edit.

**Result:** FAIL  

**Fix:** Reverted manual console change **or** ran `terraform apply` to reconcile Terraform as source of truth.

---

## Test: Post-destroy — no Terraform-tagged instances

**Command:** (PowerShell)
```powershell
.\scripts\verify-aws-cleanup.ps1
```

**Expected:** No instances with `ManagedBy=terraform` (or empty list).

**Actual:** (paste CLI output)

**Result:** PASS / FAIL
