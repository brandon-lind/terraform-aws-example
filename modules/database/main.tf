# -----------------------------------------------------------------------------
# Data: Subnets & ECS execution role
# -----------------------------------------------------------------------------

data "aws_subnet_ids" "private" {
  vpc_id = "${var.vpc_id}"
  tags   = { Name = "${var.tags_name}-private-subnet" }
  depends_on = [var.aws_subnet_private_ids]
}

# -----------------------------------------------------------------------------
# Data: Security Group
# -----------------------------------------------------------------------------

resource "aws_security_group" "_" {
  tags        = { Name = "${var.tags_name}" }
  name        = "${var.stage}${var.app_name}-db"
  description = "Controls access to the DocumentDB"
  vpc_id      = "${var.vpc_id}"

  ingress {
    protocol    = "tcp"
    from_port   = 27017
    to_port     = 27017
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["10.0.0.0/16"]
  }
}

# -----------------------------------------------------------------------------
# Resources: DB Cluster
# -----------------------------------------------------------------------------

resource "aws_docdb_subnet_group" "_" {
  tags       = { Name = "${var.tags_name}" }
  name       = "${var.stage}${var.app_name}-db"
  subnet_ids = "${data.aws_subnet_ids.private.ids}"
}

resource "aws_docdb_cluster_parameter_group" "_" {
  tags   = { Name = "${var.tags_name}" }
  family = "docdb3.6"
  name   = "${var.stage}${var.app_name}-db"

  parameter {
    name  = "tls"
    value = "disabled"
  }
}

resource "aws_docdb_cluster" "_" {
  tags                    = { Name = "${var.tags_name}" }
  skip_final_snapshot     = true
  db_subnet_group_name    = "${aws_docdb_subnet_group._.name}"
  cluster_identifier      = "${var.stage}${var.app_name}-db"
  engine                  = "docdb"
  master_username         = "${var.docdb_username}"
  master_password         = "${var.docdb_password}"
  vpc_security_group_ids  = ["${aws_security_group._.id}"]
  db_cluster_parameter_group_name = "${aws_docdb_cluster_parameter_group._.name}"
}

resource "aws_docdb_cluster_instance" "_" {
  tags               = { Name = "${var.tags_name}" }
  count              = "${var.az_count}"
  identifier         = "${var.stage}${var.app_name}-${count.index}"
  cluster_identifier = "${aws_docdb_cluster._.id}"
  instance_class     = "${var.docdb_instance_class}"
}
