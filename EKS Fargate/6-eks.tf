// Creating IAM Role for EKS Cluster Service
resource "aws_iam_role" "eks-fargate-iam-role" {
  name               = "${var.eks_cluster_name}-role"
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
resource "aws_iam_role_policy_attachment" "eks-fargate-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-fargate-iam-role.name
}


// Creating AWS EKS Cluster
resource "aws_eks_cluster" "eks-fargate-cluster" {
  name     = var.eks_cluster_name
  role_arn = aws_iam_role.eks-fargate-iam-role.arn // Connecting EKS Cluster with IAM Role 

  vpc_config {

    endpoint_private_access = false
    endpoint_public_access  = true
    public_access_cidrs     = ["0.0.0.0/0"]


    subnet_ids = [
      aws_subnet.eks-fargate-private-us-east-1a.id,
      aws_subnet.eks-fargate-private-us-east-1b.id,
      aws_subnet.eks-fargate-public-us-east-1a.id,
      aws_subnet.eks-fargate-public-us-east-1b.id
    ]
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks-fargate-AmazonEKSClusterPolicy,
    aws_route_table_association.private-us-east-1a,
    aws_route_table_association.private-us-east-1b,
    aws_route_table_association.public-us-east-1a,
    aws_route_table_association.public-us-east-1b,
  ]

  provisioner "local-exec" {
    command = "aws eks --region us-east-1 update-kubeconfig --name ${var.eks_cluster_name}"
  }
}
