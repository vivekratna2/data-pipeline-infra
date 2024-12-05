resource "aws_ecs_cluster" "ecs_cluster_worker_reparse" {
  name = "etl-cluster-worker-reparse-${terraform.workspace}"
}

resource "aws_ecs_capacity_provider" "feeds_ecs_capacity_worker_reparse" {
  name = "etl_ecs_capacity_reparse_${terraform.workspace}"
  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.etl_asg_worker_reparse.arn
  }
}

resource "aws_ecs_cluster_capacity_providers" "ecs_cluster_capacity_reparse" {
  cluster_name = aws_ecs_cluster.ecs_cluster_worker_reparse.name

  capacity_providers = [aws_ecs_capacity_provider.feeds_ecs_capacity_worker_reparse.name]
}