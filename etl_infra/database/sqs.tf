resource "aws_sqs_queue" "cai_reparse_sqs" {
  name                        = "etl-cai-reparse-queue-${terraform.workspace}.fifo"
  fifo_queue                  = true
  content_based_deduplication = true
  message_retention_seconds   = 345600
  receive_wait_time_seconds   = 10
  visibility_timeout_seconds  = 120
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.cai_reparse_sqs_dlq.arn
    maxReceiveCount     = 3
  })
  tags = {
    Environment = terraform.workspace
  }
}

resource "aws_sqs_queue" "cai_reparse_sqs_dlq" {
  name       = "etl-cai-reparse-queue-dlq-${terraform.workspace}.fifo"
  fifo_queue = true
}

resource "aws_sqs_queue_policy" "cai_reparse_sqs_policy" {
  queue_url = aws_sqs_queue.cai_reparse_sqs.url

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = "*",
        Action    = "sqs:SendMessage",
        Resource  = aws_sqs_queue.cai_reparse_sqs.arn,
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_sqs_queue.cai_reparse_sqs_dlq.arn
          }
        }
      }
    ]
  })
}