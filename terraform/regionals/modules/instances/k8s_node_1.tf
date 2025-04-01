data "aws_ami" "kubernetes_docker" {
  most_recent = true

  filter {
    name   = "name"
    values = ["packer-kubernetes-docker-*"]
  }
}


resource "aws_instance" "kubernetes_docker" {
  ami           = data.aws_ami.kubernetes_docker.image_id
  instance_type = "t3a.medium"

  key_name             = var.key_pair
  iam_instance_profile = data.aws_iam_instance_profile.session_manager.name

  subnet_id  = var.subnet_private_id
  private_ip = cidrhost(var.subnet_private_cidr, 19)

  vpc_security_group_ids = [
    var.security_group_id
  ]

  tags = {
    Name    = "${var.team_number}-docker"
    service = "kubernetes"
  }
}
