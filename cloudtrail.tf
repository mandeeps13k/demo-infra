resource "aws_s3_bucket" "cloudtrail_logs_bucket" {
  bucket = "cloudtrail-logging-bucket-1"  
  tags = {
    Name = "CloudTrailLogsBucket"
  }

}

data "aws_iam_policy_document" "cloudtrail_bucket_policy" {
  statement {
    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.cloudtrail_logs_bucket.arn]
    effect    = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }

  statement {
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.cloudtrail_logs_bucket.arn}/*"]
    effect    = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
  
  statement {
    actions   = ["s3:GetBucketPolicy"]
    resources = [aws_s3_bucket.cloudtrail_logs_bucket.arn]
    effect    = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.cloudtrail_logs_bucket.arn]
    effect    = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }
}

resource "aws_s3_bucket_policy" "cloudtrail_bucket_policy" {
  bucket = aws_s3_bucket.cloudtrail_logs_bucket.id
  policy = data.aws_iam_policy_document.cloudtrail_bucket_policy.json
}


resource "aws_cloudtrail" "organization_cloudtrail" {
  name                          = "OrganizationCloudTrail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail_logs_bucket.id
  include_global_service_events = true


  event_selector {
    read_write_type = "All"
    include_management_events = true

    data_resource {
      type = "AWS::S3::Object"
      values = ["arn:aws:s3:::cloudtrail-logging-bucket-1/*"]  
    }
  }
}

