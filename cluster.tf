resource "aws_ecs_cluster" "test_cluster" {
  name = "test-cluster"
}

resource "aws_ecs_task_definition" "discord_bot" {
  family                   = "discord_bot"
  cpu                      = 256
  memory                   = 512
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  task_role_arn            = "arn:aws:iam::540854239492:role/ecsTaskExecutionRole"
  execution_role_arn       = "arn:aws:iam::540854239492:role/ecsTaskExecutionRole"
  container_definitions = <<DEFINITION
  [
    {
      "environment": [{
        "name": "TOKEN",
        "value": "CHANGE_ME"
      }],
      "name": "discord_bot_container",
      "essential": true,
      "image": "540854239492.dkr.ecr.us-west-2.amazonaws.com/eg-repo:latest"
    }
  ]
  DEFINITION
}

resource "aws_ecs_service" "test" {
  name            = "Terraform_Test"
  cluster         = "${aws_ecs_cluster.test_cluster.id}"
  task_definition = "${aws_ecs_task_definition.discord_bot.arn}"
  desired_count   = 1
  launch_type     = "FARGATE"
#   network_configuration {
#     security_groups = ["${aws_vpc.my_vpc.default_security_group_id}"]
#     subnets         = ["${aws_subnet.private.*.id}"]
# }
  # iam_role        = "${aws_iam_role.foo.arn}"
  # depends_on      = ["aws_iam_role_policy.foo"]

  # placement_constraints {
  #   type       = "memberOf"
  #   expression = "attribute:ecs.availability-zone in [us-west-2a, us-west-2b]"
  # }
}

