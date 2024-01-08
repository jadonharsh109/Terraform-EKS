// it is used in a private subnet to allow services to connect to the internet.
// important note: must make it inside the public subnets because it is required to send packets to the internet by the Internet gateway


// Creation of nat gateway requires an Public Elastic IP
resource "aws_eip" "eks-fargate-aws_eip" {
  domain = "vpc"
  tags = {
    Name = "eks-fargate-aws_eip"
  }
  depends_on = [aws_internet_gateway.eks-fargate-igw]
}

resource "aws_nat_gateway" "eks-fargate-nat" {
  allocation_id = aws_eip.eks-fargate-aws_eip.id              // Associating an Elastic IP
  subnet_id     = aws_subnet.eks-fargate-public-us-east-1a.id // Subnet must have an internet gateway as a default route

  tags = {
    Name = "eks-fargate-natgw"
  }

  depends_on = [
    aws_eip.eks-fargate-aws_eip,
    aws_internet_gateway.eks-fargate-igw
  ]
}
