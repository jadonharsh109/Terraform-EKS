// Authenticating Helm to kubernetes cluster
provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.eks-fargate-cluster.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.eks-fargate-cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.eks.token
  }
}
// Installing Metrics Helms Charts to our K8s cluster
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

  depends_on = [aws_eks_fargate_profile.aws_eks_fargate]
}
