##########################################
## This file contains the ECS cluster     #
## and the ECS task definitions            #
## and the ECS service definitions.         #
##                                           #
## Each of these could be tf modules, 3 total #
################################################
resource "aws_ecs_cluster" "demo-cluster" {
  name = "demo-cluster"
}
resource "aws_ecs_task_definition" "discord-bot" {
  family                   = "${var.bot_family}"
  network_mode             = "awsvpc"
  task_role_arn            = "${var.role_arn}"
  execution_role_arn       = "${var.role_arn}"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "${var.discord_bot_cpu}"
  memory                   = "${var.discord_bot_memory}"

  container_definitions = <<DEFINITION
  [{
    "name": "${var.bot_family}-container",
    "cpu": ${var.discord_bot_cpu},
    "memory": ${var.discord_bot_memory},
    "image": "${var.bot_image}",
    "networkMode": "awsvpc",
    "environment": [{
      "name": "TOKEN",
      "value": "${var.token}"
    }]
  }]
  DEFINITION
}
resource "aws_ecs_task_definition" "egeeio-website" {
  family                   = "${var.website_family}"
  network_mode             = "awsvpc"
  task_role_arn            = "${var.role_arn}"
  execution_role_arn       = "${var.role_arn}"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "${var.website_cpu}"
  memory                   = "${var.website_memory}"

  container_definitions = <<DEFINITION
  [{
    "name": "${var.website_family}-container",
    "portMappings": [{
        "containerPort": 4200,
        "protocol": "tcp"
      }],
    "cpu": ${var.website_cpu},
    "memory": ${var.website_memory},
    "image": "${var.egeeio_image}",
    "networkMode": "awsvpc"
  }]
  DEFINITION
}
resource "aws_ecs_task_definition" "jumpdude-game" {
  family                   = "${var.game_family}"
  network_mode             = "awsvpc"
  task_role_arn            = "${var.role_arn}"
  execution_role_arn       = "${var.role_arn}"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "${var.game_cpu}"
  memory                   = "${var.game_memory}"

  container_definitions = <<DEFINITION
  [{
    "name": "${var.game_family}-container",
    "portMappings": [{
        "containerPort": 8080,
        "protocol": "tcp"
      }],
    "cpu": ${var.game_cpu},
    "memory": ${var.game_memory},
    "image": "${var.game_image}",
    "networkMode": "awsvpc"
  }]
  DEFINITION
}
resource "aws_ecs_service" "bot" {
  name            = "${var.bot_family}-service"
  cluster         = "${aws_ecs_cluster.demo-cluster.id}"
  task_definition = "${aws_ecs_task_definition.discord-bot.arn}"
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    assign_public_ip = true
    security_groups  = ["${aws_security_group.website-sg.id}"]
    subnets          = ["${aws_subnet.private.*.id}"]
  }
}
resource "aws_ecs_service" "game" {
  depends_on = [ "aws_alb_listener.http" ]
  name            = "${var.game_family}-service"
  cluster         = "${aws_ecs_cluster.demo-cluster.id}"
  task_definition = "${aws_ecs_task_definition.jumpdude-game.arn}"
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    assign_public_ip = true
    security_groups  = ["${aws_security_group.jumpdude-sg.id}"]
    subnets          = ["${aws_subnet.public.*.id}"]
  }
  load_balancer {
    target_group_arn = "${aws_alb_target_group.demo-game-tg.id}"
    container_name   = "${var.game_family}-container"
    container_port   = 8080 
  }
}
resource "aws_ecs_service" "website" {
  depends_on = [ "aws_alb_listener.http" ]
  name            = "${var.website_family}-service"
  cluster         = "${aws_ecs_cluster.demo-cluster.id}"
  task_definition = "${aws_ecs_task_definition.egeeio-website.arn}"
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    assign_public_ip = true
    security_groups  = ["${aws_security_group.website-sg.id}"]
    subnets          = ["${aws_subnet.public.*.id}"]
  }

  load_balancer {
    target_group_arn = "${aws_alb_target_group.demo-alb-tg.id}"
    container_name   = "${var.website_family}-container"
    container_port   = 4200 
  }
}
