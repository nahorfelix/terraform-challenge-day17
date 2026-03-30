# Manual testing checklist — webserver cluster

**Stack under test:** _________________________  
**Region:** _________________________  
**Tester / date:** _________________________

---

## 1. Provisioning verification

| # | Test | Command / action | Pass? | Notes |
|---|------|------------------|-------|-------|
| 1.1 | `terraform init` completes without errors | `terraform init` | ☐ | |
| 1.2 | `terraform validate` passes | `terraform validate` | ☐ | |
| 1.3 | `terraform plan` shows expected count/types of resources | `terraform plan` (review summary) | ☐ | |
| 1.4 | `terraform apply` completes without errors | `terraform apply` | ☐ | |

---

## 2. Resource correctness (AWS Console)

| # | Test | Where to look | Pass? | Notes |
|---|------|---------------|-------|-------|
| 2.1 | All expected resources exist | EC2, ELB, ASG, SG, TG | ☐ | |
| 2.2 | Names, **tags**, **region** match variables | Tags on instances, ALB | ☐ | |
| 2.3 | Security group rules match Terraform only | EC2 → Security groups → Inbound rules | ☐ | No extra / missing rules |

---

## 3. Functional verification

| # | Test | Command / action | Pass? | Notes |
|---|------|------------------|-------|-------|
| 3.1 | ALB DNS name resolves | `nslookup` or browser | ☐ | |
| 3.2 | HTTP returns expected body | `curl -s http://<alb-dns>/` (or Invoke-WebRequest) | ☐ | Paste expected string: _________ |
| 3.3 | Target group shows **healthy** targets | Console → Target groups | ☐ | |
| 3.4 | Stop one instance → ASG replaces it | EC2 → Terminate one instance → wait | ☐ | |

---

## 4. State consistency

| # | Test | Command | Pass? | Notes |
|---|------|---------|-------|-------|
| 4.1 | `terraform plan` shows **No changes** right after apply | `terraform plan` | ☐ | |
| 4.2 | State matches reality (no surprise drift) | `terraform plan` (after console sanity check) | ☐ | |

---

## 5. Regression (small change)

| # | Test | Command | Pass? | Notes |
|---|------|---------|-------|-------|
| 5.1 | Add or change one tag (or description) — plan shows **only** that | Edit `.tf` → `terraform plan` | ☐ | |
| 5.2 | Apply → plan clean again | `terraform apply` → `terraform plan` | ☐ | |

---

## 6. Multi-environment (repeat for each root)

| Environment | Path | Any unexpected difference vs other env? |
|-------------|------|----------------------------------------|
| Dev | | |
| Production | | |

---

## 7. Cleanup

| # | Test | Pass? | Notes |
|---|------|-------|-------|
| 7.1 | `terraform plan -destroy` reviewed | ☐ | |
| 7.2 | `terraform destroy` completed | ☐ | |
| 7.3 | Post-destroy AWS empty / script run | ☐ | See `scripts/verify-aws-cleanup.ps1` |
