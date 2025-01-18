variable "config" {
  
}

locals {
    config = jsondecode(var.config)
}