#-----------------------------------------------------------------------------
# TERRAFORM STATE
#-----------------------------------------------------------------------------

terraform {
  backend "s3" {
    bucket = "ls-lindsft-example-terraform"
    key    = "environments/terraform.tfstate"
    region = "us-east-1"
  }
}

#-----------------------------------------------------------------------------
# PROVIDERS
#-----------------------------------------------------------------------------

provider "aws" {
  region  = var.region
  version = "~> 2.18"
}

#-----------------------------------------------------------------------------
# DATA
#-----------------------------------------------------------------------------

data "aws_caller_identity" "_" {
}

#-----------------------------------------------------------------------------
# MODULES
#-----------------------------------------------------------------------------

module "network" {
  source = "./modules/network"

  az_count       = var.az_count
  region         = var.region
  tags_name      = var.tags_name
  vpc_cidr_block = var.vpc_cidr_block
}

module "app1" {
  source = "./modules/app1"

  app_count      = var.app1_count
  app_name       = var.app1_name
  app_image      = var.app1_image
  app_port       = var.app1_port
  app_port_host  = var.app1_port_host
  awslogs_group  = var.awslogs_group
  az_count       = var.az_count
  fargate_cpu    = var.app1_fargate_cpu
  fargate_memory = var.app1_fargate_memory
  site_name      = var.site_name
  stage          = var.stage
  region         = var.region
  tags_name      = var.tags_name
  vpc_id         = module.network.aws_vpc___id
  app2_alb_arn   = module.app2.app_alb_arn
  aws_subnet_private_ids = module.network.aws_subnet_private_ids
  aws_subnet_public_ids  = module.network.aws_subnet_public_ids
}

module "app2" {
  source = "./modules/app2"

  app_count      = var.app2_count
  app_name       = var.app2_name
  app_image      = var.app2_image
  app_port       = var.app2_port
  app_port_host  = var.app2_port_host
  awslogs_group  = var.awslogs_group
  az_count       = var.az_count
  fargate_cpu    = var.app2_fargate_cpu
  fargate_memory = var.app2_fargate_memory
  site_name      = var.site_name
  stage          = var.stage
  region         = var.region
  tags_name      = var.tags_name
  vpc_id         = module.network.aws_vpc___id
  aws_subnet_private_ids = module.network.aws_subnet_private_ids
  aws_subnet_public_ids  = module.network.aws_subnet_public_ids
}

// module "database" {
//   source = "./modules/database"

//   az_count       = var.az_count
//   docdb_instance_class = var.docdb_instance_class
//   docdb_name     = var.docdb_name
//   docdb_password = var.docdb_password
//   docdb_username = var.docdb_username
//   stage          = var.stage
//   tags_name      = var.tags_name
//   vpc_id         = module.network.aws_vpc___id
//   aws_subnet_private_ids = module.network.aws_subnet_private_ids
//   aws_subnet_public_ids  = module.network.aws_subnet_public_ids
// }

// module.web
// module "web" {
//   source = "./modules/web"

//   region       = var.region
//   site_name    = var.site_name
//   tls_cert_arn = var.tls_cert_arn
// }