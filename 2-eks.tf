locals {
  cluster_name = "eks-aws-lb"
}

resource "aws_iam_role" "controlplane" {
  name_prefix = "${local.cluster_name}-"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.controlplane.name
}

resource "aws_iam_role_policy_attachment" "service_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.controlplane.name
}

resource "aws_eks_cluster" "cluster" {
  name     = local.cluster_name
  version  = "1.27"
  role_arn = aws_iam_role.controlplane.arn

  vpc_config {
    subnet_ids = concat(
      module.vpc.public_subnets,
      module.vpc.private_subnets
    )
    #endpoint_private_access = true
    #public_access_cidrs     = ["76.153.164.196/32"]
  }

  depends_on = [
    module.vpc,
    aws_iam_role_policy_attachment.cluster_policy,
    aws_iam_role_policy_attachment.service_policy
  ]
}

