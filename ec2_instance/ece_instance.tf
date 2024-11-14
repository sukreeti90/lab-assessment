resource "aws_instance" "ec2_aws_instance" {
  
  ami = "ami-0866a3c8686eaeeba"
  instance_type = "t2.micro"
  tags = {
    Name = "devvm"
    cidr_block = "10.0.0.0/16"
  }
}

