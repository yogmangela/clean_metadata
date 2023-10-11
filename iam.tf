

# Create IAM User "user_a", Replace with your desired username
resource "aws_iam_user" "user_a" {
  name = "user-a"
}

#  Create IAM User "user_b", Replace with your desired username
resource "aws_iam_user" "user_b" {
  name = "user-b"
}

# Create bucket policy for User A with Full access Replace with your desired policies here
resource "aws_iam_policy" "policy_a" {
  name        = "policy-a"
  description = "Policy for User A"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = ["s3:PutObject", "s3:GetObject", "s3:ListBucket"],
        Effect   = "Allow",
        Resource = [aws_s3_bucket.bucket_a.arn, "${aws_s3_bucket.bucket_a.arn}/*"],
      },
    ],
  })
}

# Create bucket policy for User B with Full access Replace with your desired policies here
resource "aws_iam_policy" "policy_b" {
  name        = "policy-b"
  description = "Policy for User B"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = ["s3:GetObject", "s3:ListBucket"],
        Effect   = "Allow",
        Resource = [aws_s3_bucket.bucket_b.arn, "${aws_s3_bucket.bucket_b.arn}/*"],
      },
    ],
  })
}

# Attach bucket policy "policy_a" to "user_a".
resource "aws_iam_user_policy_attachment" "attach_policy_a" {
  user       = aws_iam_user.user_a.name
  policy_arn = aws_iam_policy.policy_a.arn
}

# Attach bucket policy "policy_b" to "user_b".
resource "aws_iam_user_policy_attachment" "attach_policy_b" {
  user       = aws_iam_user.user_b.name
  policy_arn = aws_iam_policy.policy_b.arn
}