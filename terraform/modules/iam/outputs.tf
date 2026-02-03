output "iam_username" {
  value = aws_iam_user.iam_user.name
}

output "secret_key" {
  value     = aws_iam_access_key.credentials.secret
  sensitive = true
}

output "access_key_id" {
  value     = aws_iam_access_key.credentials.id
  sensitive = true
}