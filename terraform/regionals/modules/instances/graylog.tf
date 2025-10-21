data "aws_ami" "graylog" {
  most_recent = true

  filter {
    name   = "name"
    values = ["packer-graylog-*"]
  }

  owners = ["self"]
}


resource "aws_instance" "graylog" {
  ami           = data.aws_ami.graylog.image_id
  instance_type = "t3.medium"  # Optimized: was t3a.large ($55/mo), now t3.medium ($30/mo)

  key_name             = var.key_pair
  iam_instance_profile = data.aws_iam_instance_profile.session_manager.name

  subnet_id  = var.subnet_dmz_id
  private_ip = cidrhost(var.subnet_dmz_cidr, 9)

  vpc_security_group_ids = [
    var.security_group_id
  ]

  tags = {
    Name    = "${var.team_number}-graylog"
    service = "graylog"
  }
}
