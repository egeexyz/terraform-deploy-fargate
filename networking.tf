data "aws_availability_zones" "avail_zones" {}

resource "aws_vpc" "demo-vpc" {
  cidr_block           = "10.0.0.0/16"
}

resource "aws_subnet" "private" {
  count             = "2"
  cidr_block        = "${cidrsubnet(aws_vpc.demo-vpc.cidr_block, 8, count.index)}"
  availability_zone = "${data.aws_availability_zones.avail_zones.names[count.index]}"
  vpc_id            = "${aws_vpc.demo-vpc.id}"
}

resource "aws_subnet" "public" {
  count                   = "2"
  cidr_block              = "${cidrsubnet(aws_vpc.demo-vpc.cidr_block, 8, "${var.az_count}" + count.index)}"
  availability_zone       = "${data.aws_availability_zones.avail_zones.names[count.index]}"
  vpc_id                  = "${aws_vpc.demo-vpc.id}"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "demo-igw" {
  vpc_id = "${aws_vpc.demo-vpc.id}"
}

resource "aws_route" "demo-routetable" {
  route_table_id         = "${aws_vpc.demo-vpc.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.demo-igw.id}"
}

resource "aws_eip" "demo-elasticip" {
  count      = "${var.az_count}"
  vpc        = true
  depends_on = ["aws_internet_gateway.demo-igw"]
}

resource "aws_nat_gateway" "demo-nat" {
  count         = "${var.az_count}"
  subnet_id     = "${element(aws_subnet.public.*.id, count.index)}"
  allocation_id = "${element(aws_eip.demo-elasticip.*.id, count.index)}"
}

resource "aws_route_table" "private" {
  count  = "${var.az_count}"
  vpc_id = "${aws_vpc.demo-vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${element(aws_nat_gateway.demo-nat.*.id, count.index)}"
  }
}

resource "aws_route_table_association" "private" {
  count          = "${var.az_count}"
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
}
