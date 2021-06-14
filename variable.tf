variable "resource_group" {
  description = "Azure Resource Group"
  type        = string
  default     = "default"
}
variable "location" {
  description = "Azure Location"
  type        = string
  default     = "southeastasia"
}
variable "cluster_name" {
  description = "Cluster Name"
  type        = string
  default     = "vmr-cluster"
}
variable "address_spaces" {
  description = "The address space that is used by the virtual network. You can supply more than one address space. Changing this forces a new resource to be created."
  type = list(string)
  default     = ["192.168.1.0/24"]
}
variable "subnet_prefix" {
  description = "The address prefix to use for the subnet."
  default     = "192.168.1.0/24"
}
variable "storage_account_tier" {
  description = "Defines the Tier of storage account to be created. Valid options are Standard and Premium."
  default     = "Standard"
}
variable "storage_replication_type" {
  description = "Defines the Replication Type to use for this storage account. Valid options include LRS, GRS etc."
  default     = "LRS"
}
variable "ssh_key_name" {
  default = "az-vmr"
}
# variable ssh_public_key {
#     description = "SSH Public Key"
#     default = ""
# }
variable "os_image" {
  description = "os image map"
  type        = map(string)

  default = {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}
variable "admin_username" {
  description = "administrator user name"
  default     = "sysadmin"
}
/*
variable "admin_password" {
  description = "administrator password (recommended to disable password auth)"
  default = ""
}
*/
##### vmr Configurations ######
variable "vmr_ha" {
  description = "VMR with HA"
  type        = bool
  default     = false
}
variable "vmr_name" {
  description = "VM Name"
  type        = string
  default     = "solace1"
}
variable "vmr_vm_size" {
  description = "Azure VM Size"
  type        = string
  default     = "Standard_B2s"
}
variable "vmr_data_size" {
  description = "VMR Data Storage Size"
  type        = number
  default     = 30
}
variable "storage_device" {
  description = "Storage Device Name"
  type        = string
  default = "nvme1n1"
}
variable "vmr_user" {
  description = "VMR Admin user"
  type        = string
  default     = "admin"
}
variable "vmr_password" {
  description = "VMR Admin password"
  type        = string
}

