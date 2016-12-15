#!/bin/sh

set -e

# Set script variables
ENV=$1
FE=$2
FECOUNT=$3
FESIZE=$4
BE=$5
BECOUNT=$6
BESIZE=$7

usage() {
  if [ -z "${ENV}" ] || [ -z "${FE}" ] || [ -z "${FECOUNT}" ] || [ -z "${FESIZE}" ] [ -z "${BE}" ] || [ -z "${BECOUNT}" ] || [ -z "${BESIZE}" ]; then
    echo """
      $1 - $2 - $3 - $4 - $5 - $6 - $7 - $# - $@
      To run this script you to need to supply 7 arguments:
      $0 <environment><FE> <num_servers> <server_size><BE> <num_servers> <server_size>
    """
    exit 1
  else
    echo "arguments are set ...."
  fi
  if [ -z "${AWS_SECRET_ACCESS_KEY}" ] || [ -z "${AWS_ACCESS_KEY_ID}" ]; then
    echo """
      Please make sure you've set your AWS credentials i.e:
      export AWS_ACCESS_KEY_ID=xxxx
      export AWS_SECRET_ACCESS_KEY=yyyy
    """
    exit 1
  else
    echo "AWS stuff are set ...."
  fi

}

main() {
  usage
  runTerraform
}

runTerraform() {
  export PATH=$PATH:/opt/terraform
  cd ./terraform-aws
  terraform get
  terraform apply \
  -var "application_FE=${FE:-fe}" \
  -var "application_BE=${BE:-be}" \
  -var "environment=${ENV:-dev}" \
  -var 'fecount="'${FECOUNT:-1}'"' \
  -var 'becount="'${BECOUNT:-1}'"' \
  -var "beinstance_type=${BESIZE:-t2.nano}" \
  -var "feinstance_type=${FESIZE:-t2.nano}"
  if [ $? -eq 0 ]; then
    echo "Waiting for AWS resources ...."
    sleep 85
    cd ..
    sh hosts_file_gen.sh >./ansible/hosts
    cd ./terraform-aws
    elb_be=`terraform output elb_dns_name_BE`
    cd ..
    sed -i "s/backendlb/$elb_be/g" nginx/proxy.conf
    cd ./ansible
    
    ansible-playbook -i hosts -l webserver playbook_fe.yml 
    ansible-playbook -i hosts -l appserver playbook_be.yml
    cd ..
    cd ./terraform-aws
    echo "Please access your application at ---->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    terraform output elb_dns_name_FE
    cd ..
    sed -i "s/$elb_be/backendlb/g" nginx/proxy.conf
  else
    echo "Terraform didn't complete successfully!"
    exit 1
  fi
}

main
