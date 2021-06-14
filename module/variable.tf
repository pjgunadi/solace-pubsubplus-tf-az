variable "vmr_ips" {
    type = list(string)
}
variable "vmr_ha" {
    type = bool
}
variable "vmr_name" {
    type = string
}
variable "vmr_user" {
    type= string
}
variable "vmr_password" {
    type = string
}
variable "ssh_user" {
    type = string
}
variable "ssh_key" {
    type = string
}