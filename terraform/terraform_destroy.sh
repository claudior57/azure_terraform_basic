#!/bin/bash

FOLDERS_REVERSE=("simple-vm" "vnet" "nsg" "rg")

echo "----- Terraform Destroy -----"

for folder in "${FOLDERS_REVERSE[@]}"
do
  echo "---------------------------"
  echo "Terraform destroying module $folder"
  echo "---------------------------"
  cd ./$folder
  terraform destroy --auto-approve
  cd ..
  echo " "
done