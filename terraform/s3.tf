

# bucket are created globally and bucketname must be unique globally hence adding random string

resource "random_string" "random-a" {
  length           = 5
  special          = true
  override_special = "/@£$"
  lower            = true
  upper            = false
}


resource "random_string" "random-b" {
  length           = 6
  special          = true
  override_special = "/@£$"
  lower            = true
  upper            = false
}
# Create S3 bucket "bucket_a", Replace with your desired S3 bucket name.

resource "aws_s3_bucket" "bucket_a" {
  bucket = "bucket-a-${random_string.random-a.result}"
}

resource "aws_s3_bucket_versioning" "bucket_a_ver" {
  bucket = aws_s3_bucket.bucket_a
  versioning_configuration {
    status = "Disabled"
  }
}

# Create a folder (prefix) inside the bucket
resource "aws_s3_object" "s3_prefix_a" {
  bucket = aws_s3_bucket.bucket_a.id
  key    = "path/to/images/" # will create sub-folfer called "img"
}

# Create S3 bucket "bucket_b", Replace with your desired S3 bucket name
resource "aws_s3_bucket" "bucket_b" {
  bucket = "bucket-b-${random_string.random-b.result}"
}

# Create a folder (prefix) inside the bucket
resource "aws_s3_object" "s3_prefix_b" {
  bucket = aws_s3_bucket.bucket_b.id
  key    = "img/" # will create sub-folfer called "img"
  # source = "" # Specify local path to upload file from.
}
