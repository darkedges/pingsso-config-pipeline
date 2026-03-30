---
name: Manage Redirect URIs
about: Request new or updated redirect URIs for an application.
title: "[Manage Redirect URIs]: "
labels: ''
assignees: ''

---

body:
  - type: markdown
    attributes:
      value: |
        Thanks for taking the time to fill out this Manage Redirect URI request
  - type: input
    id: team_name
    attributes:
      label: Team Name
      placeholder: e.g., Cloud-Platform-Team
    validations:
      required: true
  - type: input
    id: app_name
    attributes:
      label: Application Name
      placeholder: e.g., customer-portal-api
    validations:
      required: true
  - type: textarea
    id: dev_redirect_uris
    attributes:
      label: Development Redirect URIs
      description: List one URI per line for the DEV environment.
      placeholder: |
        http://localhost:3000/callback
        https://dev.myapp.com/callback
    validations:
      required: false
  - type: textarea
    id: test_redirect_uris
    attributes:
      label: Test Redirect URIs
      description: List one URI per line for the TEST environment.
    validations:
      required: false
  - type: textarea
    id: stage_redirect_uris
    attributes:
      label: Staging Redirect URIs
      description: List one URI per line for the STAGE environment.
    validations:
      required: false
  - type: textarea
    id: prod_redirect_uris
    attributes:
      label: Production Redirect URIs
      description: List one URI per line for the PROD environment.
    validations:
      required: false
  - type: checkboxes
    id: terms
    attributes:
      label: Security Confirmation
      options:
        - label: I confirm these URIs follow our security standards (e.g., HTTPS for non-localhost).
          required: true
