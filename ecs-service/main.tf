# タスク実行ロール
# SEE: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#execution_role_arn
resource "aws_iam_role" "ecs_task_execution" {
  name               = "${var.name_prefix}-ecs-execution-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# SEE: https://docs.aws.amazon.com/ja_jp/AmazonECR/latest/userguide/pull-through-cache.html
resource "aws_iam_policy" "pull_through_cache" {
  count = var.enable_pull_through_cache ? 1 : 0

  name   = "${var.name_prefix}-pull-through-cache-role"
  policy = data.aws_iam_policy_document.pull_through_cache.json
}

resource "aws_iam_role_policy_attachment" "pull_through_cache" {
  count = var.enable_pull_through_cache ? 1 : 0

  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = aws_iam_policy.pull_through_cache[0].arn
}

# タスクロール
# SEE: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#task_role_arn
resource "aws_iam_role" "ecs_task" {
  name               = "${var.name_prefix}-ecs-task-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_policy" "ecs_task" {
  name   = "${var.name_prefix}-ecs-task-policy"
  path   = "/service-role/"
  policy = data.aws_iam_policy_document.ecs_task.json
}

resource "aws_iam_role_policy_attachment" "ecs_task" {
  role       = aws_iam_role.ecs_task.name
  policy_arn = aws_iam_policy.ecs_task.arn
}

resource "aws_iam_role_policy_attachment" "container_registry_read_only" {
  role       = aws_iam_role.ecs_task.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_ecs_task_definition" "this" {
  family                   = "${var.name_prefix}-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  cpu    = var.cpu
  memory = var.memory
  runtime_platform {
    cpu_architecture        = var.cpu_architecture
    operating_system_family = "LINUX"
  }

  execution_role_arn = aws_iam_role.ecs_task_execution.arn
  task_role_arn      = aws_iam_role.ecs_task.arn

  track_latest          = var.track_latest
  container_definitions = var.container_definitions
}

resource "aws_ecs_service" "this" {
  name                 = "${var.name_prefix}-service"
  cluster              = var.cluster_id
  task_definition      = aws_ecs_task_definition.this.arn
  desired_count        = 1
  launch_type          = "FARGATE"
  force_new_deployment = true

  network_configuration {
    security_groups  = var.security_group_ids
    subnets          = var.subnets
    assign_public_ip = var.assign_public_ip
  }

  # load_balancer {
  #   target_group_arn = aws_lb_target_group.teacher.arn
  #   container_name   = local.container_name
  #   container_port   = 9581
  # }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.container_name
    container_port   = var.container_port
  }
}
