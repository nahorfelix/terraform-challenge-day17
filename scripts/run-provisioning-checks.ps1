# Run fmt, validate, and plan (non-destructive) in a Terraform root.
# Usage:
#   .\scripts\run-provisioning-checks.ps1 -TerraformDir "C:\path\to\terraform-challenge-day4\clustered-alb"

param(
  [Parameter(Mandatory = $true)]
  [string] $TerraformDir
)

$ErrorActionPreference = "Stop"
if (-not (Test-Path $TerraformDir)) {
  throw "Directory not found: $TerraformDir"
}

Push-Location $TerraformDir
try {
  Write-Host "=== terraform fmt -recursive ===" -ForegroundColor Cyan
  terraform fmt -recursive
  Write-Host "`n=== terraform validate ===" -ForegroundColor Cyan
  terraform validate
  Write-Host "`n=== terraform plan (review only) ===" -ForegroundColor Cyan
  terraform plan -input=false
  Write-Host "`nProvisioning checks finished." -ForegroundColor Green
}
finally {
  Pop-Location
}
