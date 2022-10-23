locals {
    bucket = "webserver-s3-us-east-1"
}

module "s3" {
    source = "./modules/s3"
    name = local.bucket
    dir = "files" //files to be uploaded to s3
}
