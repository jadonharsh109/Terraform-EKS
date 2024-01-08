resource "aws_internet_gateway" "eks-fargate-igw" {
  vpc_id = aws_vpc.eks-fargate-vpc.id //Connecting IGW to VPC

  tags = {
    Name = "eks-fargate-igw"
  }
}
