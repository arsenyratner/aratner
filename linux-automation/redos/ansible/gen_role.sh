#!/bin/bash

if [ $# -eq 0 ] 
then 
  echo "usage: gen_role.sh rolename playbook-file.xml"
  exit 0
fi

cd "$(dirname "$0")"
SCRIPT_DIR="$(pwd)"

rolename=$1
playbook=$2

if [ ! -d roles/$rolename ]
then 
  ansible-galaxy role init $rolename
  cp -f $playbook $rolename/tasks/main.yml
  mv $rolename roles/
else
  echo $SCRIPT_DIR
  echo $SCRIPT_DIR/role/$rolename exist alredy
fi
