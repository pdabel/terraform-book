provider "aws" {
  region     = "eu-west-1"
}

terraform {
  backend "s3" {
    bucket = "${var.db_remote_state_bucket}"
    key    = "${var.db_remote_state_key}"
    region = "eu-west-1"
  }
}
