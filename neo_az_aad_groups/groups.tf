# Get the group owner users
data "azuread_user" "group_owner_users" {
  for_each = { for owner_user in local.aad_owner_users : owner_user.id => owner_user }

  user_principal_name = each.value.user
}

# Create the AAD groups
resource "azuread_group" "aad_groups" {
  for_each = { for group in local.new_aad_groups : group.name => group }

  display_name     = join("-", [var.resource_prefix, "grp", join("_", compact([var.name_prefix, each.key]))])
  security_enabled = true
  owners           = length(local.aad_group_owners[each.key]) > 0 ? local.aad_group_owners[each.key] : null

  # ToDo: Need to split group creation into two (Then merge in locals for references elsewhere) if we want to support groups which ignore member changes.
  # lifecycle {
  #   ignore_changes = [members]
  # }
}

# Fetch existing groups
data "azuread_group" "existing_groups" {
  for_each = { for group in local.existing_aad_groups : group.name => group }

  display_name = join("-", [var.resource_prefix, "grp", join("_", compact([var.name_prefix, each.key]))])
}

# Assign roles to the groups
resource "azurerm_role_assignment" "add_group_role_assignments" {
  for_each = { for role_assignment in local.aad_group_role_assignments : role_assignment.id => role_assignment }

  scope                = each.value.role_assignment.scope
  role_definition_name = each.value.role_assignment.role_definition_name
  principal_id         = each.value.existing_group ? data.azuread_group.existing_groups[each.value.group].id : azuread_group.aad_groups[each.value.group].id
}

# Add Users to the groups
data "azuread_user" "group_member_users" {
  for_each = { for group_user in local.aad_group_users : group_user.id => group_user }

  user_principal_name = each.value.user
}

resource "azuread_group_member" "aad_group_user_members" {
  for_each = { for group_user in local.aad_group_users : group_user.id => group_user }

  group_object_id  = each.value.existing_group ? data.azuread_group.existing_groups[each.value.group].id : azuread_group.aad_groups[each.value.group].id
  member_object_id = data.azuread_user.group_member_users[each.key].object_id

  depends_on = [azuread_group.aad_groups]
}

# Add Expiring Users to the groups
data "azuread_user" "group_member_expiring_users" {
  for_each = { for user in local.aad_group_expiring_users : user.id => user }

  user_principal_name = each.value.user
}

resource "azuread_group_member" "aad_group_expiring_user_members" {
  for_each = {
    for user in local.aad_group_expiring_users : user.id => user
    # if formatdate("YYYYMMDD", join("", [user.expiry_date, "T00:00:00.000Z"])) > formatdate("YYYYMMDD", timestamp())
  }

  group_object_id  = each.value.existing_group ? data.azuread_group.existing_groups[each.value.group].id : azuread_group.aad_groups[each.value.group].id
  member_object_id = data.azuread_user.group_member_expiring_users[each.key].object_id

  depends_on = [azuread_group.aad_groups]
}

# Add Groups to the groups
data "azuread_group" "group_member_groups" {
  for_each = { for group_groups in local.aad_group_groups : group_groups.id => group_groups }

  display_name     = each.value.member_group
  security_enabled = true
}

resource "azuread_group_member" "aad_group_group_members" {
  for_each = { for group_groups in local.aad_group_groups : group_groups.id => group_groups }

  group_object_id  = each.value.existing_group ? data.azuread_group.existing_groups[each.value.group].id : azuread_group.aad_groups[each.value.group].id
  member_object_id = data.azuread_group.group_member_groups[each.key].id
}

# Add Managed Identities to the groups
data "azurerm_user_assigned_identity" "managed_identities" {
  for_each = { for group_identity in local.aad_group_identities : group_identity.id => group_identity }

  name                = each.value.identity
  resource_group_name = var.identities_resource_group
}

resource "azuread_group_member" "aad_group_identity_members" {
  for_each = { for group_identity in local.aad_group_identities : group_identity.id => group_identity }

  group_object_id  = each.value.existing_group ? data.azuread_group.existing_groups[each.value.group].id : azuread_group.aad_groups[each.value.group].id
  member_object_id = data.azurerm_user_assigned_identity.managed_identities[each.key].principal_id
}

# Add Principals to the groups
resource "azuread_group_member" "aad_group_principal_members" {
  for_each = { for group_principal in local.aad_group_principals : group_principal.id => group_principal }

  group_object_id  = each.value.existing_group ? data.azuread_group.existing_groups[each.value.group].id : azuread_group.aad_groups[each.value.group].id
  member_object_id = each.value.principal_id
}

# Add Named principals to the groups
resource "azuread_group_member" "aad_group_named_principal_members" {
  for_each = { for group_named_principal in local.aad_group_named_principals : group_named_principal.id => group_named_principal }

  group_object_id  = each.value.existing_group ? data.azuread_group.existing_groups[each.value.group].id : azuread_group.aad_groups[each.value.group].id
  member_object_id = each.value.principal_id
}
