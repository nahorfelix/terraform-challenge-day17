<#
.SYNOPSIS
  Runs Day 17 manual-test commands in order with clear SCREENSHOT prompts (press Enter between steps).

.DESCRIPTION
  Paste the FULL command from the comment block at the bottom into VS Code Terminal (PowerShell).

.EXAMPLE
  cd "c:\Users\felix\terraform 30day challenge\terraform-challenge-day17\scripts"
  .\run-day17-screenshot-session.ps1 -Region us-east-1

.EXAMPLE
  Plan-only session (no apply yet - skip HTTP and optional cleanup noise):
  .\run-day17-screenshot-session.ps1 -SkipFunctionalChecks -SkipCleanupVerification
#>

param(
  [string] $TerraformDir = "c:\Users\felix\terraform 30day challenge\terraform-challenge-day4\clustered-alb",
  [string] $Region = "us-east-1",
  [switch] $SkipFunctionalChecks,
  [switch] $SkipCleanupVerification
)

$ErrorActionPreference = "Stop"
$Day17Root = Split-Path $PSScriptRoot -Parent

function Wait-NextStep {
  param([string] $Label)
  Write-Host ""
  Write-Host ">>> SCREENSHOT: $Label <<<" -ForegroundColor Yellow
  Write-Host "(Scroll up if needed so the command output above is visible.)" -ForegroundColor DarkGray
  $null = Read-Host "Press Enter to continue"
}

Write-Host "`n=== Day 17 - screenshot session ===" -ForegroundColor Cyan
Write-Host "Terraform root: $TerraformDir" -ForegroundColor Gray
Write-Host "Region: $Region`n" -ForegroundColor Gray

# --- 1) Toolchain + identity ---
Write-Host "`n--- terraform version ---" -ForegroundColor Green
terraform version
Wait-NextStep "1) Terraform version"

Write-Host "`n--- aws CLI version ---" -ForegroundColor Green
aws --version
Wait-NextStep "2) AWS CLI version"

Write-Host "`n--- AWS caller identity (blur account ID in screenshots if your course requires it) ---" -ForegroundColor Green
aws sts get-caller-identity
Wait-NextStep "3) aws sts get-caller-identity"

if (-not (Test-Path $TerraformDir)) {
  throw "Terraform directory not found: $TerraformDir - edit -TerraformDir in this script or your command line."
}

Push-Location $TerraformDir
try {
  Write-Host "`n--- terraform init ---" -ForegroundColor Green
  terraform init -input=false
  Wait-NextStep "4) terraform init (complete output)"

  Write-Host "`n--- terraform validate ---" -ForegroundColor Green
  terraform validate
  Wait-NextStep "5) terraform validate (Success message)"

  Write-Host "`n--- terraform plan (review only) ---" -ForegroundColor Green
  terraform plan -input=false
  Wait-NextStep "6) terraform plan (summary line + resources, or full scroll)"

  if (-not $SkipFunctionalChecks) {
    Write-Host "`n--- terraform output (needs: terraform apply in this folder first) ---" -ForegroundColor Green
    $prevEap = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    $dns = terraform output -raw alb_dns_name 2>&1
    $ErrorActionPreference = $prevEap
    $dnsOk = ($LASTEXITCODE -eq 0) -and ($dns -is [string]) -and ($dns.Trim().Length -gt 0) -and ($dns -notmatch "Error")
    if ($dnsOk) {
      terraform output -no-color
      Write-Host "`n--- Invoke-WebRequest to ALB (HTTP) ---" -ForegroundColor Green
      $url = "http://$($dns.Trim())/"
      Write-Host "GET $url" -ForegroundColor Gray
      try {
        $r = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 30
        Write-Host "Status $($r.StatusCode)"
        $r.Content.Substring(0, [Math]::Min(500, $r.Content.Length))
      }
      catch {
        Write-Host "Request failed (ALB may still be provisioning or SG blocks you): $_" -ForegroundColor DarkYellow
      }
    }
    else {
      Write-Host "No alb_dns_name output yet - run terraform apply here, then re-run this script for HTTP screenshots." -ForegroundColor DarkYellow
    }
    Wait-NextStep "7) terraform output + optional HTTP response (after apply)"
  }
}
finally {
  Pop-Location
}

$runChecks = Join-Path $Day17Root "scripts\run-provisioning-checks.ps1"
Write-Host "`n--- run-provisioning-checks.ps1 ---" -ForegroundColor Green
& $runChecks -TerraformDir $TerraformDir
Wait-NextStep "8) run-provisioning-checks.ps1 (fmt + validate + plan)"

if (-not $SkipCleanupVerification) {
  $verify = Join-Path $Day17Root "scripts\verify-aws-cleanup.ps1"
  Write-Host "`n--- verify-aws-cleanup.ps1 (after destroy: your stack gone; shared accounts may list other ALBs) ---" -ForegroundColor Green
  & $verify -Region $Region
  Wait-NextStep "9) verify-aws-cleanup.ps1 (EC2 tag filter + ALB/TG tables)"
}

Write-Host "`n=== Screenshot session finished ===" -ForegroundColor Cyan
Write-Host "Extra: for 'No changes' screenshot, run: cd '$TerraformDir'; terraform plan" -ForegroundColor DarkGray

# FULL COMMAND FOR VS CODE (copy everything below this line into Terminal):
#
# cd "c:\Users\felix\terraform 30day challenge\terraform-challenge-day17\scripts"; .\run-day17-screenshot-session.ps1 -Region us-east-1
#
# Plan-only (no apply yet):
# cd "c:\Users\felix\terraform 30day challenge\terraform-challenge-day17\scripts"; .\run-day17-screenshot-session.ps1 -Region us-east-1 -SkipFunctionalChecks -SkipCleanupVerification
