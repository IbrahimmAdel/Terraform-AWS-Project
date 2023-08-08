# CREATE 2 TARGET GROUP FOR PUBLIC AND PRIVATE SUBNETS
resource "aws_lb_target_group" "tg" {
    count    = 2
    port     = 80
    protocol = "HTTP"   
    vpc_id   = var.lb_vpc_id
}

# ATTACHE TARGET GROUP TO PUBLIC SUBNETS
resource "aws_lb_target_group_attachment" "public-target-group-attachment" {
    count            = length(var.pub_target_id)
    target_group_arn = aws_lb_target_group.tg[0].arn
    target_id        = var.pub_target_id[count.index]
    port             = 80
}

# ATTACHE TARGET GROUP TO PRIVATE SUBNETS
resource "aws_lb_target_group_attachment" "private-target-group-attachment" {
    count            = length(var.priv_target_id)
    target_group_arn = aws_lb_target_group.tg[1].arn
    target_id        = var.priv_target_id[count.index]
    port             = 80
}

# CREATE PUBLIC & PRIVATE LOAD BALANCER
resource "aws_lb" "load-balancer" {
    count                      = 2
    name                       = "sprints-load-balancer-${count.index}"
    internal                   = var.lb_internal[count.index]
    load_balancer_type         = "application"
    subnets                    = var.lb_subnets[count.index]     
    security_groups            = [var.lb_sg_id]
    # enable_deletion_protection = true
}
# CREATE 2 LOAD BALANCER LISTNERS
resource "aws_lb_listener" "lb-listner" {
    count             = 2
    load_balancer_arn = aws_lb.load-balancer[count.index].id
    port              = "80"
    protocol          = "HTTP"
    default_action {
        type  = "forward"
        target_group_arn = aws_lb_target_group.tg[count.index].id
  }
}

