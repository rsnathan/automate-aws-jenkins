
output "elb_dns_name_FE" {
  value = "${module.elb_FE.elb_dns_name}"
}
output "publicIP_FE" {
  value = "${module.ec2_FE.publicIP}"
}

output "elb_dns_name_BE" {
  value = "${module.elb_BE.elb_dns_name}"
}
output "publicIP_BE" {
  value = "${module.ec2_BE.publicIP}"
}

