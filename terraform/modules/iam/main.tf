resource "aws_iam_user" "iam_user" {
  name = "terraform-user"
}

resource "aws_iam_user_policy_attachment" "readonly" {
  user       = aws_iam_user.iam_user.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_policy" "iam_put_bucket" {
  name        = "bedrock-assets-upload-policy"
  description = "Allow IAM user to upload objects to bedrock-assets-1174"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "s3:PutObject",
          "s3:PutObjectAcl"
        ]
        Resource = "${var.s3_bucket_arn}/*"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "attach_upload" {
  name       = "attach-upload-policy"
  policy_arn = aws_iam_policy.iam_put_bucket.arn
  users      = [aws_iam_user.iam_user.name]
}

resource "aws_iam_access_key" "credentials" {
  user = aws_iam_user.iam_user.name
}

resource "aws_iam_user_login_profile" "credentials" {
  user                    = aws_iam_user.iam_user.name
  password_reset_required = false
}

#resource "kubernetes_config_map" "aws_auth" {
 #  name      = "aws-auth"
  #  namespace = "kube-system"
  #}

  #data = {
   # mapUsers = yamlencode([
    #  {
     #   userarn  = aws_iam_user.iam_user.arn
      #  username = "bedrock-assets-1174"
       # groups   = ["view"]  
      #}
    #])
  #}
#}