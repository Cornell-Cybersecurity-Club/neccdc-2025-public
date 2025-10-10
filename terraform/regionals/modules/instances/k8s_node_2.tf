data "aws_ami" "kubernetes_containerd" {
  most_recent = true

  filter {
    name   = "name"
    values = ["packer-kubernetes-containerd-*"]
  }
}


resource "aws_instance" "kubernetes_containerd" {
  ami           = data.aws_ami.kubernetes_containerd.image_id
  instance_type = "t3.small"  # Optimized: was t3a.medium ($27/mo), now t3.small ($15/mo)

  key_name             = var.key_pair
  iam_instance_profile = data.aws_iam_instance_profile.session_manager.name

  subnet_id  = var.subnet_private_id
  private_ip = cidrhost(var.subnet_private_cidr, 30)

  vpc_security_group_ids = [
    var.security_group_id
  ]

  tags = {
    Name    = "${var.team_number}-containerd"
    service = "kubernetes"
  }
}
