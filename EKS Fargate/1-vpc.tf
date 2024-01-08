// Custom VPC Creation
resource "aws_vpc" "eks-fargate-vpc" {
  cidr_block = var.vpc_cidr // Private IP addr range...

  // Must be Enabled for EFS to work with AWS EKS...
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "eks-fargate-vpc"
  }
}
