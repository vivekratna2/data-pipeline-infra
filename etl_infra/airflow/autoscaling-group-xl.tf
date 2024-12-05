resource "aws_launch_configuration" "etl_ecs_launch_config_worker_xl" {
  name                        = "etl_ecs_launch_config_worker_xl_${terraform.workspace}"
  image_id                    = "ami-02c6f7952af6bd632"
  iam_instance_profile        = aws_iam_instance_profile.etl_ecs_ec2_cluster_worker_xl.arn
  security_groups             = [aws_security_group.etl_worker_sg.id]
  user_data                   = "#!/bin/bash\necho ECS_CLUSTER=${aws_ecs_cluster.ecs_cluster_worker_xl.name} >> /etc/ecs/ecs.config"
  instance_type               = "m5a.xlarge"
  associate_public_ip_address = true
  key_name                    = "etl-us-west-2"

  root_block_device {
    volume_size           = "32"
    volume_type           = "gp2"
    delete_on_termination = true
  }
}

resource "aws_autoscaling_group" "etl_asg_worker_xl" {
  name                 = "etl_asg_worker_xl_${terraform.workspace}"
  vpc_zone_identifier  = [var.public_subnet_id_1, var.public_subnet_id_2]
  launch_configuration = aws_launch_configuration.etl_ecs_launch_config_worker_xl.name

  desired_capacity          = 2
  min_size                  = 2
  max_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "EC2"
  tag {
    key                 = "Name"
    value               = "etl_worker_xl_${terraform.workspace}"
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

resource "aws_autoscaling_policy" "etl_ecs_ec2_asg_policy_worker_xl" {
  autoscaling_group_name = aws_autoscaling_group.etl_asg_worker_xl.name
  name                   = "etl_ecs_ec2_asg_policy_worker_xl_${terraform.workspace}"
  policy_type            = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50
  }
}

resource "aws_iam_instance_profile" "etl_ecs_ec2_cluster_worker_xl" {
  name = "etl_ecs_ec2_cluster_worker_xl_${terraform.workspace}"
  role = aws_iam_role.etl_ecs_worker_xl.name

  tags = {
    Project = "etl"
    Stage   = terraform.workspace
  }
}

resource "aws_iam_role" "etl_ecs_worker_xl" {
  name               = "etl_ecs_worker_xl_${terraform.workspace}"
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
            "secretsmanager:ListSecrets",
            "sqs:*"
          ]
          Effect   = "Allow"
          Resource = "*"
        },
        {
          Effect : "Allow",
          Action : [
            "athena:BatchGetQueryExecution",
            "athena:CancelQueryExecution",
            "athena:GetCatalogs",
            "athena:GetExecutionEngine",
            "athena:GetExecutionEngines",
            "athena:GetNamespace",
            "athena:GetNamespaces",
            "athena:GetQueryExecution",
            "athena:GetQueryExecutions",
            "athena:GetQueryResults",
            "athena:GetQueryResultsStream",
            "athena:GetTable",
            "athena:GetTables",
            "athena:ListQueryExecutions",
            "athena:RunQuery",
            "athena:StartQueryExecution",
            "athena:StopQueryExecution",
            "athena:ListWorkGroups",
            "athena:ListEngineVersions",
            "athena:GetWorkGroup",
            "athena:GetDataCatalog",
            "athena:GetDatabase",
            "athena:GetTableMetadata",
            "athena:ListDataCatalogs",
            "athena:ListDatabases",
            "athena:ListTableMetadata"
          ],
          Resource : [
            "*"
          ]
        },
        {
          Effect : "Allow",
          Action : [
            "glue:CreateDatabase",
            "glue:DeleteDatabase",
            "glue:GetDatabase",
            "glue:GetDatabases",
            "glue:UpdateDatabase",
            "glue:CreateTable",
            "glue:DeleteTable",
            "glue:BatchDeleteTable",
            "glue:UpdateTable",
            "glue:GetTable",
            "glue:GetTables",
            "glue:BatchCreatePartition",
            "glue:CreatePartition",
            "glue:DeletePartition",
            "glue:BatchDeletePartition",
            "glue:UpdatePartition",
            "glue:GetPartition",
            "glue:GetPartitions",
            "glue:BatchGetPartition"
          ],
          Resource : [
            "*"
          ]
        },
      ]
    })
  }

  tags = {
    Project = "etl"
    Stage   = terraform.workspace
  }
}