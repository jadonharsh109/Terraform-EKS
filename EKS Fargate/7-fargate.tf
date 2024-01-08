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


// Fargate Profile for "kube-system" namespace
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
}


// Patching CoreDNS to make it run on Fargate
data "aws_eks_cluster_auth" "eks" {
  name = aws_eks_cluster.eks-fargate-cluster.id
}


// Executing "kubectl patch ..." in local machine
resource "null_resource" "k8s_patcher" {
  depends_on = [aws_eks_fargate_profile.aws_eks_fargate]

  triggers = {
    endpoint = aws_eks_cluster.eks-fargate-cluster.endpoint
    ca_crt   = base64decode(aws_eks_cluster.eks-fargate-cluster.certificate_authority[0].data)
    token    = data.aws_eks_cluster_auth.eks.token
  }
  provisioner "local-exec" {
    command = <<EOH
cat >/tmp/ca.crt <<EOF
${base64decode(aws_eks_cluster.eks-fargate-cluster.certificate_authority[0].data)}
EOF
kubectl \
  --server="${aws_eks_cluster.eks-fargate-cluster.endpoint}" \
  --certificate_authority=/tmp/ca.crt \
  --token="${data.aws_eks_cluster_auth.eks.token}" \
  patch deployment coredns \
  -n kube-system --type json \
  -p='[{"op": "remove", "path": "/spec/template/metadata/annotations/eks.amazonaws.com~1compute-type"}]'
EOH
  }

  lifecycle {
    ignore_changes = [triggers]
  }
}


// Fargate Profile for "default" namespace
resource "aws_eks_fargate_profile" "aws_eks_fargate_default" {
  cluster_name           = var.eks_cluster_name
  fargate_profile_name   = "default"
  pod_execution_role_arn = aws_iam_role.eks-fargate-profile-role.arn
  subnet_ids = [
    aws_subnet.eks-fargate-private-us-east-1a.id, //Private Subnet
    aws_subnet.eks-fargate-private-us-east-1b.id  //Private Subnet
  ]
  selector {
    namespace = "default"
  }
  depends_on = [aws_eks_cluster.eks-fargate-cluster]
}






