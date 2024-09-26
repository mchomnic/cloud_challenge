# variable "ec2_size" {
#   description = "EC2 size base on the environment"
#   type = string
# }

# data "aws_iam_instance_profile" "ssm_iam_role" {
#   name = "SystemManagementRole"
# }

# data "aws_ami" "ubuntu_image" {
#   most_recent = true

#   filter {
#     name   = "name"
#     # values = ["ubuntu/images/hvm-ssd/ubuntu-lunar-24.04-amd64-server-*"] # Updated for Ubuntu 24.04 (Lunar)
#     values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"] # Ubuntu 22.04 (Jammy)
#   }

#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }

#   owners = ["099720109477"] # Canonical's AWS Account ID
# }

# # Define the Security Group
# resource "aws_security_group" "web_sg" {
#   name        = "web_sg"
#   description = "Allow HTTP, HTTPS, and SSH"
#   vpc_id      = aws_vpc.main.id

#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["134.191.0.0/16"]
#   }

#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["134.191.0.0/16"]
#   }

#   ingress {
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"
#     cidr_blocks = ["134.191.0.0/16"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# # Launch EC2 Instance for Web
# resource "aws_instance" "web_instance" {
#   ami                         = data.aws_ami.ubuntu_image.id
#   instance_type               = var.ec2_size
#   vpc_security_group_ids      = [aws_security_group.web_sg.id]
#   associate_public_ip_address = true
#   subnet_id                   = aws_subnet.public_subnet_a.id
#   iam_instance_profile        = data.aws_iam_instance_profile.ssm_iam_role.name

#   tags = {
#     Name = "${var.environment}-WebInstance"
#     Terraform = "true"
#   }

#   user_data = <<-EOF
#     #!/bin/bash
#     apt-get update -y
#     apt-get install apache2 -y
#     systemctl start apache2
#     systemctl enable apache2
#     apt install nodejs npm -y
#     git clone https://github.com/designmodo/html-website-templates.git /var/www/html/web
#     cp -R /var/www/html/web/'One Page Portfolio Website Template' /var/www/html/web/one_page
#     sudo chown -R www-data:www-data /var/www/html/
#     sudo chmod -R 755 /var/www/html/
#     sed -i 's/\/var\/www\/html/\/var\/www\/html\/web\/one_page/g' /etc/apache2/sites-available/000-default.conf
#     systemctl restart apache2
#   EOF
# }

# # Output the web server URL
# output "web_instance_public_ip" {
#   value = aws_instance.web_instance.public_ip
# }

# # RDS Subnet Group
# resource "aws_db_subnet_group" "web_db_subnet_group" {
#   name       = "${var.environment}-web-db-subnet-group"
#   subnet_ids = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]

#   tags = {
#     Name = "${var.environment}-WebDBSubnetGroup"
#   }
# }

# # RDS (MariaDB) instance for Web
# resource "aws_db_instance" "web_db" {
#   allocated_storage   = 10
#   engine              = "mariadb"
#   instance_class      = "db.t3.micro"
#   username            = "admin"
#   password            = "password123"
#   publicly_accessible = false
#   vpc_security_group_ids = [aws_security_group.web_sg.id]
#   db_subnet_group_name = aws_db_subnet_group.web_db_subnet_group.name
#   skip_final_snapshot = true

#   tags = {
#     Name = "${var.environment}-WebDB"
#     Terraform = "true"
#   }
# }

# output "web_db_endpoint" {
#   value = aws_db_instance.web_db.endpoint
# }
