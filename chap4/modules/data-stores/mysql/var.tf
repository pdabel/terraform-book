variable "cluster_name" {
  description = "The name to use for all the cluster resources"
}

variable "db_password" {
  description = "The password for the database"
}

variable "db_remote_state_bucket" {
  description = "The name of the S3 bucket for the database's remote state"
}

variable "db_remote_state_key" {
  description = "The path to the database's remote state in S3"
}
