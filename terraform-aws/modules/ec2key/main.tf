 resource "aws_key_pair" "ec2key" {
  key_name = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}

output "ec2key_name" {
  value = "${aws_key_pair.ec2key.key_name}"
}
