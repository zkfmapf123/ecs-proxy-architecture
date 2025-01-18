######################################## Region ########################################
data "aws_region" "current" {}

output "region" {
    value = data.aws_region.current.name
}

######################################## Accountid ########################################
data "aws_caller_identity" "current" {}

output "account_id" {
    value = data.aws_caller_identity.current.account_id
}

output "config" {
    value = {
        vpc_id = "vpc-0be5e4795b7e66a4f"
        was_subnet_ids = ["subnet-096272491365decec","subnet-0ded2f9aa6b8e37d0"]
    }
}