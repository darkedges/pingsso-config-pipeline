# Testing Guide

## Local Testing Environment

A test environment is provided in the `test/` directory to validate your configurations before deploying to teams.

### 1. Navigate to the test directory

```bash
cd test
```

### 2. Configure test credentials

Copy the example file and fill in your PingFederate credentials:

```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your PingFederate credentials
```

**Never commit terraform.tfvars!**

### 3. Test Configuration Variables

The test environment requires these variables in `terraform.tfvars`:

```hcl
pf_admin_username   = "your-admin-username"
pf_admin_password   = "your-admin-password"
pf_admin_base_url   = "https://your-pingfederate.example.com:9999"

# Optional - override defaults if needed
access_token_manager_id = "AccessTokenManagement"
idp_adapter_id          = "IDENTIFIERFIRST"
signing_key_id          = "your-signing-key-id"
saml_subject_attribute  = "subject"
```

### 4. Run test validation

```bash
terraform init
terraform plan
terraform apply
```

### 5. Example Applications

The test environment includes two sample applications:

- **Marketing Portal** (OIDC) - demonstrates OAuth/OIDC configuration
- **HR Payroll** (SAML) - demonstrates SAML 2.0 configuration

### 6. Clean up after testing

```bash
terraform destroy
```

## Troubleshooting Test Issues

### "No declaration found for variable"

Make sure you've created `test/terraform.tfvars` from the example file.

### "Access Token Manager not found"

Update the `access_token_manager_id` variable in your `terraform.tfvars` to match an existing Access Token Manager in your PingFederate instance.

### "IDP Adapter not found"

Update the `idp_adapter_id` variable in your `terraform.tfvars` to match an existing IDP Adapter in your PingFederate instance.

### "Signing key not found"

Update the `signing_key_id` variable in your `terraform.tfvars` to match an existing signing key pair in your PingFederate instance.
