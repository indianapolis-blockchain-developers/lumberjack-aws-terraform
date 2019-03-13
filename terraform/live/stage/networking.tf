# The main VPC contains all the resources
resource "aws_vpc" "lumberjack" {
    cidr_block                 = "${var.VPCCIDR}"
    enable_dns_support         = true
    enable_dns_hostnames       = true   
    tags                       = {
        Name                   = "Lumberjack VPC"
        resource-group         = "${var.resource_group}"
    }
}

# This is the Public Subnet

resource "aws_subnet" "public" {
    vpc_id                     = "${aws_vpc.lumberjack.id}"
    cidr_block                 = "${var.PublicSubnetCIDR}"
    availability_zone          = "${var.availability_zone}"
      
    tags {      
        Name                   = "Public Subnet"
    }
}

# This is the Private Subnet
resource "aws_subnet" "private" {
    vpc_id                     = "${aws_vpc.lumberjack.id}"
    cidr_block                 = "${var.PrivateSubnetCIDR}"
    availability_zone          = "${var.availability_zone}"
      
    tags {      
        Name                   = "Private Subnet"
    }
}    

# The DHCP options set overrides the AWS/EC2 options
resource "aws_vpc_dhcp_options" "dns_resolver" {
    domain_name_servers        = ["1.1.1.1", "8.8.8.8"]
    domain_name                = "ec2.internal"
    tags {       
        Name                   = "ec2.internal"
        resource-group         = "${var.resource_group}"
    }   
}

# Defines the security group for the public subnet
resource "aws_security_group" "bastion-sg" {
    vpc_id                     = "${aws_vpc.lumberjack.id}"
    name                       = "bastion-security-group"
    description                = "AWS Security Group for Bastion Host"
    ingress {           
        from_port              = 22
        to_port                = 22
        protocol               = "tcp"
        cidr_blocks            = ["0.0.0.0/0"] 
    }           
    egress {           
        protocol               = -1
        from_port              = 0
        to_port                = 0
        cidr_blocks            = ["0.0.0.0/0"]
    }
}

# Defines the security group for the private subnet

resource "aws_security_group" "private_sg" {
    vpc_id                     = "${aws_vpc.lumberjack.id}"
    name                       = "private_security-group"
    description                = "AWS Security Group for Kubernetes Node Cluster"
    ingress {           
        from_port              = 22
        to_port                = 22
        protocol               = "tcp"
        cidr_blocks            = ["${var.PublicSubnetCIDR}"]
    }           
          
    ingress {           
        from_port              = -1
        to_port                = -1
        protocol               = "icmp"
        cidr_blocks            = ["${var.PublicSubnetCIDR}"]
    }           
          
    egress {           
        protocol               = -1
        from_port              = 0
        to_port                = 0
        cidr_blocks            = ["0.0.0.0/0"]
    }           
          
    vpc_id                     = "${aws_vpc.lumberjack.id}"
}     

# The internet gateway connects the public subnet to the internet
resource "aws_internet_gateway" "igw" {
  vpc_id                       = "${aws_vpc.lumberjack.id}"
  tags {      
    Environment                = "${var.environment_tag}"
    resource-group             = "${var.resource_group}"
  }
}


# Creates the NAT IP for the private subnet, as seen from within the public one
resource "aws_eip" "NatIP" {
    vpc                        = true
}

# Create the NAT Gateway for Private Subnet

resource "aws_nat_gateway" "NatGateway" {
    allocation_id              = "${aws_eip.NatIP.id}"
    subnet_id                  = "${aws_subnet.public.id}"
}


# Create the Route tables for private subnet

resource "aws_route_table" "k8s-private-rt" {
    vpc_id                     = "${aws_vpc.lumberjack.id}"

    route {
        cidr_block             = "0.0.0.0/0"
        nat_gateway_id         = "${aws_nat_gateway.NatGateway.id}"
    }      
        
    tags {        
        Name                   = "Private Route Table Subnet"
        Environment            = "${var.environment_tag}"
        resource-group         = "${var.resource_group}"
    }
}

# Assign the route table to the private subnet

resource "aws_route_table_association" "k8s-private-rt" {
    subnet_id                  = "${aws_subnet.private.id}"
    route_table_id             = "${aws_route_table.k8s-private-rt.id}"
}

# Create the route tables for the public subnet
resource "aws_route_table" "web-public-rt" {
    vpc_id                     = "${aws_vpc.lumberjack.id}"
    route {      
        cidr_block = "0.0.0.0/0"
        gateway_id             = "${aws_internet_gateway.igw.id}"
    }

    tags {
        Name = "Public Route Table Subnet"
        Environment            = "${var.environment_tag}"
        resource-group         = "${var.resource_group}"
    }
}

# Assign the route table the public subnet
resource "aws_route_table_association" "web-public-rt" {
    subnet_id            = "${aws_subnet.public.id}"
    route_table_id       = "${aws_route_table.web-public-rt.id}"
}

