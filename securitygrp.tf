provider "aws" {
  region = "us-east-1"  
}
 
resource "aws_security_group" "dev-sg" {
  name        = "dev-web-ssh-sg"
  vpc_id      = "vpc-0255bdb78e96d17db"
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