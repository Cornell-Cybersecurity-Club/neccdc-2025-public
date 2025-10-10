data "aws_ami" "packer_pfsense" {
  most_recent = true

  filter {
    name   = "name"
    values = ["packer-pfsense-24.11*"]
  }
}


resource "aws_instance" "pfSense" {
  instance_type = "t3.small"  # Optimized: was c5.xlarge ($124/mo), now t3.small ($15/mo)
  ami           = data.aws_ami.packer_pfsense.id
  key_name      = var.key_pair

  user_data = "password=CHANGE_ME"

  network_interface {
    network_interface_id = var.pfSense_instance_interfaces.public
    device_index         = 0
  }

  network_interface {
    network_interface_id = var.pfSense_instance_interfaces.private
    device_index         = 1
  }

  network_interface {
    network_interface_id = var.pfSense_instance_interfaces.corp
    device_index         = 2
  }

  network_interface {
    network_interface_id = var.pfSense_instance_interfaces.dmz
    device_index         = 3
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 3
    http_tokens                 = "optional"
    instance_metadata_tags      = "enabled"
  }

  root_block_device {
    delete_on_termination = true
  }

  tags = {
    Name    = "${var.team_number}-pfSense"
    service = "pfSense"
  }

  volume_tags = {
    service = "pfSense"
  }
}
