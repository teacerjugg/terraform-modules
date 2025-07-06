# dms-serverless

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.6 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.97.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.97.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_dms_endpoint.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dms_endpoint) | resource |
| [aws_dms_replication_config.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dms_replication_config) | resource |
| [aws_dms_replication_subnet_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dms_replication_subnet_group) | resource |
| [aws_iam_role.dms_access_for_endpoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.dms_cloudwatch_logs_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.dms_vpc_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.dms_access_for_endpoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.dms_cloudwatch_logs_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.dms_vpc_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_endpoints"></a> [endpoints](#input\_endpoints) | n/a | <pre>map(object({<br/>    endpoint_id                     = string<br/>    endpoint_type                   = string<br/>    database_name                   = optional(string)<br/>    server_name                     = optional(string)<br/>    engine_name                     = optional(string, "aurora")<br/>    secrets_manager_access_role_arn = optional(string)<br/>    secrets_manager_arn             = optional(string)<br/>    username                        = optional(string)<br/>    password                        = optional(string)<br/>    port                            = optional(number)<br/>    extra_connection_attributes     = optional(string)<br/>    certificate_arn                 = optional(string)<br/>    ssl_mode                        = optional(string, "none")<br/>  }))</pre> | `{}` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | n/a | `string` | n/a | yes |
| <a name="input_replication_configs"></a> [replication\_configs](#input\_replication\_configs) | n/a | <pre>map(object({<br/>    start_replication    = optional(bool, false)<br/>    identifier           = string<br/>    replication_type     = optional(string, "full-load-and-cdc")<br/>    source_endpoint_key  = string<br/>    target_endpoint_key  = string<br/>    table_mappings       = string<br/>    replication_settings = optional(string)<br/><br/>    compute_config = object({<br/>      vpc_security_group_ids = list(string)<br/>      min_capacity_units     = optional(number, 1)<br/>      max_capacity_units     = optional(number, 8)<br/>      multi_az               = optional(bool, false)<br/>    })<br/>  }))</pre> | `{}` | no |
| <a name="input_replication_subnet_group_description"></a> [replication\_subnet\_group\_description](#input\_replication\_subnet\_group\_description) | n/a | `string` | `"Example description"` | no |
| <a name="input_replication_subnet_group_ids"></a> [replication\_subnet\_group\_ids](#input\_replication\_subnet\_group\_ids) | n/a | `list(string)` | `[]` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
