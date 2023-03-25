output "simple_public_ip" {
  value = azurerm_public_ip.simple-vm-ip.ip_address
}

output "simple_vm_id" {
  value = azurerm_virtual_machine.simple-vm.id
}
