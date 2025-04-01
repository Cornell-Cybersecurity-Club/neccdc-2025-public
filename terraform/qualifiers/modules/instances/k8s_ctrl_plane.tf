data "aws_ami" "kubernetes_ctrl_plane" {
  most_recent = true

  filter {
    name   = "name"
    values = ["packer-kubernetes-ctrl-plane-*"]
  }
}


resource "aws_instance" "kubernetes_ctrl_plane" {
  ami           = data.aws_ami.kubernetes_ctrl_plane.image_id
  instance_type = "t3a.medium"
  key_name      = var.key_pair

  subnet_id  = var.subnet_private_id
  private_ip = cidrhost(var.subnet_private_cidr, 255)

  vpc_security_group_ids = [
    var.security_group_id
  ]

  tags = {
    Name    = "${var.team_number}-ctrl-plane"
    service = "kubernetes"
  }
}
