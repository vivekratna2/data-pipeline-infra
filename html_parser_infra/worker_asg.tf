resource "aws_launch_template" "worker_server_launch_template" {
  name          = "htmlparser_worker_template_${terraform.workspace}"
  image_id      = var.EC2_AMI
  instance_type = var.EC2_INSTANCE_TYPE_WORKER
  key_name      = "html-parser-terraform"
  user_data = base64encode(templatefile("userdata/worker_user_data.tftpl", {
    ENVIRONMENT              = terraform.workspace,
    RELEASE_VERSION          = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["RELEASE_VERSION"],
    ACCOUNT_ID               = data.aws_caller_identity.current.account_id,
    REDIS_PASS               = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["REDIS_PASS"],
    REDIS_RESULT_EXPIRE_DAYS = var.REDIS_RESULT_EXPIRE_DAYS,
    SCHEME_API_HOST          = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["SCHEME_API_HOST"],
    FLOWER_PORT              = var.FLOWER_PORT,
    REDIS_HOST               = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["REDIS_HOST"],
    REDIS_PORT               = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["REDIS_PORT"],
    REDIS_DB                 = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["REDIS_DB"],
    REDIS_DB_SCHEME_CACHE    = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["REDIS_DB_SCHEME_CACHE"],
    FLASK_PORT               = var.FLASK_PORT,
    AWS_ACCESS_KEY_RTAWS     = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["AWS_ACCESS_KEY_RTAWS"],
    AWS_SECRET_KEY_RTAWS     = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["AWS_SECRET_KEY_RTAWS"],
    AWS_ACCESS_KEY_MERKLE    = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["AWS_ACCESS_KEY_MERKLE"],
    AWS_SECRET_KEY_MERKLE    = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["AWS_SECRET_KEY_MERKLE"],
    MONGODB_USERNAME         = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["MONGODB_USERNAME"],
    MONGODB_PASSWORD         = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["MONGODB_PASSWORD"],
    MONGODB_PORT             = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["MONGODB_PORT"],
    US_IP                    = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["US_IP"],
    CA_IP                    = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["CA_IP"],
    MERKLE_IP                = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["MERKLE_IP"],
    DEV_IP                   = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["DEV_IP"],
    POSTGRES_HOST            = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["POSTGRES_HOST"],
    POSTGRES_PORT            = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["POSTGRES_PORT"],
    POSTGRES_USER            = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["POSTGRES_USER"],
    POSTGRES_PASSWORD        = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["POSTGRES_PASSWORD"],
    POSTGRES_DB              = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["POSTGRES_DB"],
    US_TOKEN                 = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["US_TOKEN"],
    MERKLE_TOKEN             = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["MERKLE_TOKEN"],
    DEV_TOKEN                = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["DEV_TOKEN"],
    etl_API_GATEWAY_URL      = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["etl_API_GATEWAY_URL"],
    etl_API_KEY              = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["etl_API_KEY"],
    REDIS_DB_SCHEME_CACHE    = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["REDIS_DB_SCHEME_CACHE"],
  }))

  /*block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = 32
      volume_type = "gp2"
    }
  }
  */

  tag_specifications {
    resource_type = "volume"
    tags = {
      Name = "htmlparser_worker_volume_${terraform.workspace}"
    }
  }
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_ecr_profile.name
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name    = "AWS-GBD-htmlparser_worker_${terraform.workspace}"
      Project = "html_parser"
      Stage   = terraform.workspace
    }
  }

  network_interfaces {
    associate_public_ip_address = "false"
    security_groups             = [aws_security_group.html_parser_sg.id]
  }
}

resource "aws_autoscaling_group" "worker_autoscale" {
  name                      = "html_parser_asg_${terraform.workspace}"
  max_size                  = 20
  min_size                  = 1
  health_check_grace_period = 300
  vpc_zone_identifier       = [var.PRIVATE_SUBNET_ID]
  launch_template {
    id      = aws_launch_template.worker_server_launch_template.id
    version = "$Latest"
  }
  lifecycle {
    ignore_changes = [min_size, max_size]
  }
}

resource "aws_autoscaling_policy" "scale_up_policy" {
  autoscaling_group_name = aws_autoscaling_group.worker_autoscale.name
  policy_type            = "TargetTrackingScaling"
  name                   = "htmlparser_worker_scale_up"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 25
  }
}

resource "aws_autoscaling_lifecycle_hook" "lifecycle_hook" {
  autoscaling_group_name = aws_autoscaling_group.worker_autoscale.name
  lifecycle_transition   = "autoscaling:EC2_INSTANCE_TERMINATING"
  name                   = "woker_lifecycle_hook"
  default_result         = "CONTINUE"
  heartbeat_timeout      = 120

  notification_metadata = jsonencode({
    foo = "bar"
  })
}

resource "aws_iam_role" "ec2_ecr_role" {
  name = "ec2_ecr_access_role_${terraform.workspace}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
  tags = {
    tag-key = "ec2_ecr_role_tag_value"
  }
}

resource "aws_iam_instance_profile" "ec2_ecr_profile" {
  name = "ec2_ecr_profile_${terraform.workspace}"
  role = aws_iam_role.ec2_ecr_role.id
}

resource "aws_iam_role_policy" "ec2_ecr_policy" {
  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        "Action" : [
          "ecr:*"
        ],
        "Effect" : "Allow",
        "Resource" : "*"
      },
      {
        "Action" : [
          "autoscaling:CompleteLifecycleAction"
        ],
        "Effect" : "Allow",
        "Resource" : "arn:aws:autoscaling:*:368759994472:autoScalingGroup:*:autoScalingGroupName/html_parser_asg_${terraform.workspace}"
      },
      {
        "Action" : [
          "sqs:SendMessage"
        ],
        "Effect" : "Allow",
        "Resource" : "*"
      },
      {
        "Action" : [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject"
        ],
        "Effect" : "Allow",
        "Resource" : "*"
      },
      {
        "Action" : "sts:AssumeRole",
        "Effect" : "Allow",
        "Resource" : "arn:aws:iam::029114956521:role/GBD-Merkle-S3-Access-Role"
      }
    ]
  })
  role = aws_iam_role.ec2_ecr_role.id
}