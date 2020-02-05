variable "instance_type" {}

resource "aws_instance" "default" {
  ami = "ami-011facbea5ec0363b"
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.default.id]
  user_data = <<EOF
#!/bin/bash
yum install -y httpd
systemctl start httpd.service
EOF
}

resource "aws_security_group" "default" {
  name = "ec2-sg"

  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "public_dns" {
  value = aws_instance.default.public_dns
}