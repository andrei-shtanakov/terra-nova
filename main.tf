provider "aws" {}


data "aws_availability_zones" "working" {}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_vpcs" "my_vpcs" {}


resource "aws_vpc" "prod-10" {
  cidr_block = "10.10.0.0/16"

  tags = {
    Name = "prod-vpc-10"
  }
}

resource "aws_vpc" "stage-20" {
  cidr_block = "10.20.0.0/16"

  tags = {
    Name = "stage-vpc-20"
  }
}

resource "aws_vpc" "dev-30" {
  cidr_block = "10.30.0.0/16"

  tags = {
    Name = "dev-vpc-30"
  }
}


resource "aws_subnet" "prod_subnet_1" {
  vpc_id            = aws_vpc.prod-10.id
  availability_zone = data.aws_availability_zones.working.names[0]
  cidr_block        = "10.10.1.0/24"
  tags = {
    Name    = "Sub-p-1 in ${data.aws_availability_zones.working.names[0]}"
    Account = "Subnet in Account ${data.aws_caller_identity.current.account_id}"
    Region  = data.aws_region.current.description
  }
}

resource "aws_subnet" "prod_subnet_2" {
  vpc_id            = aws_vpc.prod-10.id
  availability_zone = data.aws_availability_zones.working.names[1]
  cidr_block        = "10.10.2.0/24"
  tags = {
    Name    = "Sub-p-2 in ${data.aws_availability_zones.working.names[1]}"
    Account = "Subnet in Account ${data.aws_caller_identity.current.account_id}"
    Region  = data.aws_region.current.description
  }
}

resource "aws_subnet" "stage_subnet_1" {
  vpc_id            = aws_vpc.stage-20.id
  availability_zone = data.aws_availability_zones.working.names[0]
  cidr_block        = "10.20.1.0/24"
  tags = {
    Name    = "Sub-s-1 in ${data.aws_availability_zones.working.names[0]}"
    Account = "Subnet in Account ${data.aws_caller_identity.current.account_id}"
    Region  = data.aws_region.current.description
  }
}

resource "aws_subnet" "stage_subnet_2" {
  vpc_id            = aws_vpc.stage-20.id
  availability_zone = data.aws_availability_zones.working.names[1]
  cidr_block        = "10.20.2.0/24"
  tags = {
    Name    = "Sub-s-2 in ${data.aws_availability_zones.working.names[1]}"
    Account = "Subnet in Account ${data.aws_caller_identity.current.account_id}"
    Region  = data.aws_region.current.description
  }
}

resource "aws_subnet" "dev_subnet_1" {
  vpc_id            = aws_vpc.dev-30.id
  availability_zone = data.aws_availability_zones.working.names[0]
  cidr_block        = "10.30.1.0/24"
  tags = {
    Name    = "Sub-d-1 in ${data.aws_availability_zones.working.names[0]}"
    Account = "Subnet in Account ${data.aws_caller_identity.current.account_id}"
    Region  = data.aws_region.current.description
  }
}

resource "aws_subnet" "dev_subnet_2" {
  vpc_id            = aws_vpc.dev-30.id
  availability_zone = data.aws_availability_zones.working.names[1]
  cidr_block        = "10.30.2.0/24"
  tags = {
    Name    = "Sub-d-2 in ${data.aws_availability_zones.working.names[1]}"
    Account = "Subnet in Account ${data.aws_caller_identity.current.account_id}"
    Region  = data.aws_region.current.description
  }
}

data "aws_ami" "latest_RHEL" {
  owners      = ["309956199498"]
  most_recent = true
  filter {
    name   = "name"
    values = ["RHEL_HA-8.*_HVM-*-x86_64-2-Hourly2-GP2"]
  }
}

resource "aws_security_group" "apache" {
  name        = "WWW Security Group"
  description = "Open ports for Websever"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "WWW SecurityGroup"
    Owner = "Andrei Shtanakov"
  }
}


resource "aws_instance" "my_redhut" {
  ami                    = data.aws_ami.latest_RHEL.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.apache.id]
  availability_zone      = data.aws_availability_zones.working.names[0]
  user_data              = templatefile("httpd_script.tpl", {
    f_name = "Abra",
    l_name = "Kadabra",
  })

  tags = {
    Name    = "WWW-Server-10"
    Owner   = "Andrei Shtanakov"
    Project = "Terraform habdled"
  }
}


resource "aws_instance" "my_redhut2" {
  ami                    = data.aws_ami.latest_RHEL.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.apache.id]
  availability_zone      = data.aws_availability_zones.working.names[1]
  user_data              = templatefile("httpd_script.tpl", {
    f_name = "Abra",
    l_name = "Kadabra",
  })

  tags = {
    Name    = "WWW-Server-20"
    Owner   = "Andrei Shtanakov"
    Project = "Terraform habdled"
  }
}


