# https://www.packer.io/plugins/builders/amazon/ebs
source "amazon-ebs" "vm" {
  region            = "us-east-2"
  ami_name          = "packer-graylog-${formatdate("YYYY-MMM-DD-hh-mm", timestamp())}"
  subnet_id         = "subnet-04255ba24872d7d79"
  security_group_id = "sg-027af0024a1813997"

  # debian-12-amd64-20240702-1796
  source_ami                  = "ami-0002aa901e88cc81d"
  instance_type               = "t3a.large"
  associate_public_ip_address = true

  profile = "neccdc-2025"

  launch_block_device_mappings {
    device_name           = "/dev/xvda"
    volume_type           = "gp3"
    volume_size           = 48
    delete_on_termination = true
  }

  tags = {
    "Name" = "packer-graylog"
    "date" = formatdate("YYYY-MM-DD hh:mm", timestamp())
  }
  run_tags = {
    "Name" = "packer-tmp-build-server-graylog"
  }
}
