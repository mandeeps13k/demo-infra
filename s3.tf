resource "aws_s3_bucket" "demo" {
  bucket = "demo-data-django"
  acl    = "private"

  versioning {
    enabled = true
  }
}
