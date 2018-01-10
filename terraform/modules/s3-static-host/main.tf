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

resource "random_id" "bucket" {
  byte_length = 8
}

##################################################################################
# S3 Bucket                                                                      #
##################################################################################
resource "aws_s3_bucket" "static_site" {
  depends_on = [
    "null_resource.is_ready",
  ]

  acl    = "public-read"
  bucket = "wildrydes-${random_id.bucket.hex}"

  force_destroy = true

  website {
    index_document = "index.html"
  }
}

resource "aws_s3_bucket_policy" "public_access" {
  depends_on = [
    "null_resource.is_ready",
    "aws_s3_bucket.static_site",
  ]

  bucket = "${aws_s3_bucket.static_site.id}"

  policy = <<POLICY
{
  "Version":"2012-10-17",
  "Statement":[{
    "Sid":"PublicReadForGetBucketObjects",
    "Effect":"Allow",
    "Principal": "*",
    "Action":"s3:GetObject",
    "Resource":["${aws_s3_bucket.static_site.arn}/*"]
  }]
}
POLICY

  # Copy website files over to our new bucket
  provisioner "local-exec" {
    command = <<EOF
aws s3 sync \
  s3://wildrydes-us-east-1/WebApplication/1_StaticWebHosting/website \
  s3://${aws_s3_bucket.static_site.id}
EOF
  }
}

##################################################################################
# Terraform - Wait for everything to finish                                      #
# https://github.com/hashicorp/terraform/issues/7527                             #
##################################################################################
resource "null_resource" "is_complete" {
  depends_on = [
    "null_resource.is_ready",
    "aws_s3_bucket.static_site",
    "aws_s3_bucket_policy.public_access",
  ]
}

##################################################################################
# Terraform - Outputs                                                            #
##################################################################################
output "is_complete" {
  value = "${null_resource.is_complete.id}"
}

output "bucket" {
  value = "${aws_s3_bucket.static_site.id}"
}

output "website_url" {
  value = "http://${aws_s3_bucket.static_site.website_endpoint}"
}
