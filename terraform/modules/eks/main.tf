resource "aws_eks_cluster" "pb_eks_cluster" {
  name     = "${var.project_name}-eks-cluster"
  role_arn = aws_iam_role.pb_eks_role.arn

  vpc_config {
    subnet_ids              = concat(var.private_subnet_ids, var.public_subnet_ids)
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
  subnet_ids      = var.private_subnet_ids

  scaling_config {
    desired_size = 4
    max_size     = 6
    min_size     = 2
  }

  update_config {
    max_unavailable = 1
  }

  instance_types = var.instance_type
  depends_on = [
    aws_iam_role_policy_attachment.pb_eks_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.pb_eks_AmazonEKS_CNI_Policy,
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

# Data source to get the OIDC provider URL
data "aws_iam_openid_connect_provider" "eks_oidc" {
  url = aws_eks_cluster.pb_eks_cluster.identity[0].oidc[0].issuer
}

# Extract OIDC provider ID from the URL
locals {
  oidc_provider_arn = data.aws_iam_openid_connect_provider.eks_oidc.arn
  oidc_provider_id  = element(split("/", data.aws_iam_openid_connect_provider.eks_oidc.url), length(split("/", data.aws_iam_openid_connect_provider.eks_oidc.url)) - 1)
}

# IAM role for EBS CSI Driver
resource "aws_iam_role" "ebs_csi_driver_role" {
  name = "AmazonEKS_EBS_CSI_DriverRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = local.oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(aws_eks_cluster.pb_eks_cluster.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:kube-system:ebs-csi-controller-sa"
            "${replace(aws_eks_cluster.pb_eks_cluster.identity[0].oidc[0].issuer, "https://", "")}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-ebs-csi-driver-role"
  }
}

# Attach AWS managed policy for EBS CSI Driver
resource "aws_iam_role_policy_attachment" "ebs_csi_driver_policy" {
  role       = aws_iam_role.ebs_csi_driver_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

# EBS CSI Driver Addon
resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name             = aws_eks_cluster.pb_eks_cluster.name
  addon_name               = "aws-ebs-csi-driver"
  service_account_role_arn = aws_iam_role.ebs_csi_driver_role.arn

  depends_on = [
    aws_eks_node_group.pb_eks_node_group,
    aws_iam_role_policy_attachment.ebs_csi_driver_policy
  ]

  tags = {
    Name = "${var.project_name}-ebs-csi-driver"
  }
}