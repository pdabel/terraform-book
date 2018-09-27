variable "web_server_port" {
  description = "The port the backend web server will run on"
  default     = 8080
}

variable "ssh_server_port" {
  description = "The port the ssh service will run on"
  default     = 22
}

variable "desktop_ip" {
  description = "The Public IP of my desktop"
  default     = "86.45.159.64/32"
}

variable "lb_port" {
  description = "The frontend port the LB listens on"
  default     = 80
}

variable "cluster_name" {
  description = "The name to use for all the cluster resources"
}

variable "db_remote_state_bucket" {
  description = "The name of the S3 bucket for the database's remote state"
}

variable "db_remote_state_key" {
  description = "The path to the database's remote state in S3"
}

variable "wc_remote_state_bucket" {
  description = "The name of the S3 bucket for the webserver-cluster's remote state"
}

variable "wc_remote_state_key" {
  description = "The path to the webserver-cluster's remote state in S3"
}

variable "instance_type" {
  description = "The type of EC2 instance to run (e.g. t2.micro)"
}

variable "min_size" {
  description = "The minimum number of EC" instances in the ASG"
}

variable "max_size" {
  description = "The maximum number of EC" instances in the ASG"
}
