resource "aws_alb" "demo-alb" {
  name            = "demo-alb"
  subnets         = ["${aws_subnet.public.*.id}"]
  security_groups = ["${aws_security_group.alb-sg.id}"]
}

resource "aws_alb_target_group" "demo-alb-tg" {
  name        = "demo-alb-tg"
  port        = 4200
  protocol    = "HTTP"
  vpc_id      = "${aws_vpc.demo-vpc.id}"
  target_type = "ip"
  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    matcher             = "200,304"
    path                = "/"
    port                = "4200"
    protocol            = "HTTP"
    timeout             = "5"
    unhealthy_threshold = "3"
  }
}

resource "aws_alb_target_group" "demo-game-tg" {
  name        = "demo-game-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = "${aws_vpc.demo-vpc.id}"
  target_type = "ip"
  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    matcher             = "200,304"
    path                = "/"
    port                = "8080"
    protocol            = "HTTP"
    timeout             = "5"
    unhealthy_threshold = "3"
  }
}

resource "aws_alb_listener" "http" {
  load_balancer_arn = "${aws_alb.demo-alb.id}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.demo-alb-tg.id}"
    type             = "forward"
  }
}

resource "aws_alb_listener" "game" {
  load_balancer_arn = "${aws_alb.demo-alb.id}"
  port              = "8080"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.demo-game-tg.id}"
    type             = "forward"
  }
}
