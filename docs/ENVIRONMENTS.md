# Example configurations for different environments

## Development Environment

```hcl
# platform/terraform.tfvars (dev)
pingfederate_base_url = "https://pingfederate-dev.example.com"
pingfederate_username = "api-admin"
pingfederate_password = "dev-password"
insecure_tls          = true  # OK for dev with self-signed certs
```

## Staging Environment

```hcl
# platform/terraform.tfvars (staging)
pingfederate_base_url = "https://pingfederate-staging.example.com"
pingfederate_username = "api-admin"
pingfederate_password = "staging-password"
insecure_tls          = false
```

## Production Environment

```hcl
# platform/terraform.tfvars (prod)
pingfederate_base_url = "https://pingfederate.example.com"
pingfederate_username = "api-admin"
pingfederate_password = "prod-password"
insecure_tls          = false  # MUST be false in production
```

## Best Practices

1. **Never commit terraform.tfvars** - It's in .gitignore for a reason
2. **Use environment variables** - Alternative to tfvars files:

   ```bash
   export TF_VAR_pingfederate_base_url="https://..."
   export TF_VAR_pingfederate_username="admin"
   export TF_VAR_pingfederate_password="secret"
   ```

3. **Use a secrets manager** - Consider AWS Secrets Manager, HashiCorp Vault, or Azure Key Vault
4. **Separate backends** - Use different S3 keys or workspaces per environment
