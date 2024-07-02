data "aws_availability_zones" "Demo-Available" {
    state = "available"
}
resource "aws_vpc" "Demo-vpc" {
    cidr_block = "10.0.0.0/16"
    enable_dns_support = true
    enable_dns_hostnames = true
    tags = {
        Name = "Demo-vpc"
    }
}
resource "aws_subnet" "Demo-subnet-public-1" {
    vpc_id = aws_vpc.Demo-vpc.id
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = true
    availability_zone = data.aws_availability_zones.Demo-Available.names[0]
    tags = {
        Name = "Demo-subnet-public-1"
    }
}
resource "aws_subnet" "Demo-subnet-public-2" {
    vpc_id = aws_vpc.Demo-vpc.id
    cidr_block = "10.0.2.0/24"
    map_public_ip_on_launch = true
    availability_zone = data.aws_availability_zones.Demo-Available.names[1]
    tags = {
        Name = "Demo-subnet-public-2"
    }
}
resource "aws_subnet" "Demo-subnet-public-3" {
    vpc_id = aws_vpc.Demo-vpc.id
    cidr_block = "10.0.3.0/24"
    map_public_ip_on_launch = true
    availability_zone = data.aws_availability_zones.Demo-Available.names[2]
    tags = {
        Name = "Demo-subnet-public-3"
    }
}
# resource "aws_subnet" "Demo-subnet-priavet-1" {
#     vpc_id = aws_vpc.Demo-vpc.id
#     cidr_block = "10.0.11.0/24"
#     map_public_ip_on_launch = false
#     availability_zone = data.aws_availability_zones.Demo-Available.names[0]
#     tags = {
#         Name = "Demo-subnet-priavet-11"
#     }
# }
# resource "aws_subnet" "Demo-subnet-priavet-2" {
#     vpc_id = aws_vpc.Demo-vpc.id
#     cidr_block = "10.0.12.0/24"
#     map_public_ip_on_launch = false
#     availability_zone = data.aws_availability_zones.Demo-Available.names[1]
#     tags = {
#         Name = "Demo-subnet-priavet-12"
#     }
# }
# resource "aws_subnet" "Demo-subnet-priavet-3" {
#     vpc_id = aws_vpc.Demo-vpc.id
#     cidr_block = "10.0.13.0/24"
#     map_public_ip_on_launch = false
#     availability_zone = data.aws_availability_zones.Demo-Available.names[2]
#     tags = {
#         Name = "Demo-subnet-priavet-13"
#     }
# }
resource "aws_internet_gateway" "Demo-igw" {
    vpc_id = aws_vpc.Demo-vpc.id
    tags = {
        Name = "Demo-igw"
    }
}
resource "aws_route_table" "Demo-public-route" {
    vpc_id = aws_vpc.Demo-vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.Demo-igw.id
    }
    route {
        cidr_block = "10.0.0.0/16"
        gateway_id = "local"
    }
    tags = {
        Name = "Demo-public-route"
    }
}
resource "aws_route_table_association" "Demo-public-1-a" {
    subnet_id = aws_subnet.Demo-subnet-public-1.id
    route_table_id = aws_route_table.Demo-public-route.id
}
resource "aws_route_table_association" "Demo-public-2-a" {
    subnet_id = aws_subnet.Demo-subnet-public-2.id
    route_table_id = aws_route_table.Demo-public-route.id
}
resource "aws_route_table_association" "Demo-public-3-a" {
    subnet_id = aws_subnet.Demo-subnet-public-3.id
    route_table_id = aws_route_table.Demo-public-route.id
}
resource "aws_security_group" "Web-server-SG" {
    name = "Web-server-SG"
    vpc_id = aws_vpc.Demo-vpc.id
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        security_groups = [aws_security_group.Sg-Public-ALB.id]
    }
     ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        security_groups = [aws_security_group.Sg-Public-ALB.id]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name = "Web-server-SG"
    }
}

resource "aws_security_group" "Sg-Public-ALB" {
    name = "Sg-Public-ALB"
    vpc_id = aws_vpc.Demo-vpc.id
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name = "Sg-Public-ALB"
    }
}
resource "aws_launch_template" "first-LT" {
    name = "first-LT"
    image_id = "ami-07d7e3e669718ab45"
    instance_type = "t2.micro"
    key_name = "April30th2024"
    vpc_security_group_ids = [aws_security_group.Web-server-SG.id]
    tag_specifications {
        resource_type = "instance"
        tags = {
            Name = "web"
        }
    }
}
resource "aws_lb_target_group" "Demo-TG" {
    name = "Demo-TG"
    port = 80
    protocol = "HTTP"
    vpc_id = aws_vpc.Demo-vpc.id
}
resource "aws_lb" "Demo-LB" {
    name = "Demo-LB"
    internal = false
    load_balancer_type = "application"
    security_groups = [aws_security_group.Sg-Public-ALB.id]
    subnets = [aws_subnet.Demo-subnet-public-1.id,aws_subnet.Demo-subnet-public-2.id,aws_subnet.Demo-subnet-public-3.id]
    tags = {
        Name = "Demo-LB"
    }
}
resource "aws_lb_listener" "Demo-LB-listener" {
    load_balancer_arn = aws_lb.Demo-LB.arn
    port = 80
    protocol = "HTTP"
    default_action {
        type = "forward"
        target_group_arn = aws_lb_target_group.Demo-TG.arn
    }
} 
resource "aws_autoscaling_group" "Demo-ASG" {
    name = "Demo-ASG"
    desired_capacity = 1
    max_size = 3
    min_size = 1
    vpc_zone_identifier = [aws_subnet.Demo-subnet-public-1.id,aws_subnet.Demo-subnet-public-2.id,aws_subnet.Demo-subnet-public-3.id]
    launch_template {
        id = aws_launch_template.first-LT.id
        version = "$Latest"
    }

}
resource "aws_lb_target_group_attachment" "Demo-TG-attach" {
    target_group_arn = aws_lb_target_group.Demo-TG.arn
    target_id = aws_instance.web-server-1.id
    port = 80
}
resource "aws_instance" "web-server-1" {
    ami = "ami-07d7e3e669718ab45"
    instance_type = "t2.micro"
    #availability_zone = "us-east-2a"
    key_name = "April30th2024"
    vpc_security_group_ids = [aws_security_group.Web-server-SG.id]
    associate_public_ip_address = true
    subnet_id = aws_subnet.Demo-subnet-public-1.id
    user_data = file("${path.module}/script.sh")
    tags = {
        Name = "web-server-1"
    }
}
resource "aws_autoscaling_policy" "Demo-auto-scaling" { 
    name = "Demo-auto-scaling"
    autoscaling_group_name = aws_autoscaling_group.Demo-ASG.name
    policy_type = "TargetTrackingScaling"
    target_tracking_configuration {
        predefined_metric_specification {
            predefined_metric_type = "ASGAverageCPUUtilization"
        }
        target_value = 70
    }
}

  

  

  
