// Creating IAM Role for EC2 Worker Nodes 
resource "aws_iam_role" "eks-ec2-nodes-iam-role" {
  name = "eks-ec2-nodes-iam-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

// Connecting IAM Role with Required policies to function EKS and EC2 togeather.
resource "aws_iam_role_policy_attachment" "eks-ec2-nodes-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks-ec2-nodes-iam-role.name
}

resource "aws_iam_role_policy_attachment" "eks-ec2-nodes-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks-ec2-nodes-iam-role.name
}

resource "aws_iam_role_policy_attachment" "eks-ec2-nodes-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks-ec2-nodes-iam-role.name
}

resource "aws_iam_role_policy_attachment" "eks-ec2-nodes-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks-ec2-nodes-iam-role.name
}


resource "aws_iam_role_policy_attachment" "eks-ec2-nodes-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-ec2-nodes-iam-role.name
}


resource "aws_iam_role_policy_attachment" "eks-ec2-nodes-AmazonEC2FullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
  role       = aws_iam_role.eks-ec2-nodes-iam-role.name
}

// Creating EC2 Nodes Group for EKS Clusters
resource "aws_eks_node_group" "private-nodes" {
  cluster_name    = aws_eks_cluster.eks-ec2-cluster.name
  node_group_name = "private-nodes"
  node_role_arn   = aws_iam_role.eks-ec2-nodes-iam-role.arn // Connecting Nodes Grp with IAM Role


  // Assigning Worker Nodes to Private Subnets
  subnet_ids = [
    aws_subnet.eks-ec2-private-us-east-1a.id,
    aws_subnet.eks-ec2-private-us-east-1b.id
  ]

  capacity_type  = "ON_DEMAND"
  instance_types = ["t3.large"]

  scaling_config {
    desired_size = 3
    max_size     = 5
    min_size     = 3
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    role = "general"
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks-ec2-nodes-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks-ec2-nodes-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks-ec2-nodes-AmazonEC2ContainerRegistryReadOnly, aws_eks_cluster.eks-ec2-cluster
  ]

  provisioner "local-exec" {
    when    = create
    command = "aws eks update-kubeconfig --name ${var.eks_cluster_name}" // This will pull the kubeconfig file from aws eks.
  }
}
