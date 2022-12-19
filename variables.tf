variable "domain" {
  type = string
  description = "Domain to be redirected/rewritten"
}

variable "domain_zone_id" {
  type = string
  description = "The zone_id of you"
}

variable "subject_alternative_names" {
  type = list(string)
  description = "Additional domains to be redirected/rewritten. Can only be domains on the same hosted zone as the 'domain_zone_id' variable"
  default = []
}

variable "destination_domain" {
  type = string
  description = "Domain to be redirected/rewritten to"
}

variable "destination_path" {
  type = string
  description = "The path to be redirected to. If left empty, it will default to the same path as the request. Unused if the action is rewrite"
  default = ""
}

variable "action" {
  type        = string
  description = "The action that should be performed"
  validation {
    condition     = can(regex("^(permanent-redirect|temporary-redirect|rewrite)$", var.action))
    error_message = "The action must be one of the allowed values: [permanent-redirect, temporary-redirect, rewrite] ."
  }
}
