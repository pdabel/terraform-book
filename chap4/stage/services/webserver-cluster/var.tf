variable "db_remote_state_bucket" {
  description = "Bucket to store state"
  default = "pda.terraform"
}

variable "db_remote_state_key" {
  description = "State file to store state in"
  default = "book/chapter4/stage/data-stores/mysql/terraform.tfstate"
}

variable "wc_remote_state_bucket" {
  description = "Bucket to store state"
  default = "pda.terraform"
}

variable "wc_remote_state_key" {
  description = "State file to store state in"
  default = "book/chapter4/stage/services/webserver-cluster/terraform.tfstate"
}

