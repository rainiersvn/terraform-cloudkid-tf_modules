variable "resource_prefix" {
  description = "Prefix to use for azure ad resources"
  type        = string
}

variable "name_prefix" {
  description = "Prefix to add before the 'descriptive name' portion of a group name"
  type        = string
  default     = ""
}

variable "ignore_member_changes" {
  description = "Should member changes be ignored when updating the groups?"
  type        = bool
  default     = false
}

variable "skip_empty_groups" {
  description = "Should groups with no members still be provisioned?"
  type        = bool
  default     = false
}

variable "identities_resource_group" {
  description = "The group in which the user assigned identities exist, required if any groups add identities as members"
  type        = string
  default     = ""
}

variable "aad_groups" {
  description = "AAD Groups to create, and the members to add"
  type = list(object({
    name                = string
    existing            = optional(bool, false)
    owner_users         = optional(list(string), [])
    owner_principal_ids = optional(list(string), [])

    identities    = optional(list(string), [])
    users         = optional(list(string), [])
    groups        = optional(list(string), [])
    principal_ids = optional(list(string), [])

    principals = optional(map(object({
      name      = string
      object_id = string
    })), {})

    expiring_users = optional(list(object({
      username    = string
      expiry_date = string
    })), [])

    role_assignments = optional(list(object({
      resource_name        = optional(string, null) # Name of the resource, must be unique across resource type and role definition name. If provided, this prevents role assignments from being recreated if their order changes. (NOTE: This cannot be a value which can only be determined after resource creation, as terraform will be unable to plan the run)
      scope                = string
      role_definition_name = string
    })), [])
  }))
}

variable "current_timestamp" {
  # ToDo: This has to be passed in manually as timestamp() does not resolve until after apply.
  #       If a future version of Terraform adds the ability to default this to the current datetime, this should be updated.
  description = "Timestamp containing the current datetime, required for checking if expiring users need to be removed from groups."
  type        = string
  default     = "1900-01-01T00:00:00.000Z"
}
