output "iam_username" {
  description = "The name of the IAM user"
  value       = aws_iam_user.iam_user.name
}

output "secret_key" {
  description = "The secret access key for the IAM user"
  value       = aws_iam_access_key.credentials.secret
}

output "access_key_id" {
  description = "The access key ID for the IAM user"
  value       = aws_iam_access_key.credentials.id
}