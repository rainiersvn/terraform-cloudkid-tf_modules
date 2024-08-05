locals {
  groups_with_members = [
    for group in var.aad_groups : group
    if length(group.identities) > 0 || length(group.users) > 0 || length(group.groups) > 0 || length(group.principal_ids) > 0 || length(group.expiring_users) > 0
  ]

  base_groups         = var.skip_empty_groups ? local.groups_with_members : var.aad_groups
  new_aad_groups      = [for aad_group in local.base_groups : aad_group if aad_group.existing == false]
  existing_aad_groups = [for aad_group in local.base_groups : aad_group if aad_group.existing == true]

  groups_lifecycle = var.ignore_member_changes ? ["members"] : []

  # Users to make owners of the AAD Groups
  aad_owner_users = flatten([
    for group in local.base_groups : [
      for user in group.owner_users : {
        id : join("-", [group.name, user])
        group : group.name
        existing_group : group.existing
        user : user
      }
    ]
  ])

  # The owner principals for each group
  aad_group_owners = {
    for group in local.base_groups : group.name => concat(
      concat([for user in local.aad_owner_users : data.azuread_user.group_owner_users[user.id].object_id if user.group == group.name]),
      group.owner_principal_ids
    )
  }

  # Users to add to the AAD Groups
  aad_group_users = flatten([
    for group in local.base_groups : [
      for user in group.users : {
        id : join("-", [group.name, user])
        group : group.name
        existing_group : group.existing
        user : user
      }
    ]
  ])

  # Expiring users which have not yet expired
  aad_group_expiring_users = flatten([
    for group in local.base_groups : [
      for user in group.expiring_users : {
        id : join("-", [group.name, user.username])
        group : group.name
        existing_group : group.existing
        user : user.username
      } if formatdate("YYYYMMDD", join("", [user.expiry_date, "T00:00:00.000Z"])) > formatdate("YYYYMMDD", var.current_timestamp)
    ]
  ])

  # Groups to add to the AAD Groups
  aad_group_groups = flatten([
    for aad_group in local.base_groups : [
      for member_group in aad_group.groups : {
        id : join("-", [aad_group.name, member_group])
        group : aad_group.name
        existing_group : aad_group.existing
        member_group : member_group
      }
    ]
  ])

  # Identities to add to the AAD groups
  aad_group_identities = flatten([
    for group in local.base_groups : [
      for identity in group.identities : {
        id : join("-", [group.name, identity])
        group : group.name
        existing_group : group.existing
        identity : identity
      }
    ]
  ])

  # Principals to add to the AAD groups
  aad_group_principals = flatten([
    for group in local.base_groups : [
      for principal_id in group.principal_ids : {
        id : join("-", [group.name, principal_id])
        group : group.name
        existing_group : group.existing
        principal_id : principal_id
      }
    ]
  ])

  # Named principals to add to the AAD groups
  aad_group_named_principals = flatten([
    for group in local.base_groups : [
      for key, principal in group.principals : {
        id : join("-", [group.name, key])
        group : group.name
        existing_group : group.existing
        principal_id : principal.object_id
      }
    ]
  ])

  # Role Assignments to add to the AAD groups
  aad_group_role_assignments = flatten([
    for group in local.base_groups : [
      for index, role_assignment in group.role_assignments : {
        id : join("-", compact([group.name, role_assignment.resource_name, lower(replace(role_assignment.role_definition_name, " ", "_")), role_assignment.resource_name == null ? index : ""]))
        group : group.name
        existing_group : group.existing
        role_assignment : role_assignment
      }
    ]
  ])
}
