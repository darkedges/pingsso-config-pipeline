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

Optional for Jira callback automation:

- `JIRA_USER_EMAIL` - Jira automation user email for API authentication
- `JIRA_API_TOKEN` - Jira API token for comment and transition operations

### GitHub Actions Variables Required

Set these in your repository settings (Settings → Secrets and variables → Actions → Variables):

- `AWS_REGION` - AWS region for S3 backend (e.g., `us-east-1`)
- `PF_ADMIN_BASE_URL` - PingFederate base URL (e.g., `https://pingfederate.example.com:9999`)
- `PF_ADMIN_CONTEXT` - PingFederate admin API path (default: `/pf-admin-api/v1`)
- `PF_PROVIDER_TRUST_ALL_TLS` - Trust all TLS certificates (default: `false`)
- `PF_PROVIDER_BYPASS_EXTERNAL_VALIDATION_HEADER` - Bypass external validation (default: `false`)
- `PF_PROVIDER_PRODUCT_VERSION` - PingFederate version (e.g., `12.3`)

Optional for Jira callback automation:

- `JIRA_BASE_URL` - Jira tenant base URL (e.g., `https://company.atlassian.net`)
- `JIRA_DONE_TRANSITION_NAME` - Transition name to move ticket after successful apply (e.g., `Done`)

### Additional Automation Workflows

- `jira-to-github-issue.yml` creates a GitHub issue from Jira Service Management webhook payload.
- `issue-to-terraform-pr.yml` generates a Terraform file in `teams/` and opens or updates a pull request automatically.
- `issue-to-terraform-dry-run.yml` validates request data and generates a Terraform preview artifact without creating a PR.
- `pingsso-pipeline.yaml` applies approved changes and can post deployment evidence back to Jira and transition the ticket.

### Dry Run Testing (No PR Created)

Use GitHub Actions → `Issue to Terraform Dry Run` to validate parser behavior and generated Terraform content before enabling full automation in Jira.

Required inputs:

- `issue_key`, `jsm_url`, `summary`, `reporter`, `team_name`, `app_name`, `app_type`
- For OIDC: at least one redirect URI and `oidc_grant_types`
- For SAML: `saml_entity_id` and HTTPS `saml_acs_url`

Output:

- Step summary includes generated Terraform content
- `terraform-preview` artifact contains the generated file under `preview/teams/...`

### Sample Jira Webhook Payload

Use this example in your Jira Automation "Send web request" action body.

```json
{
   "event_type": "jira-uri-request",
   "client_payload": {
      "issue_key": "IAM-1423",
      "jsm_url": "https://company.atlassian.net/servicedesk/customer/portal/12/IAM-1423",
      "summary": "Add production redirect URI for payroll portal",
      "reporter": "jane.doe@company.com",
      "fields": {
         "team_name": "hr-platform",
         "app_name": "payroll-portal",
         "app_type": "OIDC",
         "oidc_grant_types": "AUTHORIZATION_CODE\nREFRESH_TOKEN",
         "dev_redirect_uris": "https://dev.payroll.example.com/callback",
         "test_redirect_uris": "https://test.payroll.example.com/callback",
         "stage_redirect_uris": "https://stage.payroll.example.com/callback",
         "prod_redirect_uris": "https://payroll.example.com/callback",
         "saml_entity_id": "",
         "saml_acs_url": ""
      }
   }
}
```

For SAML requests, set:

- `fields.app_type` = `SAML`
- `fields.saml_entity_id` = SP entity identifier
- `fields.saml_acs_url` = HTTPS ACS URL
- `fields.oidc_grant_types` and redirect URI fields can be empty if not used

### Sample Jira Webhook Payload (SAML)

