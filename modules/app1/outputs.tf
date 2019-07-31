output "app_alb_arn" {
  value = aws_alb._.arn
}

output "app_alb_hostname" {
  value = aws_alb._.dns_name
}

output "app_ecs_cluster_arn" {
  value = aws_ecs_cluster._.arn
}
