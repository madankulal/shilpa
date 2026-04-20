provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "simple-rg"
  location = "East US"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "simple-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "simple-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "pip" {
  name                = "simple-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "nic" {
  name                = "simple-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "simple-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B1s"
  admin_username      = "azureuser"

  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCUgvafAL7xrKO/mukwGg4GGk1A73bgMJhJjbkGRNzWxGENmuujgjDo3+x4R7XzVTqfx9bkxpZEsck+nU9NUHwp427kYF/jq6bnpP2QzpqEeGZM1xI6JU6X3tTEgSDL1DSnpXXck9GMu90IXDpy71TRsMZqxGYs6Y4ZcHcI0nnfFDRbPHWCKonPcxw2YbsL4tjjYmKnEWiMpZaAK8HrWH5JDv6onl+ZS/AHvSyQOGlbM0wbyUN+GvX34/nwb/BahjYtvJUwB0sPFgfnxRrcwM4199uS3IMzJhk3PW2BaQso1QzNf58HBJx048ZnERvxiLLSer9tiUXZLSR6aWihvvMl azureuser@testvm"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}
