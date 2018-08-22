variable "az_count" {
  description = "Number of AZs to cover in a given AWS region"
  default     = "2"
}

variable "androgee_image" {
  description = "Docker image to run in the ECS cluster"
  default     = "540854239492.dkr.ecr.us-west-2.amazonaws.com/eg-repo:latest"
}

variable "egeeio_image" {
  description = "Docker image to run in the ECS cluster"
  default     = "540854239492.dkr.ecr.us-west-2.amazonaws.com/eg-website:latest"
}

variable "app_port" {
  description = "Port exposed by the docker image to redirect traffic to"
  default     = 4200
}

variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = "256"
}

variable "fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = "512"
}
