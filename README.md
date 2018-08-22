# terraform-deploy-fargate

## A meta-module for deploying a small cluster of services to AWS ECS with Fargate

**Disclaimer** - This repo is not an _out-of-the-box_ solution for using Terraform to deploy to ECS. Instead, this repo serves as a reference for folks Googling documentation and samples on how to deploy to AWS Elastic Container Service using Fargate.

### Prerequisites

Before using this repo, make sure you've got these things:

* An AWS account with API keys
* Experience using Terraform and AWS
* General understanding around networking
* A Docker image (or 3) located in a cloud repository (I used ECR for this, Docker Hub et al would be fine too)

There's a handy Terraform wrapper-script included in this repo that helps wrap common Terraform commands and generally makes using Terraform easier. It's not required but it's very useful especially if you want to run Terraform as part of a CI/CD pipeline.

### State Files

The code in this repository does not account for the Terraform State File. By default, Terraform will generate the State File and place it in the local directory. Ideally you would want to put your State File in something like S3 rather than leaving it stored on your file system.

### Module Organization

This module consists of four distinct `.tf` files which contain Terraform resources. You could easily break each file out into it's own external Terraform Module, however I kept everything contained to a single module because it's easier to read and understand. There's also a `vars.tf` file which includes variables and parameters you'll want to change for your own solution.
