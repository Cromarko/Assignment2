#Compute ECS/Fargate

resource "aws_ecs_cluster" "this" {
  name = "dashboard-cluster"
}

resource "aws_lb" "app" {
  name               = "dashboard-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public.id]
}

resource "aws_lb_target_group" "app" {
  name        = "dashboard-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"
  health_check { path = "/" }
}
