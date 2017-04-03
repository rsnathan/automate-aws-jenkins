# Provider spcific
provider "aws" {
    region = "eu-west-1"
}

# Variables for VPC module
module "vpc_subnets" {
	source = "./modules/vpc_subnets"
	name = "${var.name}"
	environment = "${var.environment}"
	enable_dns_support = true
	enable_dns_hostnames = true
	vpc_cidr = "172.16.0.0/16"
        public_subnets_cidr = "172.16.10.0/24,172.16.20.0/24"
        private_subnets_cidr = "172.16.30.0/24,172.16.40.0/24"
        azs    = "eu-west-1a,eu-west-1b"
}

module "ssh_sg" {
	source = "./modules/ssh_sg"
	name = "${var.name}"
	environment = "${var.environment}"
	vpc_id = "${module.vpc_subnets.vpc_id}"
	source_cidr_block = "0.0.0.0/0"
}

module "app_sg" {
	source = "./modules/app_sg"
	name = "${var.name}"
	environment = "${var.environment}"
	vpc_id = "${module.vpc_subnets.vpc_id}"
	source_cidr_block = "0.0.0.0/0"
}

module "web_sg" {
        source = "./modules/web_sg"
        name = "${var.name}"
        environment = "${var.environment}"
        vpc_id = "${module.vpc_subnets.vpc_id}"
        source_cidr_block = "0.0.0.0/0"
}
module "elb_sg" {
	source = "./modules/elb_sg"
	name = "${var.name}"
	environment = "${var.environment}"
	vpc_id = "${module.vpc_subnets.vpc_id}"
}

module "ec2key" {
	source = "./modules/ec2key"
        key_name = "${var.key_name}"

}

module "elb_FE" {
	source = "./modules/elb"
	name = "${var.name}-${var.application_FE}"
	environment = "${var.environment}"
	security_groups = "${module.elb_sg.elb_sg_id},${module.web_sg.web_sg_id}"
	availability_zones = "eu-west-1a,eu-west-1b"
	subnets = "${module.vpc_subnets.public_subnets_id}"
        instances = "${module.ec2_FE.instances}"
        instance_port = "${var.instance_port_FE}"
}

module "elb_BE" {
	source = "./modules/elb"
	name = "${var.name}-${var.application_BE}"
	environment = "${var.environment}"
	security_groups = "${module.elb_sg.elb_sg_id},${module.app_sg.app_sg_id}"
	availability_zones = "eu-west-1a,eu-west-1b"
	subnets = "${module.vpc_subnets.public_subnets_id}"
        instances = "${module.ec2_BE.instances}"
        instance_port = "${var.instance_port_BE}"

}

module "ec2_FE" {
        source = "./modules/ec2"
        name = "${var.name}-${var.application_FE}"
        environment = "${var.environment}"
        security_groups = "${module.elb_sg.elb_sg_id},${module.app_sg.app_sg_id}"
        instance_type = "${var.feinstance_type}"
        key_name ="${module.ec2key.ec2key_name}"
        public_key_path="${var.public_key_path}"
        count ="${var.fecount}"
        ami_id = "${var.ami_id}"
        subnets = "${module.vpc_subnets.public_subnets_id}"


}
module "ec2_BE" {
        source = "./modules/ec2"
        name = "${var.name}-${var.application_BE}"
        environment = "${var.environment}"
        security_groups = "${module.elb_sg.elb_sg_id},${module.app_sg.app_sg_id}"
        instance_type = "${var.beinstance_type}"
        key_name ="${module.ec2key.ec2key_name}"
        public_key_path="${var.public_key_path}"
        count ="${var.becount}"
        ami_id = "${var.ami_id}"
        subnets = "${module.vpc_subnets.public_subnets_id}"


}
module "asg_FE" {
        source = "./modules/asg"
        name = "${var.name}-${var.application_FE}-asg"
        environment = "${var.environment}"
        ami_id = "${var.ami_id}"
        instance_type = "${var.feinstance_type}"
        security_groups = "${module.elb_sg.elb_sg_id},${module.web_sg.web_sg_id}"
        loadbalancers = "${module.elb_FE.elb.id}"


}

module "asg_BE" {
        source = "./modules/asg"
        name = "${var.name}-${var.application_BE}-asg"
        environment = "${var.environment}"
        ami_id = "${var.ami_id}"
        instance_type = "${var.beinstance_type}"
        security_groups = "${module.elb_sg.elb_sg_id},${module.app_sg.web_sg_id}"
        loadbalancers = "${module.elb_BE.elb.id}"


}

