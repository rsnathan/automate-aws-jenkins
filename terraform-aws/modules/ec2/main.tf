
resource "aws_instance" "web" {
  instance_type = "${var.instance_type}"
  count = "${var.count}"
  # AMI to be used
  ami = "${var.ami_id}"
  # SSH keypair to use
  key_name = "${var.key_name}" 
  # Our Security group to allow HTTP and SSH access
  security_groups= ["${split(",", var.security_groups)}"]
  # Subnet id to use
  #count          = "${length(var.subnets)}"
  subnet_id      = "${element(split(",",var.subnets), 0)}"
  associate_public_ip_address = true
   tags {
      Name = "${var.name}-${var.environment}-ec2"
      environment =  "${var.environment}"
    }
}
output "instances" {
value = "${join(",", aws_instance.web.*.id)}"
}
output "publicIP"{
value ="${join(",", aws_instance.web.*.public_ip)}"
}


