terraform {
 required_version = ">= 1.1.5"
 //backend is to save state file in s3 (shared across team and worker nodes in CI/CD)
#  backend "s3" {
#    bucket = "bucket_name"
#    key    = "folder/state.tfstate"
#    region = "us-east-1"
#  }
}

provider "aws" {
  region = "us-east-1"
  //default tags can be used to tag all resources created by terraform
  //helps a lot identifying the cost based on resource tags
  default_tags {
    tags = {
      "env"         = "env_name" //can be named anything 
      "app" = "app_name"
    }
  }
}

