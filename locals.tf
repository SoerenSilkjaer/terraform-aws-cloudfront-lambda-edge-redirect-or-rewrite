locals {
  project_name = "${replace(var.domain, ".", "-")}-redirect-rewrite"
  description = substr("${var.domain} ${var.action} to ${var.destination_domain}${var.destination_path}", 0, 127)

  config_json = jsonencode({
    "destination_domain" : tostring(var.destination_domain),
    "destination_path" : tostring(var.destination_path),
    "action" : tostring(var.action),
  })
}
