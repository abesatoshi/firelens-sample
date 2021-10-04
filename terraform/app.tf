resource "aws_lb" "example" {
  name = "satoshi-abe-example"
  load_balancer_type = "application"
  internal = false
  idle_timeout = 60
  
  subnets = [
    aws_subnet.public_0.id,
    aws_subnet.public_1.id
  ]

  security_groups = [
    aws_security_group.example.id
  ]
}

resource "aws_lb_target_group" "example" {
  name = "satoshi-abe-example"
  vpc_id = aws_vpc.example.id
  target_type = "ip"
  port = 8000
  protocol = "HTTP"
  deregistration_delay = 300

  health_check {
    path = "/"
    healthy_threshold = 5
    unhealthy_threshold = 2
    timeout = 5
    interval = 30
    matcher = 200
    port = "traffic-port"
    protocol = "HTTP"
  }

  depends_on = [
    aws_lb.example
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.example.arn
  port = 80
  protocol = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.example.arn
  }
}

resource "aws_ecs_cluster" "example" {
  name = "satoshi-abe-example"
}

resource "aws_ecs_task_definition" "example" {
  family = "satoshi-abe-example"
  cpu = 256
  memory = 512
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  container_definitions = file("./container_definitions.json")
  task_role_arn            = aws_iam_role.ecsTaskExecutionRole.arn
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
}

resource "aws_ecs_service" "example" {
  name = "satoshi-abe-example"
  cluster = aws_ecs_cluster.example.arn
  task_definition = aws_ecs_task_definition.example.arn
  desired_count = 2
  launch_type = "FARGATE"
  platform_version = "1.3.0"
  health_check_grace_period_seconds = 60

  network_configuration {
    assign_public_ip = true
    security_groups = [aws_security_group.example.id]

    subnets = [
      aws_subnet.public_0.id,
      aws_subnet.public_1.id,
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.example.arn
    container_name = "satoshi-abe-example"
    container_port = 8000
  }

  lifecycle {
    ignore_changes = [task_definition]
  }
}

output "alb_dns_name" {
  value = aws_lb.example.dns_name
}

resource "aws_cloudwatch_log_group" "for_ecs" {
  name = "/ecs/satoshi-abe-example"
  retention_in_days = 180
}