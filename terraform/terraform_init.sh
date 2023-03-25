#!/bin/bash

FOLDERS=("rg" "nsg" "vnet" "simple-vm")

echo "----- Terraform init -----"

for folder in "${FOLDERS[@]}"
do
  echo "---------------------------"
  echo "Terraform init $folder"
  echo "---------------------------"
  cd ./$folder
  sudo rm -r .terraform
  terraform init
  cd ..
  echo " "
done