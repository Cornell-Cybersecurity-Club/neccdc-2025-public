resource "aws_eip" "scorestack" {
  domain   = "vpc"
  instance = aws_instance.scorestack.id

  tags = {
    Name = "scorestack"
  }
}

resource "aws_route53_record" "scorestack" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "score.${aws_route53_zone.private.name}"
  type    = "A"
  ttl     = "300"
  records = [aws_eip.scorestack.public_ip]
}


resource "aws_instance" "scorestack" {
  ami           = data.aws_ami.ec2.id
  instance_type = "t3a.xlarge"

  iam_instance_profile = aws_iam_instance_profile.ssm.id

  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [aws_security_group.scorestack.id]
  associate_public_ip_address = true
  private_ip                  = "172.16.1.200"

  key_name = aws_key_pair.black_team.id

  root_block_device {
    volume_type = "gp3"
    volume_size = 80
  }

  tags = {
    Name = "scorestack"
  }
}


resource "aws_security_group" "scorestack" {
  name        = "scorestack"
  description = "Allow traffic in and out of scorestack"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Black team ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ips
  }

  ingress {
    description = "Public ingress"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = concat(["0.0.0.0/0"], var.allowed_ips)
  }

  ingress {
    description = "Public ingress"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = concat(["0.0.0.0/0"], var.allowed_ips)
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "scorestack"
  }
}
