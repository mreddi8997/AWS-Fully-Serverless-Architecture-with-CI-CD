resource "aws_vpc" "app_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "app_public_subnet_1" {
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
    tags = {
        Name = "app-public-subnet-1"
    }
}

resource "aws_subnet" "app_public_subnet_2" {
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true
    tags = {
        Name = "app-public-subnet-2"
    }
}

resource "aws_subnet" "app_private_subnet_1" {
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"
    tags = {
        Name = "app-private-subnet-1"
    }
}
resource "aws_subnet" "app_private_subnet_2" {
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"
    tags = {
        Name = "app-private-subnet-2"
    }
}

resource "aws_subnet" "app_database_subnet_1" {
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = "10.0.5.0/24"
   availability_zone = "us-east-1a"
     tags = {
            Name = "app-database-subnet-1"
        }
}        

resource "aws_subnet" "app_database_subnet_2" {
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = "10.0.6.0/24" 
  availability_zone = "us-east-1b"
    tags = {
        Name = "app-database-subnet-2"
    }
}

resource "aws_internet_gateway" "app_igw" {
  vpc_id = aws_vpc.app_vpc.id
    tags = {
        Name = "app-igw"
    }
}           

resource "aws_route_table" "app_public_rt" {
  vpc_id = aws_vpc.app_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.app_igw.id
  }
    tags = {
        Name = "app-public-rt"
    }
}           


resource "aws_route_table_association" "app_public_rt_assoc_1" {
  subnet_id      = aws_subnet.app_public_subnet_1.id
  route_table_id = aws_route_table.app_public_rt.id
}

resource "aws_route_table_association" "app_public_rt_assoc_2" {
  subnet_id      = aws_subnet.app_public_subnet_2.id
  route_table_id = aws_route_table.app_public_rt.id
}

resource "aws_eip" "app_nat_eip" {
  domain = "vpc"
  depends_on = [aws_internet_gateway.app_igw]

  tags = {
    Name = "app-nat-eip"
  }
}

resource "aws_nat_gateway" "app_nat_gw" {
  allocation_id = aws_eip.app_nat_eip.id
  subnet_id     = aws_subnet.app_public_subnet_1.id
  depends_on    = [aws_internet_gateway.app_igw]

  tags = {
    Name = "app-nat-gw"
  }
}

resource "aws_route_table" "app_private_rt" {
  vpc_id = aws_vpc.app_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.app_nat_gw.id
  }
    tags = {
        Name = "app-private-rt"
    }
}           

resource "aws_route_table_association" "app_private_rt_assoc_1" {
  subnet_id      = aws_subnet.app_private_subnet_1.id
  route_table_id = aws_route_table.app_private_rt.id
}

resource "aws_route_table_association" "app_private_rt_assoc_2" {
  subnet_id      = aws_subnet.app_private_subnet_2.id
  route_table_id = aws_route_table.app_private_rt.id
}
