resource "aws_sns_topic" "bucket_logging_topic" {
  name = "BucketLoggingAlerts"
}

resource "aws_cloudwatch_event_rule" "s3_logging_access_rule" {
  name        = "S3LoggingAccessRule"
  description = "Rule to capture PutBucketLogging events"
  event_pattern = <<PATTERN
{
  "source": ["aws.s3"],
  "detail-type": ["AWS API Call via CloudTrail"],
  "detail": {
    "eventSource": ["s3.amazonaws.com"],
    "eventName": ["PutBucketLogging"]
  }
}
PATTERN
}

resource "aws_sns_topic_policy" "bucket_logging_topic_policy" {
  arn    = aws_sns_topic.bucket_logging_topic.arn

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = {
          Service = "events.amazonaws.com"
        },
        Action    = "sns:Publish",
        Resource  = aws_sns_topic.bucket_logging_topic.arn
      }
    ]
  })
}

resource "aws_cloudwatch_event_target" "s3_logging_access_target" {
  rule = aws_cloudwatch_event_rule.s3_logging_access_rule.name
  arn  = aws_sns_topic.bucket_logging_topic.arn
}
