resource "aws_iam_openid_connect_provider" "eks" {
  url = var.oidc_issuer_url

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    var.oidc_thumbprint
  ]
}

resource "aws_iam_policy" "cloudwatch_observability" {
  name        = "${var.project_name}-cloudwatch-observability"
  description = "Policy for CloudWatch Observability Add-on"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutRetentionPolicy",
          "xray:PutTraceSegments",
          "xray:PutTelemetryRecords",
          "cloudwatch:PutMetricData"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-cloudwatch-observability-policy"
  }
}

resource "aws_iam_role" "cloudwatch_agent" {
  name = "${var.project_name}-cloudwatch-agent"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.eks.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(var.oidc_issuer_url, "https://", "")}:sub" = "system:serviceaccount:amazon-cloudwatch:cloudwatch-agent"
            "${replace(var.oidc_issuer_url, "https://", "")}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-cloudwatch-agent-role"
  }
}