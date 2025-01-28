#Creating a VPC
resource "aws_vpc" "custom_vpc" {
  cidr_block = var.block1
  instance_tenancy = "default"

  tags = {
    Name = "CustomVPC"
  }
}

#Create a  public Subnet
resource "aws_subnet" "custom_subnet" {
  vpc_id = aws_vpc.custom_vpc.id
  cidr_block = var.block2
  map_public_ip_on_launch = true
  availability_zone = var.region

  tags = {
    Name = "CustomSubnet"
  }
}
#Create a DB subnet1
resource "aws_subnet" "rds_subnet1" {
  vpc_id = aws_vpc.custom_vpc.id
  cidr_block = var.block3
  map_public_ip_on_launch = false
  availability_zone = var.region

  tags = {
    Name = "Rds_subnet1"
  }
}

#Create a DB subnet2
resource "aws_subnet" "rds_subnet2" {
  vpc_id = aws_vpc.custom_vpc.id
  cidr_block = var.block4
  map_public_ip_on_launch = false
  availability_zone = "eu-north-1b"

  tags = {
    Name = "Rds_subnet2"
  }
}
#Create a Internet Gateway
resource "aws_internet_gateway" "custom_igw" {
  vpc_id = aws_vpc.custom_vpc.id
  tags = {
    Name = "CustomIGW"
  }
}

#Create a Route Table for public subnet
resource "aws_route_table" "custom_route_table" {
  vpc_id = aws_vpc.custom_vpc.id
  tags = {
    Name = "CustomRouteTable"
  }
}

#Create a Route to the Internet Gateway
resource "aws_route" "route_to_internet" {
  route_table_id = aws_route_table.custom_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.custom_igw.id
}

#Associate the route table with the subnet
resource "aws_route_table_association" "custom_route_table_association" {
  route_table_id = aws_route_table.custom_route_table.id
  subnet_id = aws_subnet.custom_subnet.id
}

#Create a Route table for private subnet
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.custom_vpc.id

  tags = {
    Name = "CustomDBRoutetable"
  }
}

#Associate Private Subnets to the Route table
resource "aws_route_table_association" "Private_subnet1_association" {
  route_table_id = aws_route_table.private_route_table.id
  subnet_id = aws_subnet.rds_subnet1.id
}

resource "aws_route_table_association" "Private_subnet2_association" {
  route_table_id = aws_route_table.private_route_table.id
  subnet_id = aws_subnet.rds_subnet2.id
}

# #add a NAT Gateway
# resource "aws_route" "private_nat" {
#   route_table_id = aws_route_table.private_route_table.id
#   destination_cidr_block = "0.0.0.0/0"
#   nat_gateway_id = aws_na
# }

#Create a security group for EC2 Instance
resource "aws_security_group" "custom_sg" {
  vpc_id = aws_vpc.custom_vpc.id
  description = "Security group for EC2 "
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"] #Allow SSH from anywhere
  }
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"] #Allow HTTP Traffic
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "CustomSecurityGroup"
  }
}

#Security Group for DB instance
resource "aws_security_group" "rds_sg" {
  vpc_id =aws_vpc.custom_vpc.id
  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    security_groups = [aws_security_group.custom_sg.id]
  }

}

resource "aws_db_subnet_group" "main" {
  name = "rds-subnet-group"
  subnet_ids = [aws_subnet.rds_subnet1.id, aws_subnet.rds_subnet2.id]

  tags = {
    Name = "rds-subnet-group"
  }
}


#Creation of EC2 Instance
resource "aws_instance" "custom_ec2" {
  ami           = var.ami
  instance_type = var.instancetype
  subnet_id = aws_subnet.custom_subnet.id
  vpc_security_group_ids = [aws_security_group.custom_sg.id]

  #Specify the Key pair name
  key_name = "linux-keypair"

  tags = {
    Name = "CustomEC2Instance"
  }
}

#Creation of RDS instance
resource "aws_db_instance" "main" {
  instance_class = "db.t3.micro"
  allocated_storage = 20
  engine = "mysql"
  engine_version = "5.7"
  identifier = "mydb"
  username = "admin"
  password = "admin123"
  vpc_security_group_ids = [aws_security_group.custom_sg.id]
  db_subnet_group_name = aws_db_subnet_group.main.name
#   final_snapshot_identifier = "mydb"
  #to skip taking backups
  skip_final_snapshot = true
}