# -----------------------------------------------------------------------------
# Data: Subnets & ECS execution role
# -----------------------------------------------------------------------------

data "aws_subnet_ids" "private" {
  vpc_id = "${var.vpc_id}"
  tags   = { Name = "${var.tags_name}-private-subnet" }
  depends_on = [var.aws_subnet_private_ids]
}

data "aws_subnet_ids" "public" {
  vpc_id = "${var.vpc_id}"
  tags   = { Name = "${var.tags_name}-public-subnet" }
  depends_on = [var.aws_subnet_public_ids]
}

# See: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_execution_IAM_role.html
data "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
}

data "aws_alb" "app2" {
  arn = "${var.app2_alb_arn}"
  depends_on = [var.app2_alb_arn]
}

# -----------------------------------------------------------------------------
# Resources: Security groups
# -----------------------------------------------------------------------------

# ALB Security group
# This is the group you need to edit to restrict access to the application
resource "aws_security_group" "alb" {
  tags        = { Name = "${var.tags_name}" }
  name        = "${var.stage}${var.app_name}-alb"
  description = "Controls access to the ALB"
  vpc_id      = "${var.vpc_id}"

  ingress {
    protocol    = "tcp"
    from_port   = "${var.app_port}"
    to_port     = "${var.app_port}"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Traffic to the ECS Cluster should only come from the ALB
resource "aws_security_group" "ecs_tasks" {
  tags        = { Name = "${var.tags_name}" }
  name        = "${var.stage}${var.app_name}-ecs-tasks"
  description = "Allow inbound access from the ALB only"
  vpc_id      = "${var.vpc_id}"

  ingress {
    protocol        = "tcp"
    from_port       = "${var.app_port_host}"
    to_port         = "${var.app_port_host}"
    security_groups = ["${aws_security_group.alb.id}"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# -----------------------------------------------------------------------------
# Resources: Application load balancer and target group
# -----------------------------------------------------------------------------

resource "aws_alb" "_" {
  tags            = { Name = "${var.tags_name}" }
  name            = "${var.stage}${var.app_name}-ecs-alb"
  subnets         = "${data.aws_subnet_ids.public.ids}"
  security_groups = ["${aws_security_group.alb.id}"]
}

resource "aws_alb_target_group" "_" {
  tags        = { Name = "${var.tags_name}" }
  name        = "${var.stage}${var.app_name}-ecs-alb"
  port        = "${var.app_port}"
  protocol    = "HTTP"
  vpc_id      = "${var.vpc_id}"
  target_type = "ip"
}

# Redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "_" {
  load_balancer_arn = "${aws_alb._.id}"
  port              = "${var.app_port}"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group._.id}"
    type             = "forward"
  }
}

# -----------------------------------------------------------------------------
# Resources: ECS (Fargate)
# -----------------------------------------------------------------------------

resource "aws_ecs_cluster" "_" {
  tags = { Name = "${var.tags_name}" }
  name = "${var.stage}${var.app_name}-ecs-cluster"
}

resource "aws_ecs_task_definition" "_" {
  tags                     = { Name = "${var.tags_name}" }
  family                   = "${var.app_name}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "${var.fargate_cpu}"
  memory                   = "${var.fargate_memory}"
  execution_role_arn       = "${data.aws_iam_role.ecs_task_execution_role.arn}"

  container_definitions = <<DEFINITION
  [
    {
      "cpu": ${var.fargate_cpu},
      "image": "${var.app_image}",
      "memory": ${var.fargate_memory},
      "name": "${var.stage}${var.app_name}-service",
      "networkMode": "awsvpc",
      "portMappings": [
        {
          "containerPort": ${var.app_port_host},
          "hostPort": ${var.app_port_host}
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${var.awslogs_group}",
          "awslogs-region": "${var.region}",
          "awslogs-stream-prefix": "ecs"
        }
      },
      "environment": [
        {
          "name": "APP2URI", "value": "${data.aws_alb.app2.dns_name}"
        }
      ]
    }
  ]
  DEFINITION
}

resource "aws_ecs_service" "_" {
  name            = "${var.stage}${var.app_name}-ecs-service"
  cluster         = "${aws_ecs_cluster._.id}"
  task_definition = "${aws_ecs_task_definition._.arn}"
  desired_count   = "${var.app_count}"
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = ["${aws_security_group.ecs_tasks.id}"]
    subnets         = "${data.aws_subnet_ids.private.ids}"
  }

  load_balancer {
    target_group_arn = "${aws_alb_target_group._.id}"
    container_name   = "${var.stage}${var.app_name}-service"
    container_port   = "${var.app_port_host}"
  }

  depends_on = [
    "aws_alb_listener._"
  ]
}
