// it is used in a private subnet to allow services to connect to the internet.
// important note: must make it inside the public subnets because it is required to send packets to the internet by the Internet gateway



// Creation of nat gateway requires an Public Elastic IP
resource "aws_eip" "eks-ec2-aws_eip" {
  domain = "vpc"
  tags = {
    Name = "eks-ec2-aws_eip"
  }
  depends_on = [aws_internet_gateway.eks-ec2-igw]
}

resource "aws_nat_gateway" "eks-ec2-nat" {
  allocation_id = aws_eip.eks-ec2-aws_eip.id              // Associating an Elastic IP
  subnet_id     = aws_subnet.eks-ec2-public-us-east-1a.id // Subnet must have an internet gateway as a default route

  tags = {
    Name = "eks-ec2-nat"
  }

  depends_on = [aws_internet_gateway.eks-ec2-igw]
}
