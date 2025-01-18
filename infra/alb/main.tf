data "aws_acm_certificate" "cert" {
  domain = "*.leedonggyu.com"
}

resource "aws_security_group" "alb_sg" {
  name = "alb-sg"
  vpc_id = local.config.config.vpc_id
  description = "alb-sg"    

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "alb" {
  source  = "zkfmapf123/alb/donggyu"
  version = "1.0.0"

  cluster_attr = {
    cluster_name      = "proxy-cluster"
    is_create_cluster = true
  }

  lb_attr = {
    "lb_delete_protection" : true,
    "lb_name" : "proxy-lb",
    "lb_sg_ids" : [aws_security_group.alb_sg.id],
    "lb_subnet_ids" : local.config.config.was_subnet_ids,
    "lb_vpc" : local.config.config.vpc_id
  }

  lb_enable_access_logs = {
    "is_enable" : false,
    "s3_bucket_id" : ""
  }

  lb_listener_attr = {
    "lb_acm_arn" : data.aws_acm_certificate.cert.arn
  }

  lb_listener_tg = {
    "tg_name" : "default-proxy-tg",
    "tg_port" : 80,
    "tg_protocol" : "HTTP",
    "tg_target_type" : "ip",
    "tg_vpc_id" : local.config.config.vpc_id
  }

}