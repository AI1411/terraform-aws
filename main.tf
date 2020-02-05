provider "aws" {
  profile = "default"
  region = "ap-northeast-1"
}

resource "aws_instance" "ec2" {
  ami = "ami-011facbea5ec0363b"
  instance_type = "t3.micro"

  user_data = <<EOF
#!/bin/bash
yum install -y httpd
systemctl start httpd.service
EOF

  tags = {
    Name = "ec2"
  }
}