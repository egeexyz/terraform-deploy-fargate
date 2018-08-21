resource "aws_security_group" "alb-sg" {
  name        = "demo-alb-sg"
  description = "ALB Port 80"
  vpc_id      = "${aws_vpc.demo-vpc.id}"

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
# TODO: Maybe these sgs can be merged?
resource "aws_security_group" "alb-sg-02" {
  name        = "demo-alb-sg02"
  description = "ALB Port 3000"
  vpc_id      = "${aws_vpc.demo-vpc.id}"

  ingress {
    protocol        = "tcp"
    from_port       = "${var.app_port}"
    to_port         = "${var.app_port}"
    security_groups = ["${aws_security_group.alb-sg.id}"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
