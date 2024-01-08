// Private Subnets (us-east-1a)
resource "aws_subnet" "eks-fargate-private-us-east-1a" {
  vpc_id            = aws_vpc.eks-fargate-vpc.id
  cidr_block        = "10.0.0.0/19"
  availability_zone = "us-east-1a"

  tags = {
    "Name"                                          = "private-us-east-1a"
    "kubernetes.io/role/internal-elb"               = "1"     // It is used by Kubernetes to discover subnets where a private load balancer will be created
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "owned" // Required by Kubernetes cluster "eks-fargate-cluster" to discover the subnet
  }
}


// Private Subnets (us-east-1b)
resource "aws_subnet" "eks-fargate-private-us-east-1b" {
  vpc_id            = aws_vpc.eks-fargate-vpc.id
  cidr_block        = "10.0.32.0/19"
  availability_zone = "us-east-1b"

  tags = {
    "Name"                                          = "private-us-east-1b"
    "kubernetes.io/role/internal-elb"               = "1"     // It is used by Kubernetes to discover subnets where a private load balancer will be created
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "owned" // Required by Kubernetes cluster "eks-fargate-cluster" to discover the subnet
  }
}


// Public Subnets (us-east-1a)
resource "aws_subnet" "eks-fargate-public-us-east-1a" {
  vpc_id                  = aws_vpc.eks-fargate-vpc.id
  cidr_block              = "10.0.64.0/19"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true // We need public ip associate with public subnet

  tags = {
    "Name"                                          = "public-us-east-1a"
    "kubernetes.io/role/elb"                        = "1"     // It is used by Kubernetes to discover subnets where a *public* load balancer will be created
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "owned" // Required by Kubernetes cluster "eks-fargate-cluster" to discover the subnet
  }
}


// Public Subnets (us-east-1a)
resource "aws_subnet" "eks-fargate-public-us-east-1b" {
  vpc_id                  = aws_vpc.eks-fargate-vpc.id
  cidr_block              = "10.0.96.0/19"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true // We need public ip associate with public subnet

  tags = {
    "Name"                                          = "public-us-east-1b"
    "kubernetes.io/role/elb"                        = "1"     // It is used by Kubernetes to discover subnets where a *public* load balancer will be created
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "owned" // Required by Kubernetes cluster "eks-fargate-cluster" to discover the subnet
  }
}
