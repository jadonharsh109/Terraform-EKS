// Creating IAM Role for EKS Cluster Service
resource "aws_iam_role" "eks-ec2-iam-role" {
  name = "eks-ec2-cluster-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}


// Connecting IAM Role with EKS Clsuter Policy
resource "aws_iam_role_policy_attachment" "eks-ec2-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-ec2-iam-role.name
}

// Creating AWS EKS Cluster
resource "aws_eks_cluster" "eks-ec2-cluster" {
  name     = "eks-ec2-cluster"
  role_arn = aws_iam_role.eks-ec2-iam-role.arn // Connecting EKS Cluster with IAM Role 

  vpc_config {
    subnet_ids = [
      aws_subnet.eks-ec2-private-us-east-1a.id,
      aws_subnet.eks-ec2-private-us-east-1b.id,
      aws_subnet.eks-ec2-public-us-east-1a.id,
      aws_subnet.eks-ec2-public-us-east-1b.id
    ]
  }

  depends_on = [aws_iam_role_policy_attachment.eks-ec2-AmazonEKSClusterPolicy,
    aws_subnet.eks-ec2-private-us-east-1a,
    aws_subnet.eks-ec2-private-us-east-1b,
    aws_subnet.eks-ec2-public-us-east-1a,
    aws_subnet.eks-ec2-public-us-east-1b,
    aws_route_table_association.private-us-east-1a,
    aws_route_table_association.private-us-east-1b,
    aws_route_table_association.public-us-east-1a,
    aws_route_table_association.public-us-east-1b,
  ]
}
