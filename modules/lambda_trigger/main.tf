data "archive_file" "join_trigger_zip" {
  type        = "zip"
  source_file = "assets/aws/lambda/join_worker_node.py"
  output_path = "${path.module}/join_worker_node.zip"
}

resource "aws_lambda_function" "join_trigger" {
  function_name = "trigger-worker-join"
  role          = var.lambda_role_arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"

  filename         = data.archive_file.join_trigger_zip.output_path
  source_code_hash = data.archive_file.join_trigger_zip.output_base64sha256

  environment {
    variables = {
      S3_BUCKET = var.s3_bucket_name
      S3_KEY    = var.s3_key_filter
    }
  }
}

resource "aws_cloudwatch_event_rule" "s3_trigger" {
  name        = "trigger-worker-join"
  description = "Triggers Lambda when join-command.txt is uploaded"
  event_pattern = jsonencode({
    source        = ["aws.s3"],
    "detail-type" = ["Object Created"],
    detail = {
      bucket = {
        name = [var.s3_bucket_name]
      },
      object = {
        key = [var.s3_key_filter]
      }
    }
  })
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.s3_trigger.name
  target_id = "TriggerLambda"
  arn       = aws_lambda_function.join_trigger.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.join_trigger.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.s3_trigger.arn
}
