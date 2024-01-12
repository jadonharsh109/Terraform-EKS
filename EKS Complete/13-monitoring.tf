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

