resource "aws_launch_configuration" "ecs_launch_config" {
  name                 = "etl_ecs_launch_config_${terraform.workspace}"
  image_id             = "ami-02c6f7952af6bd632"
  iam_instance_profile = aws_iam_instance_profile.ecs.arn
  security_groups      = [aws_security_group.etl_scheduler_sg.id]

  user_data = <<EOF
  #!/bin/bash
  echo ECS_CLUSTER=etl-cluster-${terraform.workspace} >> /etc/ecs/ecs.config
  mkdir -p /home/etl/logs
  chmod -R 777 /home/etl
  cronjob="0 0 * * * find /home/etl/logs/scheduler -maxdepth 1 -type d -mtime +1 -exec rm -rf {} \;"
  echo "$cronjob" >> /etc/cron.d/cronjob
  echo "0 0 * * * echo test1234 >> /var/log/cron.log 2>&1" >> /etc/cron.d/cronjob
  echo "#empty line" >> /etc/cron.d/cronjob
  chmod 0644 /etc/cron.d/cronjob
  crontab etc/cron.d/cronjob
  EOF

  instance_type               = "c6a.xlarge"
  associate_public_ip_address = true
  key_name                    = "etl-us-west-2"

  root_block_device {
    volume_size           = "64"
    volume_type           = "gp2"
    delete_on_termination = true
  }
}

resource "aws_autoscaling_group" "etl_asg" {
  name                 = "etl_asg_${terraform.workspace}"
  vpc_zone_identifier  = [var.public_subnet_id_1, var.public_subnet_id_2]
  launch_configuration = aws_launch_configuration.ecs_launch_config.name

  desired_capacity          = 1
  min_size                  = 1
  max_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "EC2"
  tag {
    key                 = "Name"
    value               = "etl_server_${terraform.workspace}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = "etl"
    propagate_at_launch = true
  }

  tag {
    key                 = "Stage"
    value               = terraform.workspace
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "ecs_ec2_asg_policy" {
  autoscaling_group_name = aws_autoscaling_group.etl_asg.name
  name                   = "etl_ecs_ec2_asg_policy_${terraform.workspace}"
  policy_type            = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50
  }
}

resource "aws_iam_instance_profile" "ecs" {
  name = "etl-ecs-ec2-cluster-${terraform.workspace}"
  role = aws_iam_role.ecs.name

  tags = {
    Project = "etl"
    Stage   = terraform.workspace
  }
}

resource "aws_iam_role" "ecs" {
  name               = "etl-ecs-ec2-role-${terraform.workspace}"
  assume_role_policy = <<EOF
  {
      "Version": "2012-10-17",
      "Statement": [
          {
              "Action": "sts:AssumeRole",
              "Principal": {
                 "Service": "ec2.amazonaws.com"
              },
              "Effect": "Allow",
              "Sid": ""
          }
      ]
  }
  EOF

  inline_policy {
    name = "etl_inline_policy_ec2"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "ec2:DescribeTags",
            "ecs:CreateCluster",
            "ecs:DeregisterContainerInstance",
            "ecs:DiscoverPollEndpoint",
            "ecs:Poll",
            "ecs:RegisterContainerInstance",
            "ecs:StartTelemetrySession",
            "ecs:UpdateContainerInstancesState",
            "ecs:Submit*",
            "ecr:GetAuthorizationToken",
            "ecr:BatchCheckLayerAvailability",
            "ecr:GetDownloadUrlForLayer",
            "ecr:BatchGetImage",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ]
          Effect   = "Allow"
          Resource = "*"
        }
      ]
    })
  }

  inline_policy {
    name = "etl_inline_policy_s3"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "s3:*",
            "secretsmanager:GetRandomPassword",
            "secretsmanager:GetResourcePolicy",
            "secretsmanager:GetSecretValue",
            "secretsmanager:DescribeSecret",
            "secretsmanager:ListSecretVersionIds",
            "secretsmanager:ListSecrets"
          ]
          Effect   = "Allow"
          Resource = "*"
        }
      ]
    })
  }

  tags = {
    Project = "etl"
    Stage   = terraform.workspace
  }
}
