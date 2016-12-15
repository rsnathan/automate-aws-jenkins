variable environment {
  type="string",
  default="dev"
}

variable name {
  type="string",
  default="rahul"
}

variable application_FE {
  type="string",
  default="fe"
}

variable application_BE {
  type="string",
  default="be"
}
variable fecount {
  type="string",
  default="1"
}
variable becount {
  type="string",
  default="1"
}

variable ami_id {
  type="string",
  default="ami-ed82e39e"
}

variable feinstance_type {
  type="string",
  default="t2.nano"
}

variable beinstance_type {
  type="string",
  default="t2.nano"
}

variable public_key_path {
 default = "/home/rahul/.ssh/terraform.pub"
}

variable key_name {
  default = "terraform"
}
variable instance_port_BE {
  default = "8080"
}
variable instance_port_FE {
  default = "80"
}

