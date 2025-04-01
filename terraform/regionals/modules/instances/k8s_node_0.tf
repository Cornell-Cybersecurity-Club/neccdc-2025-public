data "aws_ami" "kubernetes_crio" {
  most_recent = true

  filter {
    name   = "name"
    values = ["packer-kubernetes-cri-o-*"]
  }
}


resource "aws_instance" "kubernetes_crio" {
  ami           = data.aws_ami.kubernetes_crio.image_id
  instance_type = "t3a.medium"

  key_name             = var.key_pair
  iam_instance_profile = data.aws_iam_instance_profile.session_manager.name

  subnet_id  = var.subnet_private_id
  private_ip = cidrhost(var.subnet_private_cidr, 8)

  vpc_security_group_ids = [
    var.security_group_id
  ]

  tags = {
    Name    = "${var.team_number}-crio"
    service = "kubernetes"
  }
}
