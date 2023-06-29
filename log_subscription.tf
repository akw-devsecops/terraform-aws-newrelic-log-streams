resource "aws_cloudwatch_log_subscription_filter" "log_group_subscriptions" {
  for_each = var.log_group_subscriptions

  destination_arn = aws_kinesis_firehose_delivery_stream.newrelic_log_stream.arn
  role_arn        = aws_iam_role.cloudwatch_to_firehose.arn
  name            = "TF-NewRelic-Log"
  filter_pattern  = ""
  log_group_name  = each.key
}

resource "aws_iam_role" "cloudwatch_to_firehose" {
  name        = "TF-NewRelic-Cloudwatch-Subscription-${data.aws_region.current.name}"
  description = "Role to allow a metric stream put metrics into a firehose"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = "sts:AssumeRole",
        Principal = {
          Service = "logs.${data.aws_region.current.name}.amazonaws.com"
        },
        Condition = {
          StringLike = {
            "aws:SourceArn" = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
          }
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_policy" "cloudwatch_to_firehose" {
  policy = jsonencode(
    {
      Version = "2012-10-17",
      Statement = [
        {
          Effect = "Allow",
          Action = [
            "firehose:PutRecord",
            "firehose:PutRecordBatch"
          ]
          Resource = [
            aws_kinesis_firehose_delivery_stream.newrelic_log_stream.arn
          ]
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "cloudwatch_to_firehose" {
  policy_arn = aws_iam_policy.cloudwatch_to_firehose.arn
  role       = aws_iam_role.cloudwatch_to_firehose.name
}
