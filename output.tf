output "vmr-ips" {
  description = "Public IP address of VMR"
  value       = [azurerm_public_ip.vmr_pip.*.ip_address]
}