resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDYLQuevK8AGmcrt4dRnHsUAv3ZkrVeryKBYKfTnRd4TKDBvcAoeiyajPCt9Z0Yrmc+pSl9yBzT1j9tosYbVJPN9d8NpvkAo+dLyymSTyIdM2NlsRYghMbU0Bt65nzaCQ9IVXRcDUltz0FpU2sSFErkUylMgPGUwWZk0SOZ5YrP5160YNZtgVwaaQ9fZuyu1BITlddmQqsQlcAMq7lC0U8WaNUmSAqrCBJABJx0jxxUPkXSJqAcyNKLkCNLZXhOuQW/ur0E5UeUCo36e1ABaB5gfd0ioUTPlfAcL91hMWDFDZRM0HWO7VlYhkaYfZ9RoaY1Qz5RevyfU7weXeUmz/XD paul@paul-400B2B-400B2B"

  lifecycle {
    create_before_destroy = true
  }
}

data "template_file" "user_data" {
  template = "${file("${path.module/user-data.sh}")}"

  vars {
    server_port = "${var.web_server_port}"
    db_address  = "${data.terraform_remote_state.db.address}"
    db_port     = "${data.terraform_remote_state.db.port}"
  }
}

data "aws_availability_zones" "all" {}

resource "aws_launch_configuration" "example" {
  image_id               = "ami-0ea87e2bfa81ca08a"
  instance_type          = "${var.instance_type}"
  security_groups        = ["${aws_security_group.instance.id}"]
  key_name               = "${aws_key_pair.deployer.key_name}"

  user_data              = "${data.template_file.user_data.rendered}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "instance" {
  name = "${var.cluster_name}-instance"

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

  min_size              = "${var.min_size}"
  max_size              = "${var.max_size}"

  tags {
    key                 = "Name"
    value               = "${var.cluster_name}-example"
    propagate_at_launch = true
  }
}

resource "aws_elb" "example" {
  name                  = "${var.cluster_name}-example"
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
  name  = "${var.cluster_name}-elb"

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

data "terraform_remote_state" "db" {
  backend = "s3"
 
  config {
    bucket  = "${var.db_remote_state_bucket}"
    key     = "${var.db_remote_state_key}"
    region  = "eu-west-1"
  }
}
