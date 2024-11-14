# Generate Private Key
resource "tls_private_key" "devk1" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Create AWS Key Pair
resource "aws_key_pair" "ec2_key" {
  key_name   = "ec2-dev-250-key"
  public_key = tls_private_key.devk1.public_key_openssh

  tags = {
    Name = "ec2-dev-tls-key"
  }
}

# Save the Private Key to a .pem File
resource "local_file" "devk1_pem" {
  filename        = "ec2-dev-250-key.pem"
  content         = tls_private_key.devk1.private_key_pem
  file_permission = "0400" # Ensure the file is only readable by the owner
}

output "private_key_path" {
  value = local_file.devk1_pem.filename
}


#Create VPC - 10.250.0.0/16
resource "aws_vpc" "dev-vpc" {
  cidr_block = "10.250.0.0/16"
  tags = {
    "Name" = "dev-vpc-250"
  }
}
#Create Subnet - 10.250.1.0/24
resource "aws_subnet" "dev-websunet" {
  vpc_id                  = aws_vpc.dev-vpc.id
  cidr_block              = "10.250.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "dev-250-websubnet"
  }
}

#Create Internet Gateway
resource "aws_internet_gateway" "dev-igway" {
  vpc_id = aws_vpc.dev-vpc.id
  tags = {
    "Name" = "dev-250-igateway"
  }
}

#Create Route Table - attached with subnet
resource "aws_route_table" "dev-rt" {
  vpc_id = aws_vpc.dev-vpc.id
}
#Create Route in Route Table for Internet Access
resource "aws_route" "dev-route" {
  route_table_id         = aws_route_table.dev-rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.dev-igway.id
}

#Associate Route Table with Subnet
resource "aws_route_table_association" "dev-rt-assoc" {
  route_table_id = aws_route_table.dev-rt.id
  subnet_id      = aws_subnet.dev-websunet.id
}

#Create Security Group in the VPC with port 80, 22 as inbound open
resource "aws_security_group" "dev-sg" {
  name        = "dev-web-ssh-sg"
  vpc_id      = aws_vpc.dev-vpc.id
  description = "Dev web server traffic allowed ssh & http"

}

resource "aws_vpc_security_group_ingress_rule" "dev-ingress-22" {
  security_group_id = aws_security_group.dev-sg.id
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "dev-ingress-80" {
  security_group_id = aws_security_group.dev-sg.id
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "dev-egress" {
  security_group_id = aws_security_group.dev-sg.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_instance" "dev-web1" {
  ami =  "ami-06b21ccaeff8cd686"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.dev-websunet.id
  vpc_security_group_ids = [ aws_security_group.dev-sg.id ]
  key_name = "ec2-dev-250-key"
  #user_data = file("webinstall.sh")
  user_data = <<-EOF
    #!bin/bash
    sudo yum update -y
    sudo yum install httpd -y
    sudo systemctl enable httpd
    sudo systemctl start httpd
    echo "welcome to web server depolyed using TF" >/var/www/html/index.html
    EOF
  tags = {
    "Name" = "dev-250 -webvm"
  }
}
resource "aws_eip" "dev-eip" {
  instance = aws_instance.dev-web1.id
  depends_on = [ aws_internet_gateway.dev-igway ]
  tags = {
    Name = "dev-ec2-elastic-IP"
  }
}
    
output "ec2ip" {
  value = aws_eip.dev-eip.address
}

