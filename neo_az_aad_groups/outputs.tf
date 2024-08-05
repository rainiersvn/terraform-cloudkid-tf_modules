output "groups" {
  description = "The group details"
  value = {
    for group in local.base_groups : group.name => {
      object_id    = group.existing ? data.azuread_group.existing_groups[group.name].object_id : azuread_group.aad_groups[group.name].object_id
      display_name = group.existing ? data.azuread_group.existing_groups[group.name].display_name : azuread_group.aad_groups[group.name].display_name
      owners       = length(local.aad_group_owners[group.name]) > 0 ? local.aad_group_owners[group.name] : []

      users = distinct(concat(
        [for user in local.aad_group_users : user.user if user.group == group.name],
        [for user in local.aad_group_expiring_users : user.user if user.group == group.name],
      ))

      principals = distinct(concat([for principal in local.aad_group_principals : principal.principal_id if principal.group == group.name]))

      # This output format is compatible with the principal_map output from neo_az_principals_lookup.
      # The format is used as an input by some other modules which manage principal access to resources.
      principal_map = {
        join("_", ["groups", group.existing ? data.azuread_group.existing_groups[group.name].display_name : azuread_group.aad_groups[group.name].display_name]) = {
          name      = group.existing ? data.azuread_group.existing_groups[group.name].display_name : azuread_group.aad_groups[group.name].display_name
          object_id = group.existing ? data.azuread_group.existing_groups[group.name].object_id : azuread_group.aad_groups[group.name].object_id
        }
      }
    }
  }
}

output "group_ids" {
  description = "The group IDs"
  value       = [for group in local.base_groups : group.existing ? data.azuread_group.existing_groups[group.name].object_id : azuread_group.aad_groups[group.name].object_id]
}

output "group_names" {
  description = "The group names"
  value       = [for group in local.base_groups : group.existing ? data.azuread_group.existing_groups[group.name].display_name : azuread_group.aad_groups[group.name].display_name]
}
