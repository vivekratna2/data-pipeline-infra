resource "aws_ecs_cluster" "ecs_cluster_worker_xl" {
  name       = "etl-cluster-worker-xl-${terraform.workspace}"
  depends_on = [aws_instance.webserver_instance]
}

resource "aws_ecs_capacity_provider" "feeds_ecs_capacity_worker_xl" {
  name = "etl_ecs_capacity_xl_${terraform.workspace}"
  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.etl_asg_worker_xl.arn
  }
}

resource "aws_ecs_cluster_capacity_providers" "ecs_cluster_capacity_xl" {
  cluster_name = aws_ecs_cluster.ecs_cluster_worker_xl.name

  capacity_providers = [aws_ecs_capacity_provider.feeds_ecs_capacity_worker_xl.name]
}