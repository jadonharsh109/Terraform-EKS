// Installing ALB Controller using Helms Charts to our cluster.
resource "helm_release" "aws-load-balancer-controller" {
  name = "aws-load-balancer-controller"

  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.6.1" // Current Version

  set {
    name  = "clusterName"
    value = aws_eks_cluster.eks-fargate-cluster.id
  }
  set {
    name  = "image.tag"
    value = "v2.6.2" // Current Version
  }
  set {
    name  = "replicaCount"
    value = 1
  }
  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }
  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.aws_load_balancer_controller.arn
  }
  # EKS Fargate specific
  set {
    name  = "region"
    value = "us-east-1"
  }
  set {
    name  = "vpcId"
    value = aws_vpc.eks-fargate-vpc.id
  }

  depends_on = [aws_eks_fargate_profile.aws_eks_fargate]
}
