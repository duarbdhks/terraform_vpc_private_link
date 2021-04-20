resource "aws_key_pair" "web_admin" {
  key_name   = "web_admin"
  public_key = file("~/.ssh/web_admin.pub")
}

#### EC2, AZ: ap-northeast-2a ####
resource "aws_instance" "public_2a" {
  ami                    = var.amazon_linux
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_2a.id
  iam_instance_profile   = aws_iam_instance_profile.ec2profile.name
  key_name               = var.dev_key_name
  vpc_security_group_ids = [aws_security_group.dev_security_group_public_2a.id]
  tags = {
    Name = "dev-public-2a"
  }
}

resource "aws_instance" "private_2a" {
  ami                    = var.amazon_linux
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private_2a.id
  iam_instance_profile   = aws_iam_instance_profile.ec2profile.name
  key_name               = var.dev_key_name
  vpc_security_group_ids = [aws_security_group.dev_security_group_private_2a.id]
  tags = {
    Name = "dev-private-2a"
  }
}

#### EC2, AZ: ap-northeast-2c ####
resource "aws_instance" "public_2c" {
  ami                    = var.amazon_linux
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_2c.id
  iam_instance_profile   = aws_iam_instance_profile.ec2profile.name
  key_name               = var.dev_key_name
  vpc_security_group_ids = [aws_security_group.dev_security_group_public_2c.id]
  tags = {
    Name = "dev-public-2c"
  }
}

resource "aws_instance" "private_2c" {
  ami                    = var.amazon_linux
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private_2c.id
  iam_instance_profile   = aws_iam_instance_profile.ec2profile.name
  key_name               = var.dev_key_name
  vpc_security_group_ids = [aws_security_group.dev_security_group_private_2c.id]
  tags = {
    Name = "dev-private-2c"
  }
}