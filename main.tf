#Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.cluster_name}-vnet"
  location            = var.location
  address_space       = var.address_spaces
  resource_group_name = azurerm_resource_group.rg.name
}
#Subnetwork
resource "azurerm_subnet" "subnet" {
  name                 = "${var.cluster_name}-subnet"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.rg.name
  address_prefixes     = [var.subnet_prefix]
}
#Network Security Group
resource "azurerm_network_security_group" "vmr_sg" {
  name                = "${var.cluster_name}-sg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "${var.cluster_name}-ssh"
    description                = "Allow inbound SSH from all locations"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "${var.cluster_name}-cli"
    description                = "Allow inbound solacecli from all locations"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "2222"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "${var.cluster_name}-webui"
    description                = "Allow inbound Web UI from all locations"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "${var.cluster_name}-smf"
    description                = "Allow inbound SMF from all locations"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "55555"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "${var.cluster_name}-ws"
    description                = "Allow inbound Web Socket from all locations"
    priority                   = 140
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8008"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
#Public IP
resource "azurerm_public_ip" "vmr_pip" {
  count               = var.vmr_ha ? 3 : 1
  name                = "${var.vmr_name}-pip-${count.index}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  domain_name_label   = "${var.cluster_name}-${var.vmr_name}-${count.index}"
}
#Network Interface
resource "azurerm_network_interface" "vmr_nic" {
  count               = var.vmr_ha ? 3 : 1
  name                = "${var.vmr_name}-nic-${count.index}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "${var.vmr_name}-ipcfg-${count.index}"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = element(azurerm_public_ip.vmr_pip.*.id, count.index)
  }
}
#Network Interface Security Group Asociation
resource "azurerm_network_interface_security_group_association" "vmr_nic_sg" {
  count = var.vmr_ha ? 3 : 1
  network_interface_id = element(azurerm_network_interface.vmr_nic.*.id, count.index)
  network_security_group_id = azurerm_network_security_group.vmr_sg.id
}
#Storage
resource "azurerm_managed_disk" "vmr_datadisk" {
  count                = var.vmr_ha ? 3 : 1
  name                 = "${var.vmr_name}-datadisk-${count.index}"
  location             = var.location
  resource_group_name  = azurerm_resource_group.rg.name
  storage_account_type = "${var.storage_account_tier}_${var.storage_replication_type}"
  create_option        = "Empty"
  disk_size_gb         = var.vmr_data_size + 1
}
#Private Key
resource "tls_private_key" "azkey" {
  algorithm = "RSA"

  provisioner "local-exec" {
    command = "cat > ${var.ssh_key_name}.pem <<EOL\n${tls_private_key.azkey.private_key_pem}\nEOL"
  }

  provisioner "local-exec" {
    command = "chmod 600 ${var.ssh_key_name}.pem"
  }
}
#Script Template
data "template_file" "cloud_init" {
  template = file("${path.module}/scripts/cloudInit.tpl")

  vars = {
    device_name = var.storage_device
    disk_size = var.vmr_data_size
  }
}
#Virtual Machines
resource "azurerm_virtual_machine" "vmr" {
  count                 = var.vmr_ha ? 3 : 1
  name                  = "${var.vmr_name}-${count.index}"
  location              = var.location
  resource_group_name   = azurerm_resource_group.rg.name
  vm_size               = var.vmr_vm_size
  network_interface_ids = [element(azurerm_network_interface.vmr_nic.*.id, count.index)]

  storage_image_reference {
    publisher = var.os_image["publisher"]
    offer     = var.os_image["offer"]
    sku       = var.os_image["sku"]
    version   = var.os_image["version"]
  }

  storage_os_disk {
    name              = "${var.vmr_name}-osdisk-${count.index}"
    managed_disk_type = "${var.storage_account_tier}_${var.storage_replication_type}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
  }

  storage_data_disk {
    name              = "${var.vmr_name}-datadisk-${count.index}"
    managed_disk_id   = element(azurerm_managed_disk.vmr_datadisk.*.id,count.index)
    managed_disk_type = "${var.storage_account_tier}_${var.storage_replication_type}"
    disk_size_gb      = var.vmr_data_size + 1
    create_option     = "Attach"
    lun               = 0
  }

  os_profile {
    computer_name  = "${var.vmr_name}-${count.index}"
    admin_username = "${var.admin_username}"
    #admin_password = "${var.admin_password}"
    custom_data    = "${data.template_file.cloud_init.rendered}"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/${var.admin_username}/.ssh/authorized_keys"
      key_data = "${tls_private_key.azkey.public_key_openssh}"
    }    
  }
}

module "vmr_install" {
  depends_on = [
    azurerm_virtual_machine.vmr
  ]
  source = "./module"
  vmr_ips = "${azurerm_public_ip.vmr_pip.*.ip_address}"
  vmr_ha = var.vmr_ha
  vmr_name = var.vmr_name
  vmr_user = var.vmr_user
  vmr_password = var.vmr_password
  ssh_user = var.admin_username
  ssh_key  = tls_private_key.azkey.private_key_pem
}