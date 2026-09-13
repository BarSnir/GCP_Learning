# outputs.tf
output "node_flex_url" {
  description = "Node.js Flexible service URL"
  value       = "https://node-flex-dot-${var.project_id}.ew.r.appspot.com"
}

output "curl_node_flex" {
  description = "Quick test command"
  value       = "curl https://node-flex-dot-${var.project_id}.ew.r.appspot.com"
}