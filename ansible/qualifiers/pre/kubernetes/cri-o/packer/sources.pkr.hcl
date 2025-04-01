# https://www.packer.io/plugins/builders/amazon/ebs
source "amazon-ebs" "vm" {
  region            = "us-east-2"
  ami_name          = "packer-kubernetes-cri-o-${formatdate("YYYY-MMM-DD-hh-mm", timestamp())}"
  subnet_id         = "subnet-04255ba24872d7d79"
  security_group_id = "sg-027af0024a1813997"

  # Canonical, Ubuntu, 22.04 LTS, amd64 jammy image build on 2024-09-27
  # ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-20240927
  source_ami                  = "ami-00eb69d236edcfaf8"
  instance_type               = "t3a.medium"
  associate_public_ip_address = true

  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_type           = "gp3"
    volume_size           = 16
    delete_on_termination = true
  }

  launch_block_device_mappings {
    device_name           = "/dev/sdb"
    volume_type           = "gp3"
    volume_size           = 32
    delete_on_termination = true
  }

  tags = {
    "Name" = "packer-kubernetes-cri-o"
    "date" = formatdate("YYYY-MM-DD hh:mm", timestamp())
  }
  run_tags = {
    "Name" = "packer-tmp-build-server-cri-o"
  }
}
