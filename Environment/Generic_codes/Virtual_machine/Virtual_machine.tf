

resource "azurerm_resource_group" "rg_aman1" {
  name     = "test.rg.eu.02"
  location = "West Europe"
}

resource "azurerm_virtual_network" "vm" {
  name                = "test.rg.eu.02-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg_aman1.location
  resource_group_name = azurerm_resource_group.rg_aman1.name
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.rg_aman1.name
  virtual_network_name = azurerm_virtual_network.vm.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "vm_public_ip" {
  name                = "main-public-ip"
  location            = azurerm_resource_group.rg_aman1.location
  resource_group_name = azurerm_resource_group.rg_aman1.name
  allocation_method   = "Static"

  sku = "Standard"

     
}

resource "azurerm_network_interface" "main" {
  name                = "test.rg.eu.02-nic"
  location            = azurerm_resource_group.rg_aman1.location
  resource_group_name = azurerm_resource_group.rg_aman1.name



  ip_configuration {
    name                          = "test.rg.eu.02configuration1"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
     public_ip_address_id  = azurerm_public_ip.vm_public_ip.id
  }
}

resource "azurerm_virtual_machine" "main" {
  name                  = "test.rg.eu.02-vm"
  location              = azurerm_resource_group.rg_aman1.location
  resource_group_name   = azurerm_resource_group.rg_aman1.name
  network_interface_ids = [azurerm_network_interface.main.id]
  vm_size               = "Standard_B1s"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "testing"
  }
}