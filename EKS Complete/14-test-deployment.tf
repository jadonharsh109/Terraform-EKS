// This will deploy custom helm charts for testing purpose.
resource "helm_release" "my-release" {
  name      = "test-deployment"
  chart     = "k8s"     # Local path to the chart
  namespace = "default" # Optional: Specify namespace

  depends_on = [helm_release.aws-load-balancer-controller]
}
