<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.2 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | >= 2.29.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.27.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | >= 2.29.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 3.27.0 |

## Resources

| Name | Type |
|------|------|
| [azuread_group.aad_groups](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group) | resource |
| [azuread_group_member.aad_group_expiring_user_members](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group_member) | resource |
| [azuread_group_member.aad_group_group_members](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group_member) | resource |
| [azuread_group_member.aad_group_identity_members](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group_member) | resource |
| [azuread_group_member.aad_group_principal_members](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group_member) | resource |
| [azuread_group_member.aad_group_user_members](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group_member) | resource |
| [azurerm_role_assignment.add_group_role_assignments](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azuread_group.existing_groups](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/group) | data source |
| [azuread_group.group_member_groups](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/group) | data source |
| [azuread_user.group_member_expiring_users](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/user) | data source |
| [azuread_user.group_member_users](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/user) | data source |
| [azuread_user.group_owner_users](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/user) | data source |
| [azurerm_user_assigned_identity.managed_identities](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/user_assigned_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aad_groups"></a> [aad\_groups](#input\_aad\_groups) | AAD Groups to create, and the members to add | <pre>list(object({<br>    name                = string<br>    existing            = optional(bool, false)<br>    owner_users         = optional(list(string), [])<br>    owner_principal_ids = optional(list(string), [])<br><br>    identities    = optional(list(string), [])<br>    users         = optional(list(string), [])<br>    groups        = optional(list(string), [])<br>    principal_ids = optional(list(string), [])<br>    expiring_users = optional(list(object({<br>      username    = string<br>      expiry_date = string<br>    })), [])<br>    role_assignments = optional(list(object({<br>      scope                = string<br>      role_definition_name = string<br>    })), [])<br>  }))</pre> | n/a | yes |
| <a name="input_current_timestamp"></a> [current\_timestamp](#input\_current\_timestamp) | Timestamp containing the current datetime, required for checking if expiring users need to be removed from groups. | `string` | `"1900-01-01T00:00:00.000Z"` | no |
| <a name="input_identities_resource_group"></a> [identities\_resource\_group](#input\_identities\_resource\_group) | The group in which the user assigned identities exist, required if any groups add identities as members | `string` | `""` | no |
| <a name="input_ignore_member_changes"></a> [ignore\_member\_changes](#input\_ignore\_member\_changes) | Should member changes be ignored when updating the groups? | `bool` | `false` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix to add before the 'descriptive name' portion of a group name | `string` | `""` | no |
| <a name="input_resource_prefix"></a> [resource\_prefix](#input\_resource\_prefix) | Prefix to use for azure ad resources | `string` | n/a | yes |
| <a name="input_skip_empty_groups"></a> [skip\_empty\_groups](#input\_skip\_empty\_groups) | Should groups with no members still be provisioned? | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_group_ids"></a> [group\_ids](#output\_group\_ids) | The group IDs |
| <a name="output_group_names"></a> [group\_names](#output\_group\_names) | The group names |
| <a name="output_groups"></a> [groups](#output\_groups) | The group details |
<!-- END_TF_DOCS -->