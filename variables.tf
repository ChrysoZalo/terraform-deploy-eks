variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}

variable "env_name" {
  description = "Enviroment Name"
  type        = string
  default     = "dev"
}

variable "cluster_version" {
  description = "Kubernetes version to use for the EKS cluster"
  type = string
  default = "1.32"
}
