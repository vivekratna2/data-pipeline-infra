resource "aws_ecs_cluster" "ecs_cluster" {
  name       = "etl-cluster-${terraform.workspace}"
  depends_on = [aws_instance.webserver_instance]
}

resource "aws_ecs_capacity_provider" "feeds_ecs_capacity" {
  name = "etl_ecs_capacity_${terraform.workspace}"
  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.etl_asg.arn
  }
}

resource "aws_ecs_cluster_capacity_providers" "ecs_cluster_capacity" {
  cluster_name = aws_ecs_cluster.ecs_cluster.name

  capacity_providers = [aws_ecs_capacity_provider.feeds_ecs_capacity.name]
}