##########################
## Networking Variables ##
##########################
variable "vpc_cidr" {
  description = "CIDR block for the VPC to use"
  default     = "10.0.0.0/16"
}

variable "internet_cidr" {
  description = "CIDR for internet access"
  default     = "0.0.0.0/0"
}

variable "az_count" {
  description = "Number of AZs for an AWS region. This can be used as the subnet count also."
  default     = "2"
}

variable "public_subnet_count" {
  description = "Number of public subnets for the VPC"
  default     = "2"
}

variable "private_subnet_count" {
  description = "Number of private subnets for the VPC"
  default     = "2"
}

########################
## ECS Task Variables ##
########################
variable "role_arn" {
  description = "The role arn that allows access to ECS and ECR"
  default     = "arn:aws:iam::540854239492:role/ecsTaskExecutionRole"
}
variable "task_network_mode" {
  description = "The network mode in which the ECS task runs"
  default     = "awsvpc"
}
variable "token" {
  description = "Token to connect to the Discord server"
}
variable "bot_family" {
  description = "The effective name of the task definition"
  default     = "discord_bot"
}
variable "website_family" {
  description = "The effective name of the task definition"
  default     = "website"
}
variable "game_family" {
  description = "The effective name of the task definition"
  default     = "game"
}
variable "bot_image" {
  description = "Docker image for discord-bot task in the ECS cluster"
  default     = "540854239492.dkr.ecr.us-west-2.amazonaws.com/eg-repo:latest"
}
variable "egeeio_image" {
  description = "Docker image for egeeio-website task in the ECS cluster"
  default     = "540854239492.dkr.ecr.us-west-2.amazonaws.com/eg-website:latest"
}
variable "game_image" {
  description = "Docker image for jumpdude-game task in the ECS cluster"
  default     = "540854239492.dkr.ecr.us-west-2.amazonaws.com/eg-jumper:latest"
}
variable "website_port" {
  description = "Port for egeeio-website task to expose traffic to"
  default     = 4200
}
variable "game_port" {
  description = "Port for jumpdude-game task to expose traffic to"
  default     = 8080
}
variable "discord_bot_cpu" {
  description = "discord-bot task instance CPU units to provision (0.25 vCPU = 256 CPU units)"
  default     = "256"
}
variable "game_cpu" {
  description = "game task instance CPU units to provision (0.25 vCPU = 256 CPU units)"
  default     = "256"
}
variable "website_cpu" {
  description = "website task instance CPU units to provision (0.25 vCPU = 256 CPU units)"
  default     = "256"
}
variable "website_memory" {
  description = "website task instance instance memory to provision in MiB"
  default     = "512"
}
variable "discord_bot_memory" {
  description = "discord-bot task instance instance memory to provision in MiB"
  default     = "512"
}
variable "game_memory" {
  description = "game task instance instance memory to provision in MiB"
  default     = "512"
}
