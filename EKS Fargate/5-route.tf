// Private Route Table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.eks-fargate-vpc.id
  route {
    cidr_block     = "0.0.0.0/0"                        // Allow all ipv4 addr to connect with route table
    nat_gateway_id = aws_nat_gateway.eks-fargate-nat.id // Forward the request to NAT GW to make private connection
  }
  tags = {
    Name = "private"
  }
  depends_on = [aws_nat_gateway.eks-fargate-nat]
}


// Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.eks-fargate-vpc.id
  route {
    cidr_block = "0.0.0.0/0"                             // Allow all ipv4 addr to connect with route table
    gateway_id = aws_internet_gateway.eks-fargate-igw.id // Forward the request to Internet GW to make public connection
  }
  tags = {
    Name = "public"
  }
  depends_on = [aws_internet_gateway.eks-fargate-igw]
}


// Allocating Private Route Table with Subnet to make Private Subnet
resource "aws_route_table_association" "private-us-east-1a" {
  subnet_id      = aws_subnet.eks-fargate-private-us-east-1a.id //Private Subnet (us-east-1a)
  route_table_id = aws_route_table.private.id                   //Private Route Table (with NAT)
  depends_on     = [aws_route_table.private]
}

resource "aws_route_table_association" "private-us-east-1b" {
  subnet_id      = aws_subnet.eks-fargate-private-us-east-1b.id //Private Subnet (us-east-1b)
  route_table_id = aws_route_table.private.id                   //Private Route Table (with NAT)
  depends_on     = [aws_route_table.private]
}

// Allocating Public Route Table with Subnet to make Public Subnet

resource "aws_route_table_association" "public-us-east-1a" {
  subnet_id      = aws_subnet.eks-fargate-public-us-east-1a.id //Public Subnet (us-east-1a)
  route_table_id = aws_route_table.public.id                   //Public Route Table (with IGW)
  depends_on     = [aws_route_table.public]
}

resource "aws_route_table_association" "public-us-east-1b" {
  subnet_id      = aws_subnet.eks-fargate-public-us-east-1b.id //Public Subnet (us-east-1b)
  route_table_id = aws_route_table.public.id                   //Public Route Table (with IGW)
  depends_on     = [aws_route_table.public]
}
