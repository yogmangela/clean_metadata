resource "aws_iam_role_policy_attachment" "lambda_execution_role_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AWSLambdaExecute"
  role       = aws_iam_role.lambda_execution_role.name
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "lambda_function"
  output_path = "lambda_function.zip"
}

resource "aws_lambda_permission" "allow_s3_trigger" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.image_processing_lambda.function_name
  principal     = "s3.amazonaws.com"

  source_arn = aws_s3_bucket.bucket_a.arn
}

resource "aws_s3_bucket_notification" "bucket_a_notification" {
  bucket = aws_s3_bucket.bucket_a.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.image_processing_lambda.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "images/"
    filter_suffix       = ".jpg"
  }
}





# Create IAM User "user_a", Replace with your desired username
resource "aws_iam_user" "user_a" {
  name = "user-a"
}

#  Create IAM User "user_b", Replace with your desired username
resource "aws_iam_user" "user_b" {
  name = "user-b"
}

resource "aws_iam_user" "user_c" {
  name = "user-c"
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
        Resource = [aws_s3_bucket.bucket_b.arn, "${aws_s3_bucket.bucket_b.arn}/*"]
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
