remote_state {
    backend = "s3"

    generate = {
        path = "backend.tf"
        if_exists = "overwrite_terragrunt"
    }

    config = {
        encrypt = true
        bucket = "dk-state-bucket"
        key = "${path_relative_to_include()}/terraform.tfstate"
        region = "ap-northeast-2"
        profile = "leedonggyu"
    }
}

generate "provider" {
    path = "provider.tf"
    if_exists = "overwrite_terragrunt"

    contents = <<EOF
    provider "aws" {
        region = "ap-northeast-2"
        profile = "leedonggyu"
    }
    EOF
}

### config
dependency "config" {
    config_path = "../config"

    mock_outputs ={
        region = "ap-northeast-2"
        account_id = "1234567890"
        vpc = {
            vpc_id = "vpc-111"
            was_subnet_ids = ["subnet-111","subnet-222"]
        }
    }
}

inputs = {
    env = "prd"
}
