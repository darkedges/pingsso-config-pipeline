package terraform.pingsso

import input as tfplan

# --- Helpers to grab specific resources ---

# Get all OIDC Clients being created or updated
oidc_resources[r] {
    r := tfplan.resource_changes[_]
    r.type == "pingfederate_oauth_client"
    r.mode == "managed"
    (r.change.actions[_] == "create" or r.change.actions[_] == "update")
}

# Get all SAML Connections being created or updated
saml_resources[r] {
    r := tfplan.resource_changes[_]
    r.type == "pingfederate_idp_sp_connection"
    r.mode == "managed"
    (r.change.actions[_] == "create" or r.change.actions[_] == "update")
}

# --- 1. Enforce HTTPS for OIDC Redirects ---
deny[msg] {
    r := oidc_resources[_]
    # Iterate over every redirect URI in the list
    uri := r.change.after.redirect_uris[_]
    
    not startswith(uri, "https://")
    
    msg := sprintf(
        "SECURITY VIOLATION: OIDC Redirect URI '%v' in app '%v' must use HTTPS.",
        [uri, r.name]
    )
}

# --- 2. Enforce HTTPS for SAML ACS URLs ---
deny[msg] {
    r := saml_resources[_]
    url := r.change.after.sp_browser_sso[0].sso_service_endpoints[0].url
    
    not startswith(url, "https://")
    
    msg := sprintf(
        "SECURITY VIOLATION: SAML ACS URL '%v' in app '%v' must use HTTPS.",
        [url, r.name]
    )
}

# --- 3. Block Localhost (Production Safety) ---
# Checks both SAML and OIDC for localhost or 127.0.0.1
deny[msg] {
    r := oidc_resources[_]
    uri := r.change.after.redirect_uris[_]
    
    contains_localhost(uri)
    
    msg := sprintf(
        "PRODUCTION SAFETY: OIDC Redirect URI '%v' contains localhost. This is not allowed in this environment.",
        [uri]
    )
}

deny[msg] {
    r := saml_resources[_]
    url := r.change.after.sp_browser_sso[0].sso_service_endpoints[0].url
    
    contains_localhost(url)
    
    msg := sprintf(
        "PRODUCTION SAFETY: SAML ACS URL '%v' contains localhost. This is not allowed in this environment.",
        [url]
    )
}

# --- 4. Validate OIDC Grant Types ---
deny[msg] {
    r := oidc_resources[_]
    grant := r.change.after.grant_types[_]
    
    valid_grants := ["AUTHORIZATION_CODE", "CLIENT_CREDENTIALS", "IMPLICIT", "REFRESH_TOKEN"]
    not contains(valid_grants, grant)
    
    msg := sprintf(
        "INVALID GRANT TYPE: OIDC app '%v' uses invalid grant type '%v'. Allowed: AUTHORIZATION_CODE, CLIENT_CREDENTIALS, IMPLICIT, REFRESH_TOKEN.",
        [r.name, grant]
    )
}

# --- 5. Require Attribute Mappings ---
deny[msg] {
    r := oidc_resources[_]
    
    # Check if attribute mapping is empty or missing
    object.length(r.change.after.attribute_mapping) == 0
    
    msg := sprintf(
        "CONFIGURATION ERROR: OIDC app '%v' has no attribute mappings defined. At least email and sub should be mapped.",
        [r.name]
    )
}

# Helper function to check for localhost
contains_localhost(url) {
    contains(url, "localhost")
}
contains_localhost(url) {
    contains(url, "127.0.0.1")
}