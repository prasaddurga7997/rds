#Creating a VPC
resource "aws_vpc" "custom_vpc" {
  cidr_block = var.block1
  instance_tenancy = "default"

  tags = {
    Name = "CustomVPC"
  }
}

#Create a Subnet
resource "aws_subnet" "custom_subnet" {
  vpc_id = aws_vpc.custom_vpc.id
  cidr_block = var.block2
  map_public_ip_on_launch = true
  availability_zone = var.region

  tags = {
    Name = "CustomSubnet"
  }
}

#Create a Internet Gateway
resource "aws_internet_gateway" "custom_igw" {
  vpc_id = aws_vpc.custom_vpc.id
  tags = {
    Name = "CustomIGW"
  }
}

#Create a Route Table
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

#Create a security group
resource "aws_security_group" "custom_sg" {
  vpc_id = aws_vpc.custom_vpc.id
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
    protocol = "-1" #Allow all Outbound Traffic
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "CustomSecurityGroup"
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