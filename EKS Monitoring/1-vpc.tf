resource "aws_vpc" "eks-ec2-vpc" {
  cidr_block = var.vpc_cidr // Private IP addr range...

  tags = {
    Name = "eks-ec2-vpc"
  }
}
