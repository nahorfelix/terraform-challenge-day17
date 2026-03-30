# Post-destroy verification — should return EMPTY or no matching resources.
# Requires AWS CLI configured (same profile/region as your tests).
# Usage: .\scripts\verify-aws-cleanup.ps1
# Optional: -Region us-east-1

param(
  [string] $Region = $env:AWS_DEFAULT_REGION,
  [string] $ManagedByTagValue = "terraform"
)

$ErrorActionPreference = "Continue"
if (-not $Region) { $Region = "us-east-1" }

Write-Host "`n=== EC2 instances with tag ManagedBy=$ManagedByTagValue (should be empty after clean destroy) ===" -ForegroundColor Cyan
aws ec2 describe-instances `
  --region $Region `
  --filters "Name=tag:ManagedBy,Values=$ManagedByTagValue" "Name=instance-state-name,Values=running,pending,stopping,stopped" `
  --query "Reservations[*].Instances[*].[InstanceId,State.Name,Tags[?Key=='Name'].Value|[0]]" `
  --output table

Write-Host "`n=== Application Load Balancers (all in region — confirm yours are gone) ===" -ForegroundColor Cyan
aws elbv2 describe-load-balancers --region $Region --query "LoadBalancers[*].[LoadBalancerName,DNSName]" --output table

Write-Host "`n=== Target groups (spot-check names from your stack) ===" -ForegroundColor Cyan
aws elbv2 describe-target-groups --region $Region --query "TargetGroups[*].TargetGroupName" --output table

Write-Host "`nDone. If destroy worked, your test stack's ALB/TG/ASG/EC2 should be absent." -ForegroundColor Green
