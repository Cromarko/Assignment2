#Storage (S3 for logs/artifacts, EBS for app data)

resource "aws_s3_bucket" "app_storage" {
  bucket = "dashboard-app-storage-${random_id.bucket_suffix.hex}"
  force_destroy = true
  tags = { Name = "dashboard-app-storage" }
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}
