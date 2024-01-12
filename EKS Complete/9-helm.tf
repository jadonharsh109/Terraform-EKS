// Cluster authentication & autherization related information
data "aws_eks_cluster_auth" "eks" {
  name = aws_eks_cluster.eks-ec2-cluster.id
}

// Authenticating Helm to kubernetes cluster
provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.eks-ec2-cluster.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.eks-ec2-cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.eks.token
  }
}
