data "aws_ami" "database" {
  most_recent = true

  filter {
    name   = "name"
    values = ["packer-database-*"]
  }
}


resource "aws_instance" "database" {
  ami           = data.aws_ami.database.image_id
  instance_type = "t3a.small"
  key_name      = var.key_pair

  subnet_id  = var.subnet_private_id
  private_ip = cidrhost(var.subnet_private_cidr, 448)

  vpc_security_group_ids = [
    var.security_group_id
  ]

  tags = {
    Name    = "${var.team_number}-database"
    service = "database"
  }
}
