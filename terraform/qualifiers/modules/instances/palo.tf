resource "aws_instance" "palo" {
  instance_type = "c6gn.xlarge" # ARM Instance
  ami           = "ami-0d0b86f27cyyyyyyy"

  key_name = var.key_pair

  network_interface {
    network_interface_id = var.palo_instance_interfaces.management
    device_index         = 0
  }

  network_interface {
    network_interface_id = var.palo_instance_interfaces.public
    device_index         = 1
  }

  network_interface {
    network_interface_id = var.palo_instance_interfaces.private
    device_index         = 2
  }

  network_interface {
    network_interface_id = var.palo_instance_interfaces.dmz
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
    Name    = "${var.team_number}-PaloAlto"
    service = "PaloAlto"
  }

  volume_tags = {
    service = "PaloAlto"
  }
}
