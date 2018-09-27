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
