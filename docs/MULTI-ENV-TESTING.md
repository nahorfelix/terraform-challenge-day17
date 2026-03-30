# Testing multiple environments

Run the **same** [`CHECKLIST.md`](../CHECKLIST.md) against **each** root module independently.

## Example: Day 11 layout

```text
terraform-challenge-day11/live/dev/services/webserver-cluster
terraform-challenge-day11/live/production/services/webserver-cluster
```

In each directory:

1. `terraform init`
2. `terraform workspace show` (if using workspaces) — optional
3. Complete provisioning + functional + state sections of the checklist
4. Compare: **instance type**, **min/max ASG**, **tags**, **region** — differences should match **variables**, not surprises.

## Common surprises

- **Production** uses larger `instance_type` → different AZ capacity or quota errors.
- **Different regions** → AMI IDs and endpoint hostnames change — `curl` must use the **current** `alb_dns_name` output.
- **Stricter SG** in production → health checks fail if paths/ports differ.

Document any unexpected difference in your test log.
