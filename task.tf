# Create ECS cluster; will be used with task
resource "aws_ecs_cluster" "db_check_cluster" {
  name = "db_cluster"
}
# Created ECS task; used docker container created manually; uploaded to DockerHub
resource "aws_ecs_task_definition" "db_connection" {
  family                   = "app_check"
  container_definitions    = file("task.json")
  requires_compatibilities = ["EC2"]
  # network_mode             = "awsvpc"
}
# Create ECS service to run task
resource "aws_ecs_service" "db_check" {
  name            = "db_check"
  cluster         = aws_ecs_cluster.db_check_cluster.id
  task_definition = aws_ecs_task_definition.db_connection.arn
  desired_count   = 1
}
/*
resource "aws_ecs_service" "db_con_service" {
  name            = "service_db_connection"
  cluster         = aws_ecs_cluster.db_check_cluster.id
  task_definition = aws_ecs_task_definition.db_connection.arn
  desired_count   = 1
  network_configuration {
    subnets = aws_subnet.app_subnet.*.id
  }
}
*/
