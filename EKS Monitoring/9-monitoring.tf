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

resource "helm_release" "metrics-server" {
  name = "metrics-server"

  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  namespace  = "kube-system"
  version    = "3.8.2"

  set {
    name  = "metrics.enabled"
    value = false
  }

  depends_on = [aws_eks_node_group.private-nodes]
}


resource "helm_release" "prometheus" {
  depends_on       = [aws_eks_node_group.private-nodes]
  name             = "prometheus"
  namespace        = "prometheus"
  chart            = "kube-prometheus-stack"
  repository       = "https://prometheus-community.github.io/helm-charts"
  version          = "45.7.1"
  create_namespace = true

  set {
    name  = "podSecurityPolicy.enabled"
    value = true
  }

  set {
    name  = "server.persistentVolume.enabled"
    value = false
  }
}

