# terraform-deploy-fargate

## A meta-module for deploying a small cluster of services to AWS ECS with Fargate

**Disclaimer** - This repo is not an _out-of-the-box_ solution for using Terraform to deploy to ECS. It serves as a reference for folks Googling docs and samples on how to do it as, it's not terribly easy the first (or sixth) time doing it.

### Prerequisites

Before using this repo, make sure you've got these things:

* An AWS account with API keys
* Experience using Terraform and AWS
* General understanding around networking
* A Docker image (or 3) located in a cloud repository (I used ECR for this, Docker Hub et al would be fine too)
* A shell that is Unix-friendly
