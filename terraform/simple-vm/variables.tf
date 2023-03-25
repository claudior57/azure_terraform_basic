variable enviroment {
  default = "staging"
}

variable username {
  default = "admin-staging"
}

variable ssh_public_key {
  default = "../../id_rsa_iaclab.pub"
}

variable tags {
  type = map
  default = {
    Team        = "DevOps"
    Environment = "Staging"
    CreatedBy   = "Terraform"
  }
}
