# azure_terraform_basic
demo - azure basic iac configs for a working cluster (should be used only for demonstration purposes NOT READY FOR PRODUCTION), use it at your own discretion

#First Steps:
- install python3 e AZ CLI and Terraform
  ```
    this have a different setup for each OS so suit yourself
  ``` 

- run AZ login and follow the instructions

  ```
    az login --use-device-code
  ```
### In order to run Terraform storing the states on the Azure storage container, you need to create a storage first, you can do it manually or running the steps bellow:

- export the name of the account that you want to use
  ```
    export COMPANY_NAME=acme   
    export RESOURCE_GROUP=devops-$COMPANY_NAME 
    export SERVICE_PRINCIPAL=devops-$COMPANY_NAME
  ```

- export the id of the desired Subscription

  ``` 
    export SUBSCRIPTION_ID=$(az account show | grep id |  cut -d'"' -f 4)
  ```

- create the DevOps resource group: on this example we are using the Region: eastus (East of USA)

  ```
    az group create -l eastus -n $RESOURCE_GROUP
  ```

- create the storage account for holding the terraform state. the Name you Choose for the storage account needs to be unique, and add the network rule for your ip

  ```
    export STORAGE_ACCOUNT=devops${COMPANY_NAME}stg2023
    az storage account create -n $STORAGE_ACCOUNT -l eastus -g $RESOURCE_GROUP --sku Standard_LRS
    az storage account network-rule add --resource-group $RESOURCE_GROUP --account-name $STORAGE_ACCOUNT --ip-address "$(curl http://ipv4.icanhazip.com --silent)
  ```

- export the STORAGE_KEY for the account that you have created:

  ```
    export STORAGE_KEY=$(az storage account keys list -g $RESOURCE_GROUP -n $STORAGE_ACCOUNT | grep value -m 1| cut -d'"' -f 4 )
  ```

- create the storage container on the account previously made:

  ``` 
    az storage container create -n tfstate --account-name $STORAGE_ACCOUNT --account-key $STORAGE_KEY 
  ```

- run generate the ssh-keys to use (use a real email that you own)
  ```
    ssh-keygen -f ./id_rsa_iaclab -C devops@iaclab.com
  ```
  


- On the ./terraform/rg directory, run the creation of the rg: 

  ```
    terraform init 
    terraform apply --auto-approve
  ```

- On the ./terraform/nsg directory, Run the creation of the nsg:

  ```
    terraform init
    terraform apply --auto-approve
  ```

- On the ./terraform/vnet directory, Run the creation of the vnet:

  ```
    terraform init
    terraform apply --auto-approve
  ```

- On the ./terraform/simple-vm directory, Run the creation of the vnet:

  ```
    terraform init
    terraform apply --auto-approve
  ```

- after running the commands you will be able to access the page from the nginx server on the browser, and do an ssh to it using the key generated on the root folder of this repo,(ec2 ip output example:34.239.139.80)
  ##### wget
  ```
  wget "http://34.239.139.80/"
  cat index.html
  ```  
  ##### ssh
  ```
  ssh admin-staging@34.239.139.80 -i ./id_rsa_iaclab
  ```

- if you want to test the sns notification alarm to your email you will need to confirm the email subscription on the sns topic

- When you finish with the demo please run the Terraform_destroy.sh, or destroy it individually using `terraform destroy` in each subfolder of the ./terraform and verify if the resources were destroyed properly
  ```
  cd terraform
  ./terraform_destroy.sh
  ```