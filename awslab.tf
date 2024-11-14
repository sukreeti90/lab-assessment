terraform {
  #required_version = "1.9.4"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.74.0"
    }
    
  
  }
}

provider "aws" {
  region = "us-east-1"
  
}

provider "local" {
  
}

resource "aws_vpc" "vnet" {
  cidr_block = "10.100.0.0/16"
  tags = {
    name = "demo_25"
   
  }
}

resource "aws_subnet" "websub" {
  vpc_id = "vpc-0f6ef352732182c53"
  cidr_block = "10.100.1.0/24"

  tags = {
    name = "25websubnet"
  } 
}

resource "aws_subnet" "dbsn" {
vpc_id = aws_vpc.vnet.id
cidr_block = "10.100.2.0/24"
tags = {
  name = "25dbsubnet"
}
  
}