provider "aws" {}


data "aws_availability_zones" "working" {}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_vpcs" "my_vpcs" {}



resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}



resource "aws_default_subnet" "default_az0" {
  availability_zone = data.aws_availability_zones.working.names[0]

  tags = {
    Name = "Default subnet for eu-central-1a"
  }
}

resource "aws_default_subnet" "default_az1" {
  availability_zone = data.aws_availability_zones.working.names[1]

  tags = {
    Name = "Default subnet for eu-central-1b"
  }
}

resource "aws_default_subnet" "default_az2" {
  availability_zone = data.aws_availability_zones.working.names[2]

  tags = {
    Name = "Default subnet for eu-central-1c"
  }
}


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

data "aws_ami" "latest_ubuntu" {
  owners      = ["099720109477"]
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
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

ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [aws_default_vpc.default.cidr_block]
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


resource "aws_db_instance" "mysqldb" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0.20"
  instance_class       = "db.t2.micro"
  name                 = "wordpress"
  identifier           = "mysqldb"
  identifier_prefix    = null
#  id                   = "mysqldb"
  multi_az             = false
  port                 = 3306
  storage_encrypted    = false
  skip_final_snapshot  = true
  snapshot_identifier  = null
  username             = "wordpressuser"
  password             = "12345678"
  parameter_group_name = "default.mysql8.0"
  db_subnet_group_name = "for-db"
  vpc_security_group_ids = [
    aws_security_group.apache.id
  ]
}


resource "aws_db_subnet_group" "for-db" {
  name                 = "for-db"
  description          = "Subnet for DB"
#  id                   = "for-db"
  subnet_ids = [aws_default_subnet.default_az0.id,
                aws_default_subnet.default_az1.id,
                aws_default_subnet.default_az2.id
               ]
  tags = {
    Name = "My DB subnet group"
  }

}


resource "aws_instance" "my_ubuntu" {
  ami                    = data.aws_ami.latest_ubuntu.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.deployer.id
  vpc_security_group_ids = [aws_security_group.apache.id]
  availability_zone      = data.aws_availability_zones.working.names[0]
  user_data              = templatefile("apache_script.tpl", {
    fs_name              = aws_efs_file_system.my_efs.id,
    db_address           = aws_db_instance.mysqldb.address,
 
  })

  tags = {
    Name    = "WWW-Server-10"
    Owner   = "Andrei Shtanakov"
    Project = "Terraform habdled"
  }
  depends_on = [aws_efs_file_system.my_efs]
}


resource "aws_instance" "my_ubuntu2" {
  ami                    = data.aws_ami.latest_ubuntu.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.deployer.id
  vpc_security_group_ids = [aws_security_group.apache.id]
  availability_zone      = data.aws_availability_zones.working.names[1]
  user_data              = templatefile("apache_script.tpl", {
    fs_name              = aws_efs_file_system.my_efs.id,
    db_address           = aws_db_instance.mysqldb.address,
  })

  tags = {
    Name    = "WWW-Server-20"
    Owner   = "Andrei Shtanakov"
    Project = "Terraform habdled"
  }
  depends_on = [aws_efs_file_system.my_efs]
}



resource "aws_default_subnet" "default_az-a" {
  availability_zone =  data.aws_availability_zones.working.names[0]

  tags = {
    Name = "Default subnet a"
  }
}

resource "aws_default_subnet" "default_az-b" {
  availability_zone =  data.aws_availability_zones.working.names[1]

  tags = {
    Name = "Default subnet b"
  }
}




resource "aws_efs_file_system" "my_efs" {
  # (resource arguments)
  creation_token = "my-product"

  tags = {
    Name = "MyProduct"
  }
}
resource "aws_efs_access_point" "test" {
  file_system_id = aws_efs_file_system.my_efs.id
}

resource "aws_efs_mount_target" "primary" {
  file_system_id  = aws_efs_file_system.my_efs.id
  subnet_id       = aws_default_subnet.default_az-a.id
  security_groups = [aws_security_group.apache.id]
}

resource "aws_efs_mount_target" "secondary" {
  file_system_id  = aws_efs_file_system.my_efs.id
  subnet_id       = aws_default_subnet.default_az-b.id
  security_groups = [aws_security_group.apache.id]

}




output "vps_cidr_block" {
  
  value = aws_default_vpc.default.cidr_block
}




output "subnet_cidr_blocks-a" {
  value = aws_default_subnet.default_az-a.cidr_block
}

output "subnet_cidr_blocks-b" {
  value = aws_default_subnet.default_az-b.cidr_block
}


resource "aws_key_pair" "deployer" {
  key_name   = "deployer_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDAccnhhq6Jaoe99qLP1hgUP9O2mrVFmmpYEZouY7VNjcTVdkZihj7LBP/4niODLFIUH+E7iYS89dnB6xtS9T8BXsiHChk6K3K2HlI6vObd8i5kKMgtSP9bGarW9Fuq+3S/VHQP94JSBDKcCm2TqgvQZcmd6sgeN4optp3WpAWMR56HJbZqTyrNr2tIOYvm0LBq0QlGNyFyxuXpKTEDHzpGhiaHZl+5e+MWxtshR13rnCTirHYl+fSCAr3r+dNcukBr8UZdWQ6FEW8DJWs3c5116YoFU6d1Rp9FV/yLTmUOo/gU/xcy6f6h0W0gprBW8tLdSVsb2niP0NrBB9ZKo0FH user@epam2"
}

output "aws_vpcs" {
  value = data.aws_vpcs.my_vpcs.id
}

output "db_name_dns" {
  value = aws_db_instance.mysqldb.address
}
