##################################################################################
# IAM Role
# SEE: https://docs.aws.amazon.com/dms/latest/userguide/security-iam-awsmanpol.html#security-iam-awsmanpol-AmazonDMSVPCManagementRole
# WARNING: アカウントに1つあればいいようなので外出しした方がいいかも
##################################################################################

resource "aws_iam_role" "dms_access_for_endpoint" {
  name               = "dms-access-for-endpoint"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "dms_access_for_endpoint" {
  role       = aws_iam_role.dms_access_for_endpoint.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSRedshiftS3Role"
}

resource "aws_iam_role" "dms_cloudwatch_logs_role" {
  name               = "dms-cloudwatch-logs-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "dms_cloudwatch_logs_role" {
  role       = aws_iam_role.dms_cloudwatch_logs_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSCloudWatchLogsRole"
}

resource "aws_iam_role" "dms_vpc_role" {
  name               = "dms-vpc-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "dms_vpc_role" {
  role       = aws_iam_role.dms_vpc_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSVPCManagementRole"
}

##################################################################################
# Subnet Group
##################################################################################
resource "aws_dms_replication_subnet_group" "this" {
  replication_subnet_group_id          = "${var.name_prefix}-subnet-group"
  replication_subnet_group_description = var.replication_subnet_group_description

  subnet_ids = var.replication_subnet_group_ids

  # dms-vpc-roleに依存しているため必要
  depends_on = [aws_iam_role.dms_vpc_role]
}

##################################################################################
# Endpoint
##################################################################################
resource "aws_dms_endpoint" "this" {
  for_each = var.endpoints

  endpoint_id   = each.value.endpoint_id
  endpoint_type = each.value.endpoint_type

  database_name = each.value.database_name
  server_name   = each.value.server_name

  engine_name = each.value.engine_name

  secrets_manager_access_role_arn = each.value.secrets_manager_access_role_arn
  secrets_manager_arn             = each.value.secrets_manager_arn
  username                        = each.value.username
  password                        = each.value.password
  port                            = each.value.port


  extra_connection_attributes = each.value.extra_connection_attributes

  certificate_arn = each.value.certificate_arn
  ssl_mode        = each.value.ssl_mode
}

##################################################################################
# Replication Config (For Serverless)
##################################################################################
resource "aws_dms_replication_config" "this" {
  for_each = var.replication_configs

  start_replication = each.value.start_replication

  replication_config_identifier = each.value.identifier
  resource_identifier           = each.value.identifier

  replication_type    = each.value.replication_type
  source_endpoint_arn = aws_dms_endpoint.this[each.value.source_endpoint_key].endpoint_arn
  target_endpoint_arn = aws_dms_endpoint.this[each.value.target_endpoint_key].endpoint_arn

  table_mappings       = each.value.table_mappings
  replication_settings = each.value.replication_settings

  compute_config {
    replication_subnet_group_id = aws_dms_replication_subnet_group.this.id
    vpc_security_group_ids      = each.value.compute_config.vpc_security_group_ids
    min_capacity_units          = each.value.compute_config.min_capacity_units
    max_capacity_units          = each.value.compute_config.max_capacity_units
    multi_az                    = each.value.compute_config.multi_az
  }
}
