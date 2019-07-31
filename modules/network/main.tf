# -----------------------------------------------------------------------------
# Resources: VPC and Subnets
# -----------------------------------------------------------------------------

# Fetch AZs in the current region
data "aws_availability_zones" "available" {}

resource "aws_vpc" "_" {
  tags       = { Name = "${var.tags_name}" }
  cidr_block = "${var.vpc_cidr_block}"
}

# Create var.az_count private subnets, each in a different AZ
resource "aws_subnet" "private" {
  tags              = { Name = "${var.tags_name}-private-subnet" }
  count             = "${var.az_count}"
  cidr_block        = "${cidrsubnet(aws_vpc._.cidr_block, 8, count.index)}"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  vpc_id            = "${aws_vpc._.id}"
}

# Create var.az_count public subnets, each in a different AZ
resource "aws_subnet" "public" {
  tags                    = { Name = "${var.tags_name}-public-subnet" }
  count                   = "${var.az_count}"
  cidr_block              = "${cidrsubnet(aws_vpc._.cidr_block, 8, var.az_count + count.index)}"
  availability_zone       = "${data.aws_availability_zones.available.names[count.index]}"
  vpc_id                  = "${aws_vpc._.id}"
  map_public_ip_on_launch = true
}

# -----------------------------------------------------------------------------
# Resources: Internet Gateway, Elastic IPs, and NAT Gateways
# -----------------------------------------------------------------------------

# IGW for the public subnet
resource "aws_internet_gateway" "_" {
  tags   = { Name = "${var.tags_name}" }
  vpc_id = "${aws_vpc._.id}"
}

# Route the public subnet traffic through the IGW
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc._.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway._.id}"
}

# Create a NAT gateway with an EIP for each private subnet to get internet connectivity
resource "aws_eip" "_" {
  tags       = { Name = "${var.tags_name}" }
  count      = "${var.az_count}"
  vpc        = true
  depends_on = ["aws_internet_gateway._"]
}

resource "aws_nat_gateway" "_" {
  tags          = { Name = "${var.tags_name}" }
  count         = "${var.az_count}"
  subnet_id     = "${element(aws_subnet.public.*.id, count.index)}"
  allocation_id = "${element(aws_eip._.*.id, count.index)}"
}

# Create a new route table for the private subnets
# and make it route non-local traffic through the NAT gateway to the internet
resource "aws_route_table" "private" {
  tags = { Name = "${var.tags_name}" }
  count  = "${var.az_count}"
  vpc_id = "${aws_vpc._.id}"

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${element(aws_nat_gateway._.*.id, count.index)}"
  }
}

# Explicitely associate the newly created route tables to the private subnets (so they don't default to the main route table)
resource "aws_route_table_association" "private" {
  count          = "${var.az_count}"
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
}