```json
{
    "event_type": "jira-uri-request",
    "client_payload": {
         "issue_key": "IAM-1650",
         "jsm_url": "https://company.atlassian.net/servicedesk/customer/portal/12/IAM-1650",
         "summary": "Onboard vendor SAML application",
         "reporter": "john.smith@company.com",
         "fields": {
             "team_name": "enterprise-apps",
             "app_name": "vendor-benefits-portal",
             "app_type": "SAML",
             "oidc_grant_types": "",
             "dev_redirect_uris": "",
             "test_redirect_uris": "",
             "stage_redirect_uris": "",
             "prod_redirect_uris": "",
             "saml_entity_id": "https://sp.vendor-benefits.com/saml2",
             "saml_acs_url": "https://sp.vendor-benefits.com/sso/consume"
         }
    }
}
```

### Jira Automation Rule Recipe

Use this recipe in Jira Automation for your JSM request type.

1. Trigger

- `Issue created` or `Issue transitioned` to an approved status.

1. Conditions

- Request type equals your PingFederate onboarding form.
- Optional: status/category equals Approved.

1. Action: Send web request

- Method: `POST`
- URL: `https://api.github.com/repos/<owner>/<repo>/dispatches`
- Header `Accept`: `application/vnd.github+json`
- Header `Authorization`: `Bearer <github-pat-with-repo-scope>`
- Header `X-GitHub-Api-Version`: `2022-11-28`
- Header `Content-Type`: `application/json`

1. Web request body template

Use Jira smart values mapped to your custom fields. For dropdown fields, use `.value` so the payload sends labels instead of option IDs.

- Single-select dropdown pattern: `{{issue.customfield_12345.value}}`
- Multi-select dropdown pattern (comma-separated labels): `{{#issue.customfield_12345}}{{value}}{{^last}},{{/}}{{/}}`

```json
{
   "event_type": "jira-uri-request",
   "client_payload": {
      "issue_key": "{{issue.key}}",
      "jsm_url": "{{issue.url}}",
      "summary": "{{issue.summary}}",
      "reporter": "{{issue.reporter.emailAddress}}",
      "fields": {
         "team_name": "{{issue.customfield_team_name.value}}",
         "app_name": "{{issue.customfield_app_name.value}}",
         "app_type": "{{issue.customfield_app_type.value}}",
         "oidc_grant_types": "{{#issue.customfield_oidc_grant_types}}{{value}}{{^last}},{{/}}{{/}}",
         "dev_redirect_uris": "{{issue.customfield_dev_redirect_uris}}",
         "test_redirect_uris": "{{issue.customfield_test_redirect_uris}}",
         "stage_redirect_uris": "{{issue.customfield_stage_redirect_uris}}",
         "prod_redirect_uris": "{{issue.customfield_prod_redirect_uris}}",
         "saml_entity_id": "{{issue.customfield_saml_entity_id}}",
         "saml_acs_url": "{{issue.customfield_saml_acs_url}}"
      }
   }
}
```

1. Verification

- Confirm workflow `Create Issue from Jira Webhook` runs in GitHub Actions.
- Confirm generated GitHub issue has `automated-request` label.
- Confirm `Issue to Terraform PR` creates or updates a pull request.

### Jira Custom Field ID Discovery

Use this section to identify the exact Jira field IDs needed in the web request body template, such as `customfield_12345`.

1. UI method (fastest)

- Open an issue that uses your JSM request form.
- Open browser developer tools and inspect the issue payload in network requests.
- Locate field keys for each form value, then map them to template entries for `team_name`, `app_name`, `app_type`, `oidc_grant_types`, `dev_redirect_uris`, `test_redirect_uris`, `stage_redirect_uris`, `prod_redirect_uris`, `saml_entity_id`, and `saml_acs_url`.

1. API method (authoritative)

- Call Jira fields API and search by field display name.
- Endpoint: `GET https://<your-domain>.atlassian.net/rest/api/3/field`
- Authenticate with email and API token.

Example command:

```bash
curl -sS -u "<email>:<api_token>" \
   -H "Accept: application/json" \
   "https://<your-domain>.atlassian.net/rest/api/3/field" \
   | jq -r '.[] | [.id, .name] | @tsv'
```

