resource "aws_eks_cluster" "pb_eks_cluster" {
  name     = "${var.project_name}-eks-cluster"
  role_arn = aws_iam_role.pb_eks_role.arn

  vpc_config {
    subnet_ids              = var.pb_private_subnets_ids
    security_group_ids      = [var.pb_sg_id]
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  enabled_cluster_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  depends_on = [
    aws_iam_role_policy_attachment.pb_eks_AmazonEKSClusterPolicy
 ]

  tags = {
    Name = "${var.project_name}-cluster"
  }
}

resource "aws_iam_role" "pb_eks_role" {
  name = "${var.project_name}-eks-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "pb_eks_AmazonEKSClusterPolicy" {
  role       = aws_iam_role.pb_eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_eks_node_group" "pb_eks_node_group" {
  cluster_name    = aws_eks_cluster.pb_eks_cluster.name
  node_group_name = "${var.project_name}-node-group"
  node_role_arn   = aws_iam_role.pb_eks_node_role.arn
  subnet_ids      = aws_subnet.pb_private_subnet[*].id

  scaling_config {
    desired_size = 2
    max_size     = 4
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  instance_types = var.instance_types
  depends_on = [
    aws_iam_role_policy_attachment.pb_eks_AmazonEKSWorkerNodePolicy
    aws_iam_role_policy_attachment.pb_eks_AmazonEKS_CNI_Policy
    aws_iam_role_policy_attachment.pb_eks_AmazonEC2ContainerRegistryReadOnly
  ]

  tags = {
    Name = "${var.project_name}-node-group"
  }
}

resource "aws_iam_role" "pb_eks_node_role" {
  name = "${var.project_name}-eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "pb_eks_AmazonEKSWorkerNodePolicy" {
  role       = aws_iam_role.pb_eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "pb_eks_AmazonEKS_CNI_Policy" {
  role       = aws_iam_role.pb_eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "pb_eks_AmazonEC2ContainerRegistryReadOnly" {
  role       = aws_iam_role.pb_eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}
