resource "aws_ecs_cluster" "main" {
  name = "test-cluster"
}

resource "aws_ecs_task_definition" "discord_bot" {
  family                   = "discord_bot"
  network_mode             = "awsvpc"
  task_role_arn            = "arn:aws:iam::540854239492:role/ecsTaskExecutionRole"
  execution_role_arn       = "arn:aws:iam::540854239492:role/ecsTaskExecutionRole"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "${var.fargate_cpu}"
  memory                   = "${var.fargate_memory}"

  container_definitions = <<DEFINITION
  [{
    "name": "discord_bot_container",
    "cpu": ${var.fargate_cpu},
    "image": "${var.app_image}",
    "memory": ${var.fargate_memory},
    "image": ${var.docker_image},
    "networkMode": "awsvpc",
    "environment": [{
      "name": "TOKEN",
      "value": "CHANGE_ME"
    }]
  }]
  DEFINITION
}

resource "aws_ecs_service" "androgee" {
  name            = "androgee"
  cluster         = "${aws_ecs_cluster.main.id}"
  task_definition = "${aws_ecs_task_definition.discord_bot.arn}"
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    assign_public_ip = true
    security_groups  = ["${aws_security_group.alb-sg-02.id}"]
    subnets          = ["${aws_subnet.private.*.id}"]
  }

  # load_balancer {
  #   target_group_arn = "${aws_alb_target_group.app.id}"
  #   container_name   = "app"
  #   container_port   = "${var.app_port}"
  # }

  # depends_on = [
  #   "aws_alb_listener.front_end",
  # ]
}
