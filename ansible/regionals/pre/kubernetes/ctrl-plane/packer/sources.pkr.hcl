# https://www.packer.io/plugins/builders/amazon/ebs
source "amazon-ebs" "vm" {
  region            = "us-east-2"
  ami_name          = "packer-kubernetes-ctrl-plane-${formatdate("YYYY-MMM-DD-hh-mm", timestamp())}"
  subnet_id         = "subnet-04255ba24872d7d79"
  security_group_id = "sg-027af0024a1813997"

  # ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-20240927
  # Canonical, Ubuntu, 24.04, amd64 noble image
  source_ami                  = "ami-0ea3c35c5c3284d82"
  instance_type               = "t3a.medium"
  associate_public_ip_address = true

  profile = "neccdc-2025"

  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_type           = "gp3"
    volume_size           = 16
    delete_on_termination = true
  }

  tags = {
    "Name" = "packer-kubernetes-ctrl-plane"
    "date" = formatdate("YYYY-MM-DD hh:mm", timestamp())
  }
  run_tags = {
    "Name" = "packer-tmp-build-server-ctrl-plane"
  }
}
