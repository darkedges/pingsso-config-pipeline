# Setup Guide

## Initial Platform Setup (Admin Only)

### 1. Prerequisites

- Terraform >= 1.0 installed
- Access to PingFederate API
- AWS credentials (for S3 backend)
- Git repository access

### 2. Configure Backend

Edit `platform/main.tf` to set your S3 backend:

```hcl
backend "s3" {
  bucket = "your-company-terraform-state"
  key    = "pingsso/prod.tfstate"
  region = "us-east-1"
}
```

### 3. Set Credentials

Copy the example file and fill in values:

```bash
cd platform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your PingFederate credentials
```

**Never commit terraform.tfvars!**

### 4. Initialize Terraform

```bash
cd platform
terraform init
terraform plan
terraform apply
```

## Team Onboarding Guide

### For Application Teams

1. **Navigate to your team folder**

   ```bash
   cd teams/
   ```

2. **Create your app configuration**
   - Create a new `.tf` file (e.g., `my-app.tf`)
   - Use the examples in `teams/oidc/app.tf` or `teams/saml/app.tf`
   - Or reference the test examples in `test/main.tf` (see `TEST.md`)

3. **Configure your application**
   See the module README at `modules/pingsso_application/README.md`

4. **Submit a Pull Request**
   - The CI/CD pipeline will automatically validate
   - Security policies will be checked
   - Terraform plan will be commented on your PR

5. **After Merge**
   - Changes are automatically applied to production
   - Check outputs for your client ID or metadata URL

## CI/CD Setup (Admin)

### GitHub Actions Secrets Required

Set these in your repository settings (Settings → Secrets and variables → Actions → Secrets):

- `AWS_ACCESS_KEY_ID` - AWS access key for S3 backend
- `AWS_SECRET_ACCESS_KEY` - AWS secret key for S3 backend
- `PF_ADMIN_USERNAME` - PingFederate API admin username
- `PF_ADMIN_PASSWORD` - PingFederate API admin password

### GitHub Actions Variables Required

Set these in your repository settings (Settings → Secrets and variables → Actions → Variables):

- `AWS_REGION` - AWS region for S3 backend (e.g., `us-east-1`)
- `PF_ADMIN_BASE_URL` - PingFederate base URL (e.g., `https://pingfederate.example.com:9999`)
- `PF_ADMIN_CONTEXT` - PingFederate admin API path (default: `/pf-admin-api/v1`)
- `PF_PROVIDER_TRUST_ALL_TLS` - Trust all TLS certificates (default: `false`)
- `PF_PROVIDER_BYPASS_EXTERNAL_VALIDATION_HEADER` - Bypass external validation (default: `false`)
- `PF_PROVIDER_PRODUCT_VERSION` - PingFederate version (e.g., `12.3`)

### Enable Pre-commit Hooks (Optional)

```bash
chmod +x .git-hooks/pre-commit
ln -s ../../.git-hooks/pre-commit .git/hooks/pre-commit
```

## Troubleshooting

### "OPA Policy Violation: HTTPS Only"

Your redirect URIs or ACS URLs must use `https://`. Update your configuration.

### "No declaration found for var.insecure_tls"

Make sure you've created `platform/terraform.tfvars` from the example.

### "Backend initialization required"

Run `terraform init` in the `platform/` directory.

### "Access denied" errors

Check your PingFederate credentials and API permissions.

## Advanced Configuration

### Multiple Environments

See `ENVIRONMENTS.md` for dev/staging/prod separation strategies.

### Custom IDP Adapters

Override the default adapter in your module:

```hcl
module "my_app" {
  source = "../../modules/pingsso_application"
  
  idp_adapter_ref = "CustomLDAPAdapter"
  # ... rest of config
}
```

### Custom Access Token Manager (OIDC)

```hcl
module "my_app" {
  source = "../../modules/pingsso_application"
  
  access_token_manager_ref = "custom_jwt_atm"
  # ... rest of config
}
```

## Next Steps

1. Review security policies in `policies/pingsso_security.rego`
2. Set up monitoring for Terraform runs
3. Configure state locking (DynamoDB for S3 backend)
4. Set up Terraform Cloud or Atlantis for better PR workflows
