
resource "aws_eks_node_group" "nodes-instance" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "ec2-${var.node_group_name}"
  node_role_arn   = var.nodes_role_arn.arn

  version       = var.k8sversion
  subnet_ids    = var.private_subnets[*].id
  capacity_type = "ON_DEMAND"

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    role = var.nodes_role_arn.name
  }
  tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    "eks:cluster-name"                          = "${var.env_type}-cluster"
    "eks:nodegroup-name"                        = "ec2-${var.node_group_name}"
  }

}


resource "aws_eks_node_group" "spot-instance" {

  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "spot-${var.node_group_name}"
  node_role_arn   = var.nodes_role_arn.arn


  version       = var.k8sversion
  subnet_ids    = var.private_subnets[*].id
  capacity_type = "SPOT"

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }
  update_config {
    max_unavailable = 1
  }

  labels = {
    role = var.nodes_role_arn.name
  }
  tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    "eks:cluster-name"                          = "${var.env_type}-cluster"
    "eks:nodegroup-name"                        = "spot-${var.node_group_name}"
  }

}