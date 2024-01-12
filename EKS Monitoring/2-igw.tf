resource "aws_internet_gateway" "eks-ec2-igw" {
  vpc_id = aws_vpc.eks-ec2-vpc.id //Connecting IGW to VPC

  tags = {
    Name = "eks-ec2-igw"
  }
}
