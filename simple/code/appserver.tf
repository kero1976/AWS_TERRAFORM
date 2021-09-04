# -----------------------------------------------
# Key Pair
# -----------------------------------------------
resource "aws_key_pair" "keypair" {
  key_name   = "${var.project}-${var.environment}-keypair"
  public_key = file("./src/keypair.pub")
  tags = {
    Name    = "${var.project}-${var.environment}-keypair"
    Project = var.project
    Env     = var.environment
  }
}

# -----------------------------------------------
# EC2 Instance
# -----------------------------------------------
resource "aws_instance" "app_server-public-1a" {
   ami                         = "ami-0b276ad63ba2d6009" // Amazon Linux
  // ami                         = "ami-0bccc42bba4dedac1" //Redhat 8.4
  //ami                         = "ami-0bae31a909eda0db6" // Custom Ami is WordPress is Installed.
  instance_type               = "t3a.micro"
  subnet_id                   = aws_subnet.public_subnet_1a.id
  associate_public_ip_address = true
  vpc_security_group_ids = [
    aws_security_group.web_sg.id
  ]
  key_name = aws_key_pair.keypair.key_name
  tags = {
    Name    = "${var.project}-${var.environment}-app-ec2-public-1a"
    Project = var.project
    Env     = var.environment
    Type    = "app"
  }
   user_data = <<EOF
  #!/bin/bash
  ### 日本語設定
  localectl set-locale LANG=ja_JP.UTF-8
  ### 時刻設定
  cp /usr/share/zoneinfo/Japan /etc/localtime
  sed -i 's|^ZONE=[a-zA-Z0-9\.\-\"]*$|ZONE="Asia/Tokyo"|g' /etc/sysconfig/clock
  ### Apacheインストールし、自動起動を有効にする
  yum update -y
  yum install httpd -y
  systemctl enable httpd
  systemctl start httpd
  EOF
}
