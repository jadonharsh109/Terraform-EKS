variable "access_key" {
  type = string
}

variable "secret_key" {
  type = string
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "eks_cluster_name" {
  type    = string
  default = "eks-complete-cluster"
}

variable "eks_cluster_version" {
  type    = string
  default = "1.28"
}

