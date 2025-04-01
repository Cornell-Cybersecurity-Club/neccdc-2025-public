# Qualifiers Blue Team Terraform

## Usage

### Initializing the Workspace
To initialize a new workspace for a team, use the following commands:

```bash
terraform workspace new $team_number || terraform workspace select $team_number
```

### Applying the Configuration

To apply the Terraform configuration, simply run:
```bash
terraform apply
```
