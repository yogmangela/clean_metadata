output "bucket_a" {
  value = aws_s3_bucket.bucket_a.bucket
}

output "bucket_b" {
  value = aws_s3_bucket.bucket_b.bucket
}

output "bucket_a_prefix" {
  value = aws_s3_object.s3_prefix_a.key
}

output "bucket_b_prefix" {
  value = aws_s3_object.s3_prefix_b.key
}
