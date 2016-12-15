resource "aws_elb" "elb" {
    name = "${var.name}-elb"
    security_groups = ["${split(",", var.security_groups)}"]
    subnets = ["${split(",", var.subnets)}"]
    instances = ["${split(",", var.instances)}"]
    tags {
      Name = "${var.name}-elb"
      environment =  "${var.environment}"
    }

    listener {
    instance_port = "${var.instance_port}"
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
    }

    health_check {
    healthy_threshold = 2
    unhealthy_threshold = 5
    timeout = 15
    target = "TCP:${var.instance_port}"
    interval = 45
    }

    cross_zone_load_balancing = true
    idle_timeout = 400
    connection_draining = true
    connection_draining_timeout = 400

    provisioner "local-exec" {
    command = "echo ELB_DNS_NAME: ${aws_elb.elb.dns_name} >> ${var.name}-${var.environment}.yml"
    }
}

output "elb_name" {
  value = "${aws_elb.elb.name}"
}

output "elb_dns_name" {
  value = "${aws_elb.elb.dns_name}"
}

output "elb_zone_id" {
  value = "${aws_elb.elb.zone_id}"
}
