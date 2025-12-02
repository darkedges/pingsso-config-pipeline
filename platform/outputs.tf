# Platform-level outputs
# These can be used to reference deployed applications

output "deployment_summary" {
  description = "Summary of all deployed applications"
  value = {
    timestamp = timestamp()
    message   = "All team applications deployed successfully"
  }
}
