# https://www.packer.io/plugins/builders/amazon/ebs
source "amazon-ebs" "vm" {
  region            = "us-east-2"
  ami_name          = "packer-nginx-${formatdate("YYYY-MMM-DD-hh-mm", timestamp())}"
  subnet_id         = "subnet-04255ba24872d7d79"
  security_group_id = "sg-027af0024a1813997"

  # https://aws.amazon.com/marketplace/pp/prodview-6ihwigagrts66
  # Rocky-9-EC2-Base-9.4-20240523.0.aarch64-0d51926d-1cd1-4223-bda9-346993accc16
  source_ami                  = "ami-047e0292bc00ae1de"
  instance_type               = "t4g.medium"
  associate_public_ip_address = true

  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_type           = "gp3"
    volume_size           = 11
    delete_on_termination = true
  }

  tags = {
    Name = "packer-nginx"
    date = formatdate("YYYY-MM-DD hh:mm", timestamp())
  }
  run_tags = {
    Name = "packer-tmp-build-server-nginx"
  }
}
