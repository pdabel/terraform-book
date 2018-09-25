terraform {
  backend "s3" {
    bucket = "pda.terraform"
    key    = "book/chapter2"
    region = "eu-west-1"
  }
}


provider "aws" {
  region     = "eu-west-1"
}

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

data "aws_vpc" "ire_vpc" {
  default = true
}

#resource "aws_instance" "example" {
#	ami           = "ami-0ea87e2bfa81ca08a"
#	instance_type = "t2.micro"
#  vpc_security_group_ids = ["${aws_security_group.instance.id}"]
#  key_name = "${aws_key_pair.deployer.key_name}"
#
#	tags {
#		Name = "terraform-example"
#	}
#
#  user_data = <<-EOF
#    #!/bin/bash
#    echo "Hello, World" > index.html
#    yum -y install busybox mlocate
#    updatedb
#    nohup busybox httpd -f -p "${var.web_server_port}" &
#    EOF
#}

resource "aws_launch_configuration" "example" {
  image_id               = "ami-0ea87e2bfa81ca08a"
  instance_type          = "t2.micro"
  security_groups        = ["${aws_security_group.instance.id}"]
  key_name               = "${aws_key_pair.deployer.key_name}"

  user_data              = <<-EOF
    #!/bin/bash
    echo "Hello, World" > index.html
    yum -y install busybox mlocate
    updatedb
    nohup busybox httpd -f -p "${var.web_server_port}" &
    EOF

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_subnet_ids" "ire_subnets" {
  vpc_id = "${data.aws_vpc.ire_vpc.id}"
}

resource "aws_security_group" "instance" {
  name = "terraform-example-instance"

  ingress {
    from_port   = "${var.web_server_port}"
    to_port     = "${var.web_server_port}"
    protocol    = "tcp"
    #cidr_blocks = ["${element(data.aws_subnet_ids.ire_subnets.cidr_block, count.index)}"]
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = "${var.ssh_server_port}"
    to_port     = "${var.ssh_server_port}"
    protocol    = "tcp"
    cidr_blocks = ["${var.desktop_ip}"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_autoscaling_group" "example" {
  launch_configuration  = "${aws_launch_configuration.example.id}"
  availability_zones    = ["${data.aws_availability_zones.all.names}"]

  load_balancers        = ["${aws_elb.example.name}"]
  health_check_type     = "ELB"

  min_size              = 2
  max_size              = 8

  tags {
    key                 = "Name"
    value               = "terraform-asg-example"
    propagate_at_launch = true
  }
}

data "aws_availability_zones" "all" {}

resource "aws_elb" "example" {
  name                  = "terraform-asg-example"
  availability_zones    = ["${data.aws_availability_zones.all.names}"]
  security_groups       = ["${aws_security_group.elb.id}"]

  listener {
    lb_port             = "${var.lb_port}"
    lb_protocol         = "http"
    instance_port       = "${var.web_server_port}"
    instance_protocol   = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    target              = "HTTP:${var.web_server_port}/"
  }
}

resource "aws_security_group" "elb" {
  name  = "terraform-example-elb"

  ingress {
    from_port   = "${var.lb_port}"
    to_port     = "${var.lb_port}"
    protocol    = "tcp"
    cidr_blocks = ["${var.desktop_ip}"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDYLQuevK8AGmcrt4dRnHsUAv3ZkrVeryKBYKfTnRd4TKDBvcAoeiyajPCt9Z0Yrmc+pSl9yBzT1j9tosYbVJPN9d8NpvkAo+dLyymSTyIdM2NlsRYghMbU0Bt65nzaCQ9IVXRcDUltz0FpU2sSFErkUylMgPGUwWZk0SOZ5YrP5160YNZtgVwaaQ9fZuyu1BITlddmQqsQlcAMq7lC0U8WaNUmSAqrCBJABJx0jxxUPkXSJqAcyNKLkCNLZXhOuQW/ur0E5UeUCo36e1ABaB5gfd0ioUTPlfAcL91hMWDFDZRM0HWO7VlYhkaYfZ9RoaY1Qz5RevyfU7weXeUmz/XD paul@paul-400B2B-400B2B"

  lifecycle {
    create_before_destroy = true
  }
}

#output "public_ip" {
#  value = "${aws_instance.example.public_ip}"
#}

#output "public_dns" {
#  value = "${aws_instance.example.public_dns}"
#}

output "elb_dns_name" {
  value = "${aws_elb.example.dns_name}"
}
