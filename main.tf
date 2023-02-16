resource "azurerm_resource_group" "rg" {
  name     = "hmp-cassucena-Terraform-RG"
  location = var.location

  tags = local.common_tags
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-01"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "sub-01" {
  name                 = "sun-01"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "nsg" {
  name                = "nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}

resource "azurerm_subnet_network_security_group_association" "example" {
  subnet_id                 = azurerm_subnet.sub-01.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}




resource "azurerm_public_ip" "pip" {
  name                = "pip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "nic" {
  name                = "nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = azurerm_public_ip.pip.name
    subnet_id                     = azurerm_subnet.sub-01.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}


resource "azurerm_network_interface_security_group_association" "nic_association" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}


resource "azurerm_linux_virtual_machine" "vm" {
  name                = "vm-linux"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  size                = "Standard_F2"
  admin_username      = "cassucena"
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  admin_ssh_key {
    username   = "cassucena"
    public_key = var.azure_pub_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }


}

