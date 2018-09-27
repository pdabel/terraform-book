provider "aws" {
  region     = "eu-west-1"
}

#resource "aws_s3_bucket" "terraform_state" {
#  bucket = "pda.terraform"
#
#  versioning {
#    enabled = true
#  }
#
#  lifecycle {
#    prevent_destroy = true
#  }
#}

terraform {
  backend "s3" {
    bucket = "pda.terraform"
    key    = "book/chapter3/global/s3"
    region = "eu-west-1"
  }
}
