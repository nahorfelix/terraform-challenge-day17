# Day 17 — VS Code terminal: commands one by one + what to screenshot

Open **Terminal → New Terminal** in VS Code. Use **PowerShell** (not CMD). Run **only one block at a time**. After each block, take the listed screenshot, save it with the suggested name, then run the next block.

**Tip:** After each command finishes, scroll so the **command and its full output** are visible before you capture (**Win+Shift+S** or Snipping Tool).

---

## Step 1 — Terraform version

**Paste and run:**

```powershell
terraform version
```

**Screenshot:** Label it **01-terraform-version** (shows Terraform version and platform).

---

## Step 2 — AWS CLI version

**Paste and run:**

```powershell
aws --version
```

**Screenshot:** **02-aws-cli-version**

---

## Step 3 — Who am I in AWS (optional blur of account ID for public use)**

**Paste and run:**

```powershell
aws sts get-caller-identity
```

**Screenshot:** **03-sts-get-caller-identity**

---

## Step 4 — Go to Day 4 clustered ALB and init

**Paste and run:**

```powershell
cd "c:\Users\felix\terraform 30day challenge\terraform-challenge-day4\clustered-alb"
terraform init -input=false
```

**Screenshot:** **04-terraform-init** (show success message at the end).

---

## Step 5 — Validate

**Paste and run:**

```powershell
terraform validate
```

**Screenshot:** **05-terraform-validate** (must show `Success! The configuration is valid.`).

---

## Step 6 — Plan (review only)

**Paste and run:**

```powershell
terraform plan -input=false
```

**Screenshot:** **06-terraform-plan** (at minimum include the summary line, e.g. `Plan: X to add...`; scroll to capture it if the plan is long).

---

## Step 7 — Day 17 provisioning helper (fmt + validate + plan)

**Paste and run:**

```powershell
cd "c:\Users\felix\terraform 30day challenge\terraform-challenge-day17\scripts"
.\run-provisioning-checks.ps1 -TerraformDir "c:\Users\felix\terraform 30day challenge\terraform-challenge-day4\clustered-alb"
```

**Screenshot:** **07-run-provisioning-checks** (show `Provisioning checks finished.`).

---

## Step 8 — Cleanup verification script

**Paste and run:**

```powershell
cd "c:\Users\felix\terraform 30day challenge\terraform-challenge-day17\scripts"
powershell -NoProfile -File ".\verify-aws-cleanup.ps1" -Region us-east-1
```

**Screenshot:** **08-verify-aws-cleanup** (EC2 section + ALB table + TG table, or as much as fits).  
**Note:** If you have **not** destroyed your Day 4 stack yet, this still proves the script runs; say in your write-up that full cleanup was verified after destroy.

---

## Optional Step 9 — Only if you already ran `terraform apply` on this stack

**Paste and run:**

```powershell
cd "c:\Users\felix\terraform 30day challenge\terraform-challenge-day4\clustered-alb"
terraform output -no-color
```

**Screenshot:** **09-terraform-output**

Then:

```powershell
$dns = terraform output -raw alb_dns_name
Invoke-WebRequest -Uri "http://$dns/" -UseBasicParsing -TimeoutSec 30 | Select-Object StatusCode, @{n='ContentPreview';e={ $_.Content.Substring(0, [Math]::Min(400, $_.Content.Length)) }}
```

**Screenshot:** **10-alb-http-response**

---

## Done

You should have **01** through **08** (and optionally **09–10**) as image files to attach to your LMS next to `DAY17-SUBMISSION.md`.
