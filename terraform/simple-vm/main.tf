# Create simple-vm host VM.

resource "azurerm_public_ip" "simple-vm-ip" {
  name                = "${var.enviroment}-ip"
  location            = data.terraform_remote_state.rg.outputs.rg_location
  resource_group_name = data.terraform_remote_state.rg.outputs.rg_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_network_interface" "simple-vm-nic" {
  name                = "${var.enviroment}-simple-vm-nic"
  location            = data.terraform_remote_state.rg.outputs.rg_location
  resource_group_name = data.terraform_remote_state.rg.outputs.rg_name

  ip_configuration {
    name                          = "simple-configuration1"
    subnet_id                     = data.terraform_remote_state.vnet.outputs.public_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.simple-vm-ip.id
  }
}

resource "azurerm_virtual_machine" "simple-vm" {
  name                  = "${var.enviroment}-simple-vm-01"
  location              = data.terraform_remote_state.rg.outputs.rg_location
  resource_group_name   = data.terraform_remote_state.rg.outputs.rg_name
  network_interface_ids = [azurerm_network_interface.simple-vm-nic.id]
  vm_size               = "Standard_DS1_v2"

  delete_os_disk_on_termination = true

  storage_os_disk {
    name              = "${var.enviroment}-simple-vm-dsk001"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_profile {
    computer_name  = "${var.enviroment}-simplevm-01"
    admin_username = var.username
    custom_data    = file("${path.module}/files/nginx.yml")
  }

  os_profile_linux_config {
    disable_password_authentication = true
    # Simple VM public key.
    ssh_keys {
      path     = "/home/${var.username}/.ssh/authorized_keys"
      key_data = file(var.ssh_public_key)
    }
  }

  tags = var.tags
}

resource "azurerm_virtual_machine_extension" "simple-vm-ad" {
  name                 = "simple-vm-AADLoginForLinux"
  virtual_machine_id   = azurerm_virtual_machine.simple-vm.id
  publisher            = "Microsoft.Azure.ActiveDirectory.LinuxSSH"
  type                 = "AADLoginForLinux"
  type_handler_version = "1.0"

  tags = var.tags
}

resource "azurerm_virtual_machine_extension" "simple-vm-initial-config" {
  name                 = "simple-vm-initial-config"
  virtual_machine_id   = azurerm_virtual_machine.simple-vm.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.1"
  // this script is the base64 from the files/simple-vm_01.sh, and was generated using the command 'cat files/simple-vm_01.sh| base64 -w0 >script'
  // we gonna need to modify it later on
  settings = <<SETTINGS
    {
        "script": "eSMhL2Jpbi9zaAoKZWNobyAiTW9kaWZ5aW5nIHRoZSBTdWRvZXJzIGZpbGUiCgpzdWRvIGFwdCB1cGRhdGUKc3VkbyBhcHQgaW5zdGFsbCBuZ2lueCAteQoKIyMjIyMjIyMjIyMjIyMjIyMjIyMjIwojIFNUQVRJQyBXRUIgUEFHRQojIyMjIyMjIyMjIyMjIyMjIyMjIyMjCgpzdWRvIG1rZGlyIC92YXIvd3d3L2RlbW8gLXAKI3N1ZG8gY2htb2QgMDc1NSAgL2V0Yy9uZ2lueC93d3cvZGVtbwpzdWRvIHRlZSAtYSAvdmFyL3d3dy9kZW1vL2luZGV4Lmh0bWwgPiAvZGV2L251bGwgPDwnRU9GJwo8IWRvY3R5cGUgaHRtbD4KPGh0bWw+CjxoZWFkPgogICAgPG1ldGEgY2hhcnNldD0idXRmLTgiPgogICAgPHRpdGxlPkhlbGxvLCBOZ2lueCE8L3RpdGxlPgo8L2hlYWQ+Cjxib2R5PgogICAgPGgxPkhlbGxvLCBOZ2lueCE8L2gxPgogICAgPHA+CiAgICAgIFRoaXMgd2VicGFnZSBpcyBwYXJ0IG9mIGEgbGFiIGFuZCBpcyBzZXJ2ZWQgdGhyb3VnaCBOZ2lueCB3ZWIgc2VydmVyIG9uIFVidW50dSBTZXJ2ZXIhCiAgICA8L3A+CjwvYm9keT4KPC9odG1sPgpFT0YKI2NobW9kIDA3NTUgIC9ldGMvbmdpbngvd3d3CiNjaG1vZCA2NDQgL2V0Yy9uZ2lueC93d3cvZGVtby9pbmRleC5odG1sCmVjaG8gImluZGV4IHdlYnBhZ2UgY3JlYXRlZCAiICA+PiAvdG1wL2RlYnVnLmxvZwoKbWtkaXIgL2V0Yy9uZ2lueC9zaXRlcy1lbmFibGVkIC1wCnN1ZG8gcm0gL2V0Yy9uZ2lueC9zaXRlcy1lbmFibGVkL2RlZmF1bHQKc3VkbyB0ZWUgLWEgL2V0Yy9uZ2lueC9zaXRlcy1lbmFibGVkL2RlbW8gPiAvZGV2L251bGwgPDwnRU9GJwpzZXJ2ZXIgewogICAgICAgbGlzdGVuIDgwOwogICAgICAgbGlzdGVuIFs6Ol06ODA7CgogICAgICAgc2VydmVyX25hbWUgZXhhbXBsZS51YnVudHUuY29tOwoKICAgICAgIHJvb3QgL3Zhci93d3cvZGVtbzsKICAgICAgIGluZGV4IGluZGV4Lmh0bWw7CgogICAgICAgbG9jYXRpb24gLyB7CiAgICAgICAgICAgICAgIHRyeV9maWxlcyAkdXJpICR1cmkvID00MDQ7CiAgICAgICB9Cn0KRU9GCgpzdWRvIHNlcnZpY2UgbmdpbnggcmVzdGFydAoKc3VkbyBybSAvZXRjL3N1ZG9lcnMuZC9hYWRfYWRtaW5zCmVjaG8gJyVhYWRfYWRtaW5zIEFMTD0oQUxMKSBOT1BBU1NXRDpBTEwnID4gL2V0Yy9zdWRvZXJzLmQvYWFkX2FkbWlucwoK"
    }
SETTINGS
  tags     = var.tags
}