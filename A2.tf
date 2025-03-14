provider "aws" {
    profile = "default"
    region = "us-east-1"
}

resource "aws_vpc" "A2_VPC" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "A2_VPC"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.A2_VPC.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "public_subnet"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.A2_VPC.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1c"
  tags = {
    Name = "private1_subnet"
  }
}

resource "aws_subnet" "private_subnet2" {
  vpc_id     = aws_vpc.A2_VPC.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "private2_subnet"
  }
}

resource "aws_db_subnet_group" "db-subnet-group" {
  name       = "db-subnet-group"
  subnet_ids = [aws_subnet.private_subnet.id, aws_subnet.private_subnet2.id]

  tags = {
    Name = "db-subnet-group"
  }
}


resource "aws_internet_gateway" "A2_igw" {
  vpc_id = aws_vpc.A2_VPC.id
  tags = {
    Name = "A2_igw"
  }
}

resource "aws_route_table" "ig_rt" {
  vpc_id = aws_vpc.A2_VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.A2_igw.id
  }

  tags = {
    Name = "ig-rt"
  }
}

resource "aws_route_table_association" "ig-rt-association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.ig_rt.id
}

resource "aws_security_group" "ec2_sg" {
  name        = "ec2_sg"
  description = "allow http, https, and ssh to ec2"
  vpc_id      = aws_vpc.A2_VPC.id

   # Allow HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow everyone (change if needed)
  }

  # Allow HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow everyone (change if needed)
  }

  # Restrict SSH to your IP (Replace YOUR_IP)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Replace with your public IP
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2_sg"
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "rds-security-group"
  description = "Security group for RDS inside private subnet"
  vpc_id      = aws_vpc.A2_VPC.id  

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]  
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-sg"
  }
}

resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "example" {
  key_name   = "ec2_kp"  # Name of the key pair
  public_key = tls_private_key.example.public_key_openssh  # Correct attribute
}

output "private_key_pem" {
  value     = tls_private_key.example.private_key_pem
  sensitive = true
}


resource "aws_instance" "a2_ec2" {
    ami = "ami-08b5b3a93ed654d19"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.public_subnet.id
    vpc_security_group_ids = [aws_security_group.ec2_sg.id]    
    associate_public_ip_address = true
    key_name      = "ec2_kp"
    tags = {
      Name = "a2_ec2"
    }
    depends_on = [aws_security_group.ec2_sg]
}

resource "aws_db_instance" "a2_db" {
  identifier        = "a2-db"
  engine            = "mysql"
  engine_version    = "8.0.40"  # Choose the MySQL version
  instance_class    = "db.t4g.micro"  # You can choose other instance types based on your needs
  allocated_storage = 20  # Storage size in GB
  db_name           = "productdb"  # Optional database name
  username          = "admin"  # Master username
  password          = "adminadmin"  # Master password
  parameter_group_name = "default.mysql8.0"  # Default MySQL parameter group
  port              = 3306
  multi_az          = false  # Set to true for high availability
  publicly_accessible = false  # Set to false if you don't want it publicly accessible
  vpc_security_group_ids = [aws_security_group.rds_sg.id]  # Attach the security group
  db_subnet_group_name    = aws_db_subnet_group.db-subnet-group.name
  tags = {
    Name = "a2_db"
  }

  skip_final_snapshot = true
}


