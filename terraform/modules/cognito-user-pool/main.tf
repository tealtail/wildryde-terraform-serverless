##################################################################################
# Terraform - Wait for the is_ready variable                                     #
##################################################################################
resource "null_resource" "is_ready" {
  triggers {
    is_ready = "${var.is_ready}"
  }
}

##################################################################################
# AWS - Metadata                                                                 #
##################################################################################
data "aws_caller_identity" "current" {}

data "aws_region" "current" {
  current = true
}

##################################################################################
# Cognito User Pool                                                              #
##################################################################################
resource "aws_cognito_user_pool" "pool" {
  depends_on = [
    "null_resource.is_ready",
  ]

  name = "wildrydes"

  password_policy = {
    minimum_length    = 6
    require_numbers   = false
    require_symbols   = false
    require_uppercase = false
  }
}

resource "aws_cognito_user_pool_client" "client" {
  name = "wildrydes-webapp"

  user_pool_id = "${aws_cognito_user_pool.pool.id}"

  generate_secret = false
}

##################################################################################
# Terraform - Wait for everything to finish                                      #
# https://github.com/hashicorp/terraform/issues/7527                             #
##################################################################################
resource "null_resource" "is_complete" {
  depends_on = [
    "null_resource.is_ready",
    "aws_cognito_user_pool.pool",
    "aws_cognito_user_pool_client.client",
  ]
}

##################################################################################
# Terraform - Outputs                                                            #
##################################################################################
output "is_complete" {
  value = "${null_resource.is_complete.id}"
}

output "pool_id" {
  value = "${aws_cognito_user_pool.pool.id}"
}

output "pool_arn" {
  value = "${aws_cognito_user_pool.pool.arn}"
}

output "pool_client_id" {
  value = "${aws_cognito_user_pool_client.client.id}"
}
