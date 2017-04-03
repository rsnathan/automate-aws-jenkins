resource "aws_autoscaling_group" "asg_app" {
  lifecycle { create_before_destroy = true }
  # interpolate the LC into the ASG name so it always forces an update
  name = "${var.name}"
  max_size = 3
  min_size = 1
  wait_for_elb_capacity = 1
  desired_capacity = 1
  health_check_grace_period = 300
  health_check_type = "ELB"
  launch_configuration = "${aws_launch_configuration.lc_app.id}"
  load_balancers = "${var.loadbalancers}"
 

  tag {
      Name = "${var.name}"
      environment =  "${var.environment}"
    propagate_at_launch = true
  }
}

resource "aws_launch_configuration" "lc_app" {
    lifecycle { create_before_destroy = true }

    image_id = "${var.ami}"
    instance_type = "${var.instance_type}"

    # Our Security group to allow HTTP and SSH access
    security_groups = "${var.security_groups}"

    #user_data = "${file("user_data/app-server.sh")}"

    lifecycle {
      create_before_destroy = true
    }
}