1. Confirm in Automation logs

- Run the Jira automation rule once.
- Check audit log details and verify that each smart value resolves to the expected field content.
- Update the body template if any value is empty or mapped to the wrong field.

### Jira Field ID Mapping Worksheet

Use this table to record your Jira field IDs and copy them directly into the automation body template.

| Payload Field Key | Jira Display Name | Example Smart Value | Actual Jira Field ID |
| --- | --- | --- | --- |
| `fields.team_name` | Team Name | `{{issue.customfield_XXXXX.value}}` | `customfield_` |
| `fields.app_name` | Application Name | `{{issue.customfield_XXXXX.value}}` | `customfield_` |
| `fields.app_type` | Application Type | `{{issue.customfield_XXXXX.value}}` | `customfield_` |
| `fields.oidc_grant_types` | OIDC Grant Types | `{{#issue.customfield_XXXXX}}{{value}}{{^last}},{{/}}{{/}}` | `customfield_` |
| `fields.dev_redirect_uris` | Development Redirect URIs | `{{issue.customfield_dev_redirect_uris}}` | `customfield_` |
| `fields.test_redirect_uris` | Test Redirect URIs | `{{issue.customfield_test_redirect_uris}}` | `customfield_` |
| `fields.stage_redirect_uris` | Staging Redirect URIs | `{{issue.customfield_stage_redirect_uris}}` | `customfield_` |
| `fields.prod_redirect_uris` | Production Redirect URIs | `{{issue.customfield_prod_redirect_uris}}` | `customfield_` |
| `fields.saml_entity_id` | SAML Entity ID | `{{issue.customfield_saml_entity_id}}` | `customfield_` |
| `fields.saml_acs_url` | SAML ACS URL | `{{issue.customfield_saml_acs_url}}` | `customfield_` |

### Final Resolved Body Template (Replace Field IDs)

Copy this JSON into Jira Automation after replacing each `CUSTOMFIELD_*` token with your actual field ID value (for example `12345`).

```json
{
   "event_type": "jira-uri-request",
   "client_payload": {
      "issue_key": "{{issue.key}}",
      "jsm_url": "{{issue.url}}",
      "summary": "{{issue.summary}}",
      "reporter": "{{issue.reporter.emailAddress}}",
      "fields": {
         "team_name": "{{issue.customfield_CUSTOMFIELD_TEAM_NAME.value}}",
         "app_name": "{{issue.customfield_CUSTOMFIELD_APP_NAME.value}}",
         "app_type": "{{issue.customfield_CUSTOMFIELD_APP_TYPE.value}}",
         "oidc_grant_types": "{{#issue.customfield_CUSTOMFIELD_OIDC_GRANT_TYPES}}{{value}}{{^last}},{{/}}{{/}}",
         "dev_redirect_uris": "{{issue.customfield_CUSTOMFIELD_DEV_REDIRECT_URIS}}",
         "test_redirect_uris": "{{issue.customfield_CUSTOMFIELD_TEST_REDIRECT_URIS}}",
         "stage_redirect_uris": "{{issue.customfield_CUSTOMFIELD_STAGE_REDIRECT_URIS}}",
         "prod_redirect_uris": "{{issue.customfield_CUSTOMFIELD_PROD_REDIRECT_URIS}}",
         "saml_entity_id": "{{issue.customfield_CUSTOMFIELD_SAML_ENTITY_ID}}",
         "saml_acs_url": "{{issue.customfield_CUSTOMFIELD_SAML_ACS_URL}}"
      }
   }
}
```

Example replacement:

- `{{issue.customfield_CUSTOMFIELD_TEAM_NAME.value}}` becomes `{{issue.customfield_12345.value}}`
- `{{#issue.customfield_CUSTOMFIELD_OIDC_GRANT_TYPES}}{{value}}{{^last}},{{/}}{{/}}` becomes `{{#issue.customfield_23456}}{{value}}{{^last}},{{/}}{{/}}`

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
