# Infrastructure

Use this project to deploy new environments or update existing environments for the application.

## Prerequisites

While this project aims to automate a majority of the infrastructure, there are some manual steps which must be taken prior to executing the plans.

- Install [Terraform](https://www.terraform.io/)
- Install the [AWS CLI](https://aws.amazon.com/cli/)

### AWS Account & Profile

Create an AWS account with the proper IAM policies.
The AWS CLI should be installed and configured on your local machine.

- Create a profile in the credentials file ~/.aws/credentials

  ```bash
    [<appname>]
    aws_access_key_id = <YOUR_ACCESS_KEY_ID_FOR_THIS_PROJECT>
    aws_secret_access_key = <YOUR_SECRET_ACCESS_KEY_FOR_THIS_PROJECT>
  ```

- Before executing any commands, make the `<appname>` project the default profile for your aws-cli commands

  ```bash
  export AWS_PROFILE=`<appname>`
  ```

### AWS Route53, Certificate Manager & S3

Prior to executing the Terraform plan, make sure the following tasks have been completed:

- Route53
  - Create a public hosted zone
    - Setup to use the Route53 public hosted zone name servers
- Certificate Manager
  - Request a TLS certificate for the domain
    - Ensure the sub-domains are defined as optional names on the certificate
    - Use DNS verification and click the button to allow automatic creation of the DNS records in Route53
- S3
  - Create a bucket named `<appname>-terraform` in S3 to use as the Terraform backend state storage
  - Turn on bucket versioning
- IAM
  - Follow the instructions (loosely) to create the [ECS Task Execution Role](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_execution_IAM_role.html)

----

## Configure Environments

- Set the variables for each environment:
  - variables-dev.tfvars
  - variables-`<replace_with_env_name>`.tfvars
- Initialize the Terraform backend in S3
  - Set the terraform backend bucket name explicitly in the /main.tf to the bucket name made in the "S3" step above
  - `terraform init`
- Create the Terraform workspaces (Note: dev uses the default workspace, so don't do this for dev)
  - `terraform workspace new <replace_with_env_name>`

----

## Apply the Configuration

The configurations should be applied to the environments by a CI/CD pipeline such as CircleCI. If you are developing new changes, use the following commands against the development environment to test your changes.

- terraform plan -var-file=variables-dev.tfvars

If the plan looks good, go ahead and apply

- terraform apply -var-file=variables-dev.tfvars
