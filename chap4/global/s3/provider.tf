provider "aws" {
  region     = "eu-west-1"
}

terraform {
  backend "s3" {
    bucket = "pda.terraform"
    key    = "book/chapter4/global/s3/terraform.tfstate"
    region = "eu-west-1"
  }
}
