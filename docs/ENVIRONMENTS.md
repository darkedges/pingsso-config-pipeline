# Managing Multiple Environments

This guide covers strategies for managing different environments (dev, staging, production) with this PingSSO configuration pipeline.

## Strategy 1: GitHub Environments (Recommended)

Use GitHub's built-in [Environments feature](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment) to manage different PingFederate instances.

### Setup GitHub Environments

1. **Create GitHub Environments**

   In your repository: Settings → Environments → New environment

   Create: `development`, `staging`, `production`

2. **Configure Environment-Specific Secrets**

   For each environment, set these secrets:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `PF_ADMIN_USERNAME`
   - `PF_ADMIN_PASSWORD`

3. **Configure Environment-Specific Variables**

   For each environment, set these variables:
   - `AWS_REGION` (e.g., `us-east-1`)
   - `PF_ADMIN_BASE_URL` (e.g., `https://pingfederate-dev.example.com:9999`)
   - `PF_ADMIN_CONTEXT` (default: `/pf-admin-api/v1`)
   - `PF_PROVIDER_TRUST_ALL_TLS` (dev: `true`, staging/prod: `false`)
   - `PF_PROVIDER_BYPASS_EXTERNAL_VALIDATION_HEADER` (dev: `true`, staging/prod: `false`)
   - `PF_PROVIDER_PRODUCT_VERSION` (e.g., `12.3`)

4. **Update Workflow to Use Environment**

   Modify `.github/workflows/pingsso-pipeline.yaml`:

   ```yaml
   apply-changes:
     name: "Apply to PingFederate"
     needs: validate-and-plan
     if: github.ref == 'refs/heads/main' && github.event_name == 'push'
     runs-on: ubuntu-latest
     environment: production  # Change this to switch environments
   ```

### Example Environment Configurations

**Development:**

```yaml
Variables:
  PF_ADMIN_BASE_URL: "https://pingfederate-dev.example.com:9999"
  PF_PROVIDER_TRUST_ALL_TLS: "true"
  PF_PROVIDER_BYPASS_EXTERNAL_VALIDATION_HEADER: "true"
  AWS_REGION: "us-east-1"
```

**Staging:**

```yaml
Variables:
  PF_ADMIN_BASE_URL: "https://pingfederate-staging.example.com:9999"
  PF_PROVIDER_TRUST_ALL_TLS: "false"
  PF_PROVIDER_BYPASS_EXTERNAL_VALIDATION_HEADER: "false"
  AWS_REGION: "us-east-1"
```

**Production:**

```yaml
Variables:
  PF_ADMIN_BASE_URL: "https://pingfederate.example.com:9999"
  PF_PROVIDER_TRUST_ALL_TLS: "false"
  PF_PROVIDER_BYPASS_EXTERNAL_VALIDATION_HEADER: "false"
  AWS_REGION: "us-east-1"
Protection Rules:
  - Required reviewers: 2
  - Wait timer: 5 minutes
```

## Strategy 2: Terraform Workspaces

Use Terraform workspaces to manage multiple state files for different environments.

### Setup Workspaces

```bash
# Create workspaces
cd platform
terraform workspace new development
terraform workspace new staging
terraform workspace new production

# Switch between environments
terraform workspace select development
terraform init
terraform apply

terraform workspace select production
terraform init
terraform apply
```

### Workspace-Aware Configuration

```hcl
# platform/main.tf
locals {
  environment = terraform.workspace
  
  # Environment-specific settings
  env_config = {
    development = {
      trust_all_tls = true
      bypass_validation = true
    }
    staging = {
      trust_all_tls = false
      bypass_validation = false
    }
    production = {
      trust_all_tls = false
      bypass_validation = false
    }
  }
}

# Use workspace-specific backend key
terraform {
  backend "s3" {
    bucket = "your-terraform-state"
    key    = "pingsso/${terraform.workspace}/terraform.tfstate"
    region = "us-east-1"
  }
}
```

## Strategy 3: Separate Backend Configurations

Use different S3 state file keys for each environment.

### Development

```hcl
# platform/backend-dev.tf
terraform {
  backend "s3" {
    bucket = "your-terraform-state"
    key    = "pingsso/dev/terraform.tfstate"
    region = "us-east-1"
  }
}
```

### Production (Local Testing)

```hcl
# platform/backend-prod.tf
terraform {
  backend "s3" {
    bucket = "your-terraform-state"
    key    = "pingsso/prod/terraform.tfstate"
    region = "us-east-1"
  }
}
```

## Local Testing (terraform.tfvars)

For local development and testing, use `terraform.tfvars` files:

### Local Development Testing

```hcl
# test/terraform.tfvars (local dev)
pf_admin_username   = "Administrator"
pf_admin_password   = "dev-password"
pf_admin_base_url   = "https://pingfederate-dev.example.com:9999"
pf_admin_context    = "/pf-admin-api/v1"

# Dev-specific overrides
pf_provider_trust_all_tls                      = true
pf_provider_bypass_external_validation_header = true
pf_provider_product_version                    = "12.3"
```

### Production

```hcl
# platform/terraform.tfvars (local prod testing - DO NOT COMMIT)
pf_admin_username   = "api-admin"
pf_admin_password   = "prod-password"
pf_admin_base_url   = "https://pingfederate.example.com:9999"

# Production settings
pf_provider_trust_all_tls                      = false
pf_provider_bypass_external_validation_header = false
pf_provider_product_version                    = "12.3"
```

## Best Practices

1. **Never commit terraform.tfvars** - It's in `.gitignore` for a reason

2. **Use environment variables for CI/CD** - Leverage GitHub Actions secrets/variables:

   ```bash
   # These are set automatically in GitHub Actions
   export TF_VAR_pf_admin_username="$PF_ADMIN_USERNAME"
   export TF_VAR_pf_admin_password="$PF_ADMIN_PASSWORD"
   export TF_VAR_pf_admin_base_url="$PF_ADMIN_BASE_URL"
   ```

3. **Separate state files** - Use different S3 keys or workspaces per environment

4. **Environment-specific protection** - Enable required approvals for production:
   - GitHub Environment protection rules
   - Manual approval gates
   - Restrict who can deploy to production

5. **Use strict settings in production**:
   - `pf_provider_trust_all_tls = false`
   - `pf_provider_bypass_external_validation_header = false`
   - Only allow `https://` URLs in policies

6. **Test in lower environments first** - Always validate changes in dev/staging before production
