# Define provider
provider "aws" {
  region = "us-west-2"
}

# Create EC2 instance
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"

  # Attach security group
  vpc_security_group_ids = [aws_security_group.instance.id]

  # Attach IAM role
  iam_instance_profile = aws_iam_instance_profile.instance.name

  # Define user data script for installing PHP and Nginx
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras install -y php7.4
              yum install -y nginx
              systemctl enable nginx
              systemctl start nginx
              EOF
}

# Create security group
resource "aws_security_group" "instance" {
  name_prefix = "web-"

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create IAM instance profile
resource "aws_iam_instance_profile" "instance" {
  name = "web-instance-profile"
  role = aws_iam_role.instance.name
}

# Create IAM role for EC2 instance
resource "aws_iam_role" "instance" {
  name = "web-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Attach policy to IAM role for installing PHP and Nginx
resource "aws_iam_role_policy_attachment" "instance" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.instance.name
}
