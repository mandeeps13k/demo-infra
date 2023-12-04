resource "aws_sns_topic" "bucket_policy_change_topic" {
  name = "BucketPolicyChangeAlerts"
}

resource "aws_sns_topic_policy" "bucket_policy_change_topic_policy" {
  arn    = aws_sns_topic.bucket_policy_change_topic.arn
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = "*",
      Action    = "sns:Publish",
      Resource  = aws_sns_topic.bucket_policy_change_topic.arn,
      Condition = {
        ArnLike = {
          "AWS:SourceArn" = aws_cloudwatch_event_rule.s3_bucket_policy_rule.arn
        }
      }
    }]
  })
}

resource "aws_cloudwatch_event_rule" "s3_bucket_policy_rule" {
  name        = "S3BucketPolicyRule"
  description = "Rule to capture PutBucketPolicy events"
  event_pattern = <<PATTERN
{
  "source": ["aws.s3"],
  "detail-type": ["AWS API Call via CloudTrail"],
  "detail": {
    "eventSource": ["s3.amazonaws.com"],
    "eventName": ["PutBucketPolicy"]
  }
}
PATTERN
}

resource "aws_cloudwatch_event_target" "s3_bucket_policy_target" {
  rule = aws_cloudwatch_event_rule.s3_bucket_policy_rule.name
  arn  = aws_sns_topic.bucket_policy_change_topic.arn
}
