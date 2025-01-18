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

    mock_outputs = {
        config_output = "mock-config-output"
    }
}

dependency "alb" {
    config_path = "../alb"

    mock_outputs = {
        alb_output = "mock-alb-output"
    }
}

inputs = {
    env = "prd"

    config = dependency.config.outputs
    alb = dependency.alb.outputs
}
