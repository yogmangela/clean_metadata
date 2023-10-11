
# 2. Create an S3 event trigger for Bucket A to invoke the Lambda function when a .jpg file is uploaded.

resource "aws_s3_bucket_notification" "bucket_a_notification" {
  # bucket = "bucket-a-tzxi7"
  bucket = aws_s3_bucket.bucket_a.bucket

  lambda_function {
    lambda_function_arn = aws_lambda_function.metadata_stripper_function.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "path/to/images/"
    filter_suffix       = ".jpg"
  }
}

# -----------------------------------------------------------
# Generates an archive from content, a file, or a directory of files.

data "archive_file" "zip_the_python_code" {
  type        = "zip"
  source_dir  = "${path.module}/python/"
  output_path = "${path.module}/python/strip_exif.zip"
}

resource "aws_lambda_function" "metadata_stripper_function" {
  filename      = "${path.module}/python/strip_exif.zip"
  function_name = "metadata-stripper"
  role          = aws_iam_role.lambda_execution_role.arn
  handler       = "strip_exif.lambda_handler"
  runtime       = "python3.11"
  timeout       = 10
  layers = [aws_lambda_layer_version.pillow_py311.arn]

  environment {
    variables = {
      SOURCE_BUCKET = aws_s3_bucket.bucket_a.id,
      DEST_BUCKET   = aws_s3_bucket.bucket_b.id
    }
  }

# depends_on = [ aws_iam_policy.lambda_policy ]

}

resource "aws_lambda_layer_version" "pillow_py311" {
  filename   = "${path.module}/Pillow.zip"
  layer_name = "pillow-python311"
  compatible_runtimes = ["python3.11"]
}


resource "aws_lambda_permission" "allow_bucket_a_trigger" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.metadata_stripper_function.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.bucket_a.arn

  # depends_on = [ aws_lambda_function.metadata_stripper_function ]
}

# Create an IAM Role for the Lambda function to assume when executing. Attach a policy that allows reading from Bucket A, writing to Bucket B, and logging.

resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# TO DO: allow Lambda to access S3 bucket dynamically

resource "aws_iam_policy" "lambda_policy" {
  name        = "lambda_policy"
  description = "Policy for Lambda to access S3 buckets"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ReadWriteBucketA",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::bucket-a-tzxi7",
        "arn:aws:s3:::bucket-a-tzxi7/*"
      ]
    },
    {
      "Sid": "ReadBucketB",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::bucket-b-s791dg",
        "arn:aws:s3:::bucket-b-s791dg/*"
      ]
    },
    {
      "Sid": "WriteBucketB",
      "Effect": "Allow",
      "Action": [
        "s3:PutObject"
      ],
      "Resource": [
        "arn:aws:s3:::bucket-b-s791dg",
        "arn:aws:s3:::bucket-b-s791dg/*"
      ]
    },
    {
      "Sid": "LambdaLogs",
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_role_policy_attachment" {
  policy_arn = aws_iam_policy.lambda_policy.arn
  role       = aws_iam_role.lambda_execution_role.name
}



