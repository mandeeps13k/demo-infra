
resource "aws_key_pair" "example_keypair" {
  key_name   = "example-keypair"  
  public_key = ""
}



resource "aws_security_group" "ec2_instance_sg" {
  name        = "https-access-sg"
  description = "Security group allowing HTTPS traffic"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }
}


resource "aws_instance" "example_instance" {
  ami             = "ami-0d0dd86aa7fe3c8a9"  
  instance_type   = "t3.micro"  

  key_name        = aws_key_pair.example_keypair.key_name
  security_groups = [aws_security_group.ec2_instance_sg.name]

  metadata_options {
    http_endpoint = "disabled"
  }

  tags = {
    Name = "Example-Instance"
  }
}

resource "aws_kms_key" "database_key" {
  description             = "KMS key for RDS encryption"
  deletion_window_in_days = 30  
  enable_key_rotation = true
}

resource "aws_security_group" "rds_db_security_group" {
  name        = "rds-db-security-group"
  description = "Security group for RDS database"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.ec2_instance_sg.id]
  }
}

resource "aws_db_instance" "example_db" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "8.0.35"
  instance_class       = "db.t3.micro"
  db_name              = "demo"
  username             = "admin"
  password             = ${{ secrets.DB_PASSWORD }}  
  vpc_security_group_ids = [aws_security_group.rds_db_security_group.id]
  enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"]

  kms_key_id           = aws_kms_key.database_key.arn
  storage_encrypted   = true
  skip_final_snapshot = true

}
