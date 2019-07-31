# -----------------------------------------------------------------------------
# Variables: General
# -----------------------------------------------------------------------------

variable "awslogs_group" {
  description = "The Cloudwatch Log group"
}

variable "namespace" {
  description = "AWS resource namespace/prefix"
}

variable "region" {
  description = "AWS region"
}

variable "stage" {
  description = "Environment stage such as qa, staging, production"
}

variable "tags_name" {
  description = "The `Name` tag to apply to resources"
}

# -----------------------------------------------------------------------------
# Variables: Network
# -----------------------------------------------------------------------------

variable "az_count" {
  description = "Number of availability zones to cover in a given AWS region"
}

variable "vpc_cidr_block" {
  description = "The main cidr block for the VPC"
}

# -----------------------------------------------------------------------------
# Variables: App1
# -----------------------------------------------------------------------------

variable "app1_name" {
  description = "The name of the application to associate with network resources for App1"
}

variable "app1_image" {
  description = "Docker image to run in the ECS cluster for App1"
}

variable "app1_port" {
  description = "Port exposed by the Fargate container to redirect traffic to for App1"
}

variable "app1_port_host" {
  description = "Port exposed by the docker image for App1"
}

variable "app1_count" {
  description = "Number of docker containers to run for App1"
}

variable "app1_fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units) for App1"
}

variable "app1_fargate_memory" {
  description = "Fargate instance memory to provision (in MB) for App1"
}

# -----------------------------------------------------------------------------
# Variables: App2
# -----------------------------------------------------------------------------

variable "app2_name" {
  description = "The name of the application to associate with network resources for App2"
}

variable "app2_image" {
  description = "Docker image to run in the ECS cluster for App2"
}

variable "app2_port" {
  description = "Port exposed by the Fargate container to redirect traffic to for App2"
}

variable "app2_port_host" {
  description = "Port exposed by the docker image for App2"
}

variable "app2_count" {
  description = "Number of docker containers to run for App2"
}

variable "app2_fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units) for App2"
}

variable "app2_fargate_memory" {
  description = "Fargate instance memory to provision (in MB) for App2"
}

# -----------------------------------------------------------------------------
# Variables: Database
# -----------------------------------------------------------------------------

variable "docdb_instance_class" {
  description = "The instance size of the database cluster. See https://www.terraform.io/docs/providers/aws/r/docdb_cluster_instance.html#instance_class"
}
variable "docdb_name" {
  description = "The name of the document database"
}
variable "docdb_password" {
  description = "Password for the master DB user"
}
variable "docdb_username" {
  description = "Username for the master DB user"
}

# -----------------------------------------------------------------------------
# Variables: Web (S3, Cloudfront, Route 53, Certificate Manager, etc.)
# -----------------------------------------------------------------------------

variable "domain_name" {
  description = "The top level domain name to associate DNS records with the cloudfront distribution"
}

variable "site_name" {
  description = "The name of the website"
}

variable "tls_cert_arn" {
  description = "The ARN of the TLS/SSL certification which has been manually provisioned and approved"
}

