data "aws_availability_zones" "avilable" {}

resource "aws_elb" "elb" {
  name    = "terraform-elb"
  subnets = [aws_default_subnet.default_1.id,
             aws_default_subnet.default_2.id,
             aws_default_subnet.default_3.id]
  security_groups = [aws_security_group.apache.id]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 10
    target              = "HTTP:80/"
    interval            = 30
  }

  instances                   = [aws_instance.my_ubuntu.id, aws_instance.my_ubuntu2.id]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

}

resource "aws_default_subnet" "default_1" {
  availability_zone = data.aws_availability_zones.avilable.names[0]
}

resource "aws_default_subnet" "default_2" {
  availability_zone = data.aws_availability_zones.avilable.names[1]
}

resource "aws_default_subnet" "default_3" {
  availability_zone = data.aws_availability_zones.avilable.names[2]
}

