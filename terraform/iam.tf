data "aws_iam_policy_document" "assume_role_ecs" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "satoshi-abe-ecs-task-execution"
  assume_role_policy = data.aws_iam_policy_document.assume_role_ecs.json
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "put_firehose_and_logs" {
  statement {
    actions = ["firehose:PutRecordBatch"]
    resources = ["*"]
  }

  statement {
    actions = [
      "logs:PutLogEvents",
      "logs:DescribeLogStreams"
    ]

    resources = [
      "arn:aws:logs:ap-northeast-1:xxxxxxxxxx:log-group:/ecs/satoshi-abe-example:log-stream:*"
    ]
  }
}

resource "aws_iam_policy" "ecsTaskExecutionRole_policy2" {
  name        = "satoshi-abe-ecsTaskExecutionRole_policy2"
  policy = data.aws_iam_policy_document.put_firehose_and_logs.json
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy2" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = aws_iam_policy.ecsTaskExecutionRole_policy2.arn
}

resource "aws_iam_role" "firehose_role" {
  name = "satoshi-abe-firehose-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_firehose.json
}

data "aws_iam_policy_document" "assume_role_firehose" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "firehose_s3_and_log" {
  statement {
    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:PutObject"
    ]

    resources = [
      "arn:aws:s3:::satoshi-abe-firehose",
      "arn:aws:s3:::satoshi-abe-firehose/*"		    
    ]
  }

  statement {
    actions = [
      "logs:PutLogEvents",
    ]

    resources = [
      "arn:aws:logs:ap-northeast-1:xxxxxxxxxx:log-group:/ecs/satoshi-abe-example:log-stream:*"
    ]
  }
}

resource "aws_iam_policy" "firehose_role_policy" {
  name = "satoshi-abe-firehose_role_policy"
  policy = data.aws_iam_policy_document.firehose_s3_and_log.json
}

resource "aws_iam_role_policy_attachment" "firehose_role_policy" {
  role       = aws_iam_role.firehose_role.name
  policy_arn = aws_iam_policy.firehose_role_policy.arn
}
