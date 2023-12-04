provider "aws" {
  region = "eu-central-1"  
}

resource "aws_sns_topic" "bucket_public_access_block_topic" {
  name = "BucketPublicAccessBlockAlerts"
}

resource "aws_cloudwatch_event_rule" "s3_public_access_block_rule" {
  name        = "S3PublicAccessBlockRule"
  description = "Rule to capture PutBucketPublicAccessBlock events"
  event_pattern = <<PATTERN
{
  "source": ["aws.s3"],
  "detail-type": ["AWS API Call via CloudTrail"],
  "detail": {
    "eventSource": ["s3.amazonaws.com"],
    "eventName": ["PutBucketPublicAccessBlock"]
  }
}
PATTERN
}

resource "aws_sns_topic_policy" "bucket_public_access_block_policy" {
  arn = aws_sns_topic.bucket_public_access_block_topic.arn

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = {
          Service = "events.amazonaws.com"
        },
        Action    = "sns:Publish",
        Resource  = aws_sns_topic.bucket_public_access_block_topic.arn
      }
    ]
  })
}

resource "aws_cloudwatch_event_target" "s3_public_access_block_target" {
  rule = aws_cloudwatch_event_rule.s3_public_access_block_rule.name
  arn  = aws_sns_topic.bucket_public_access_block_topic.arn
}
