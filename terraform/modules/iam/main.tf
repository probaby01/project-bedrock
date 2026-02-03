resource "aws_iam_user" "iam_user" {
  name = "bedrock-dev-view"
}

resource "aws_iam_user_policy_attachment" "readonly" {
  user       = aws_iam_user.iam_user.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_access_key" "credentials" {
  user = aws_iam_user.iam_user.name
}

resource "aws_iam_user_login_profile" "credentials" {
  user                    = aws_iam_user.iam_user.name
  password_reset_required = false
}