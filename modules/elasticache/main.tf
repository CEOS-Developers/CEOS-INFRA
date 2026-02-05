# ElastiCache Subnet Group
resource "aws_elasticache_subnet_group" "main" {
  name       = "${var.project_name}-redis-subnet-group-${var.environment}"
  subnet_ids = var.subnet_ids

  tags = {
    Name        = "${var.project_name}-redis-subnet-group-${var.environment}"
    Environment = var.environment
    Generation  = var.generation
  }
}

# Security Group
resource "aws_security_group" "redis" {
  name        = "${var.project_name}-redis-sg-${var.environment}"
  description = "Security group for Redis"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = var.allowed_security_groups
    description     = "Redis access from application"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name        = "${var.project_name}-redis-sg-${var.environment}"
    Environment = var.environment
    Generation  = var.generation
  }
}

# ElastiCache Replication Group (Redis)
resource "aws_elasticache_replication_group" "main" {
  replication_group_id          = "${var.project_name}-redis-${var.environment}"
  replication_group_description = "Redis cluster for ${var.project_name} ${var.environment}"

  engine               = "redis"
  engine_version       = var.engine_version
  node_type            = var.node_type
  num_cache_clusters   = var.num_cache_nodes
  parameter_group_name = var.parameter_group_name
  port                 = 6379

  subnet_group_name  = aws_elasticache_subnet_group.main.name
  security_group_ids = [aws_security_group.redis.id]

  at_rest_encryption_enabled = var.enable_encryption
  transit_encryption_enabled = var.enable_encryption
  auth_token_enabled         = var.enable_encryption ? true : false

  automatic_failover_enabled = var.num_cache_nodes > 1
  multi_az_enabled           = var.num_cache_nodes > 1

  snapshot_retention_limit = var.snapshot_retention_limit
  snapshot_window          = var.snapshot_window
  maintenance_window       = var.maintenance_window

  tags = {
    Name        = "${var.project_name}-redis-${var.environment}"
    Environment = var.environment
    Generation  = var.generation
  }
}
