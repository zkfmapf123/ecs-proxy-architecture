variable "config" {

}

variable "alb" {

}

locals {
  config = jsondecode(var.config)
  alb    = jsondecode(var.alb).alb
}

