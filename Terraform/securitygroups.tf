resource "aws_security_group" "vpc_all_traffic" {
  name        = "vpc-allow-all-test-sg"
  description = "TEST LAB ONLY: Allow all inbound and outbound traffic within/outside VPC"
  vpc_id      = aws_vpc.app_vpc.id
  depends_on = [aws_vpc.app_vpc]

  ingress {
    description      = "Allow all inbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    description      = "Allow all outbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name        = "vpc-allow-all-sg"
    Environment = "production"
  }
}

resource "aws_security_group" "rds-sg" {
  name        = "vpc-rds-access-test-sg"
  description = "TEST LAB ONLY: Allow RDS access from anywhere"
  vpc_id      = aws_vpc.app_vpc.id
  depends_on = [aws_vpc.app_vpc, aws_db_subnet_group.sqldb_subnet_group]


  ingress {
    description      = "Allow RDS access"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    security_groups = [aws_security_group.lambda_sg.id]
  }

 egress {
    description      = "Allow all outbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
 }
}   



resource "aws_security_group" "endpoint_sg" {
  name        = "endpoint-sg"
  description = "Interface Endpoint security group to allow inbound/outbound from the VPC"
  vpc_id      = aws_vpc.app_vpc.id
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.lambda_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}  

resource "aws_security_group" "lambda_sg" {
  name        = "lambda-sg"
  description = "Lambda security group to allow outbound traffic to the VPC"
  vpc_id      = aws_vpc.app_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"              
    cidr_blocks = ["0.0.0.0/0"]
  }
}  
