resource "aws_ecr_repository" "app" {
  name                 = "satoshi-abe-example-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "firelens" {
  name                 = "satoshi-abe-example-firelens"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_kinesis_firehose_delivery_stream" "example" {
  name        = "satoshi-abe-firelens-stream"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn   = aws_iam_role.firehose_role.arn
    bucket_arn = aws_s3_bucket.bucket.arn
    buffer_size = 10
    buffer_interval = 60

    cloudwatch_logging_options {
      enabled = true
      log_group_name = "/ecs/satoshi-abe-example"
      log_stream_name = "satoshi-abe-firehose"
    }
  }
}

resource "aws_s3_bucket" "bucket" {
  bucket = "satoshi-abe-firehose"
  acl    = "private"
}