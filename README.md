# terraform-deploy-fargate

## A meta-module for deploying a small cluster of services to AWS ECS with Fargate

**Disclaimer** - This repo is not an _out-of-the-box_ solution for using Terraform to deploy to ECS. Instead, this repo serves as a reference for folks Googling documentation and samples on how to deploy to AWS Elastic Container Service using Fargate.

### Prerequisites

Before using this repo, make sure you've got these things:

* An AWS account with API keys
* Experience using Terraform and AWS
* General understanding around networking
* A Docker image (or 3) located in a cloud repository (I used ECR for this, Docker Hub et al would be fine too)

There's a handy Terraform wrapper-script included in this repo that helps wrap common Terraform commands and generally makes using Terraform easier. It's not required but it's very useful, especially if you want to run Terraform as part of a CI/CD pipeline.

### State Files

The code in this repository does not account for the Terraform State File. By default, Terraform will generate the State File and place it in the local directory. Ideally you would want to put your State File in something like S3 rather than leaving it stored on your file system.

### Module Organization

This module consists of four distinct `.tf` files which contain Terraform resources. You could easily break each file out into it's own external Terraform Module, however I kept everything contained to a single module because it's easier to read and understand. There's also a `vars.tf` file which includes variables and parameters you'll want to change for your own solution.

#### network.tf

Networking and VPCs are the canonical entry point to an application in AWS, and this file contains everything pertaining to the networking plumbing required for your ECS resources to communicate. The defaults are:

* Two availability zones
* Two distinct subnets (Public and Private)
* A NAT-Gateway for each public subnet
  * A route table to associate the private subnets with the NAT
* An Elastic IP for each availability zone
  * Attached to the same Internet Gateway

#### alb.tf

This file contains a single Application Load Balancer, associated with the public subnet, two target groups, and two ALB listeners. The defaults are:

* A standard Application Load Balancer (Classic Load Balancers aren't supported well)
* Target Groups use `target_type=ip`
* Target Groups use HTTP
  * ALB Listeners also
* Target Group ports are hardcoded because Terraform is weird with strings and ints (extra vars can resolve this)
  * ALB Listeners also

#### security.tf

This file consists of three security groups that are required for ECS services to communicate with one another and with the outside world. The defaults are:

* A security group specifically for the ALB
  * Ingress rules for each world-facing port
* A security group for each service requiring outside connection (proxied by the ALB)

#### cluster.tf

This file contains the Elastic Container Service cluster, the ECS task definitions, and the ECS service definitions. The task and service definitions are specific for my particular use case when crafting this reference module. The resulting services are:

* [Website](https://github.com/Egeeio/egeeio-website/tree/emberjs) running on EmberJS in development mode
* NodeJS webserver serving up a [game](https://github.com/egee-irl/jumper) written with PhaserJS
* [Discord bot](https://github.com/Egeeio/suzy/tree/typescript) written in TypeScript connecting to my Discord server

Each of these services have their own CI/CD pipelines that create Docker images which are stored in ECR as a result of the creation of a Git tag. You can view the repositories of each service by clicking on the links above.

These resources can and should be broken up into resources. The defaults are:

* A single ECS Cluster
* Each task definition:
  * uses `awsvpc` networking mode
  * uses `FARGATE` capabilities
  * is associated with an existing role ARN (ECS creates this for you, but you could create your own)
* Each service definition:
  * uses the `FARGATE` launch type
  * is associated with exactly one task definition
* The website service definition has a desired count of 2 to span availability zones
* Ports are hardcoded because Terraform is weird with strings and ints (extra vars can resolve this)

#### vars.tf

This file contains variables that can act as parameters to dynamically configure your application on ECS. Examine and modify to suit your needs.

### Continuous Delivery Pipeline

This repository also has a very basic sample of what a Terraform CD pipeline would look like running on a managed service such as TravisCI.

Deployments to AWS are triggered via Git tags using the `deploy` section in the `.travis.yml` file. While this isn't required, it is a handy recommendation otherwise a deploy would happen each time code is checked into the repository.

A fixed version of Terraform is downloaded, extracted, and run on the Travis runner. The Terraform version is important because Terraform isn't often backwards compatible and if a new version is released, you may discover your infrastructure or state file is in a weird state.

The `terraform.sh` script is used with the -auto-approve flag so that the deployment can happen without any user intervention (which would be undesirable, especially on a managed service). The helper script also outputs to a log file which is retrievable on the build runner.

**Disclaimer** This CI/CD pipeline does not account for the tf State File! If you want to run Terraform in an automated fashion, you must use a provider for your State File so that it's stored in a reasonable place such as S3. With this simple pipeline, the State File will be stored on the Travis runner which is inconvenient to say the least.
