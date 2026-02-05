# Security Group
resource "aws_security_group" "ec2" {
  name        = "${var.project_name}-ec2-sg-${var.environment}"
  description = "Security group for EC2 instance"
  vpc_id      = var.vpc_id

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_allowed_cidrs
    description = "SSH access"
  }

  # HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP access"
  }

  # HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS access"
  }

  # Application port (Spring Boot)
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "Application port"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name        = "${var.project_name}-ec2-sg-${var.environment}"
    Environment = var.environment
    Generation  = var.generation
  }
}

# EC2 Instance
resource "aws_instance" "main" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.ec2.id]

  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.root_volume_size
    delete_on_termination = true
  }

  user_data = base64encode(var.user_data)

  tags = {
    Name        = "${var.project_name}-ec2-${var.environment}"
    Environment = var.environment
    Generation  = var.generation
  }
}

# Elastic IP (optional)
resource "aws_eip" "main" {
  count    = var.enable_elastic_ip ? 1 : 0
  instance = aws_instance.main.id
  domain   = "vpc"

  tags = {
    Name        = "${var.project_name}-eip-${var.environment}"
    Environment = var.environment
    Generation  = var.generation
  }
}
