#!/bin/bash
cd terraform-aws/
echo "[appserver]"
terraform output publicIP_BE  | tr , '\n' 
echo "[appserver:vars]\nansible_ssh_user=ubuntu\nansible_sudo=yes"
echo "[webserver]"
terraform output publicIP_FE  | tr , '\n'
echo "[webserver:vars]\nansible_ssh_user=ubuntu\nansible_sudo=yes"

