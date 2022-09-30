locals {
  vpc_id           = "vpc-8791faec"
  subnet_id        = "subnet-4c72bb31"
  ssh_user         = "ubuntu"
  key_name         = "chan"
  private_key_path = ""
}

provider "aws" {
  region = "us-east-2"
}

resource "aws_security_group" "nginx" {
  name   = "nginx_access"
  vpc_id = local.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "nginx" {
  ami                         = "ami-097a2df4ac947655f"
  subnet_id                   = "subnet-4c72bb31"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  security_groups             = [aws_security_group.nginx.id]
  key_name                    = local.key_name

  provisioner "file" {
        source="script.sh"
        destination="/tmp/script.sh"
  
  provisioner "remote-exec" {
     inline=[
       "chmod +x /tmp/script.sh",
       "sudo /tmp/script.sh"
     ]
  }

    connection {
      type        = "ssh"
      user        = local.ssh_user
      private_key = file(local.private_key_path)
      host        = aws_instance.nginx.public_ip
    }
  
  provisioner "local-exec" {
    command = "ansible-playbook  -i ${aws_instance.nginx.public_ip}, --private-key ${local.private_key_path} nginx.yaml"
    }
  }
}


output "nginx_ip" {
  value = aws_instance.nginx.public_ip
}
