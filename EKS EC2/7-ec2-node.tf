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
    desired_size = 20
    max_size     = 70
    min_size     = 0
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    role = "general"
  }

  # taint {
  #   key    = "team"
  #   value  = "devops"
  #   effect = "NO_SCHEDULE"
  # }

  # launch_template {
  #   name    = aws_launch_template.eks-with-disks.name
  #   version = aws_launch_template.eks-with-disks.latest_version
  # }

  depends_on = [
    aws_iam_role_policy_attachment.eks-ec2-nodes-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks-ec2-nodes-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks-ec2-nodes-AmazonEC2ContainerRegistryReadOnly, aws_eks_cluster.eks-ec2-cluster
  ]
  provisioner "local-exec" {
    when    = create
    command = "aws eks update-kubeconfig --name eks-ec2-cluster"
  }
}

# resource "aws_launch_template" "eks-with-disks" {
#   name = "eks-with-disks"

#   key_name = "local-provisioner"

#   block_device_mappings {
#     device_name = "/dev/xvdb"

#     ebs {
#       volume_size = 50
#       volume_type = "gp2"
#     }
#   }
# }
