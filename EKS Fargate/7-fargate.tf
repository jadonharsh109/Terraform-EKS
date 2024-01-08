// AWS Role Required for Fargate 
resource "aws_iam_role" "eks-fargate-profile-role" {
  name = "eks-fargate-profile-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks-fargate-pods.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}


// Associating Required Policy to Fargate Role
resource "aws_iam_role_policy_attachment" "fargate-AmazonEKSFargatePodExecutionRolePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.eks-fargate-profile-role.name
  depends_on = [aws_iam_role.eks-fargate-profile-role]
}


// Fargate Profile 
resource "aws_eks_fargate_profile" "aws_eks_fargate" {
  cluster_name           = var.eks_cluster_name
  fargate_profile_name   = "kube-system"
  pod_execution_role_arn = aws_iam_role.eks-fargate-profile-role.arn
  subnet_ids = [
    aws_subnet.eks-fargate-private-us-east-1a.id, //Private Subnet
    aws_subnet.eks-fargate-private-us-east-1b.id  //Private Subnet
  ]

  selector {
    namespace = "kube-system"
  }

  depends_on = [aws_eks_cluster.eks-fargate-cluster]

  provisioner "local-exec" {
    command = "./coredns.sh"
  }

}



