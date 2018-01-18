terraform {
  required_version = "> 0.11.0"
}

provider "aws" {
  version = "~> 1.7"
  region  = "us-east-1"
}

################################################################################
# Modules                                                                      #
################################################################################
module "s3_static_host" {
  source = "./modules/s3-static-host"

  is_ready = "true"
}

module "cognito_user_pool" {
  source = "./modules/cognito-user-pool"

  is_ready = "true"
}

##################################################################################
# Outputs                                                                        #
##################################################################################
output "bucket_name" {
  value = "${module.s3_static_host.bucket}"
}

output "website_url" {
  value = "${module.s3_static_host.website_url}"
}

output "cognito_user_pool_id" {
  value = "${module.cognito_user_pool.pool_id}"
}

output "cognito_user_pool_arn" {
  value = "${module.cognito_user_pool.pool_arn}"
}

output "cognito_user_pool_client_id" {
  value = "${module.cognito_user_pool.pool_client_id}"
}
