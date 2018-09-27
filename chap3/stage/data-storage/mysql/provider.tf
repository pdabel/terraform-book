provider "aws" {
  region     = "eu-west-1"
}

terraform {
  backend "s3" {
    bucket = "pda.terraform"
    key    = "book/chapter3/stage/services/mysql"
    region = "eu-west-1"
  }
}
