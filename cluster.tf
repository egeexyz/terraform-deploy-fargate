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
    "memory": ${var.fargate_memory},
    "image": "${var.androgee_image}",
    "networkMode": "awsvpc",
    "environment": [{
      "name": "TOKEN",
      "value": ""
    }]
  }]
  DEFINITION
}

resource "aws_ecs_task_definition" "egeeio-website" {
  family                   = "egeeio-website"
  network_mode             = "awsvpc"
  task_role_arn            = "arn:aws:iam::540854239492:role/ecsTaskExecutionRole"
  execution_role_arn       = "arn:aws:iam::540854239492:role/ecsTaskExecutionRole"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "${var.fargate_cpu}"
  memory                   = "${var.fargate_memory}"

  container_definitions = <<DEFINITION
  [{
    "name": "egeeio_website_container",
    "portMappings": [{
        "containerPort": 4200,
        "protocol": "tcp"
      }],
    "cpu": ${var.fargate_cpu},
    "memory": ${var.fargate_memory},
    "image": "${var.egeeio_image}",
    "networkMode": "awsvpc"
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

resource "aws_ecs_service" "website" {
  name            = "website"
  cluster         = "${aws_ecs_cluster.main.id}"
  task_definition = "${aws_ecs_task_definition.egeeio-website.arn}"
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    assign_public_ip = true
    security_groups  = ["${aws_security_group.alb-sg-02.id}"]
    subnets          = ["${aws_subnet.public.*.id}"]
  }

  # load_balancer {
  #   target_group_arn = "${aws_alb_target_group.demo-alb-tg.id}"
  #   container_name   = "egeeio_website_container"
  #   container_port   = "4200"
  # }

  # depends_on = [
  #   "aws_alb_listener.http",
  # ]
}
