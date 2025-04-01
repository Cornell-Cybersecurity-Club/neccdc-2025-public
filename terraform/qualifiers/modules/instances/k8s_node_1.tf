data "aws_ami" "kubernetes_containerd" {
  most_recent = true

  filter {
    name   = "name"
    values = ["packer-kubernetes-cri-o-*"]
  }
}


resource "aws_instance" "kubernetes_containerd" {
  ami           = data.aws_ami.kubernetes_containerd.image_id
  instance_type = "t3a.medium"
  key_name      = var.key_pair

  subnet_id  = var.subnet_private_id
  private_ip = cidrhost(var.subnet_private_cidr, 256)

  vpc_security_group_ids = [
    var.security_group_id
  ]

  tags = {
    Name    = "${var.team_number}-containerd"
    service = "kubernetes"
  }
}
