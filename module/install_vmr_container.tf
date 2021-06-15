data "template_file" "compose_file" {
  count = length(var.vmr_ips)
  template = file("${path.module}/scripts/docker-compose.yaml.tpl")

  vars = {
    container_name = "${var.vmr_name}-${count.index}"
    vmr_user = var.vmr_user
    vmr_password = var.vmr_password
    max_connection = 100
  }
}
resource "null_resource" "install_vmr" {
  count = length(var.vmr_ips)

  connection {
    host                = element(var.vmr_ips, count.index)
    user                = var.ssh_user
    private_key         = var.ssh_key
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /home/${var.ssh_user}/solace"
    ]
  }
  provisioner "file" {
    content = element(data.template_file.compose_file.*.rendered, count.index)
    destination = "/home/${var.ssh_user}/solace/docker-compose.yaml"
  }
  provisioner "file" {
    source = "${path.module}/scripts/install_docker.sh"
    destination = "/home/${var.ssh_user}/install_docker.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod a+x /home/${var.ssh_user}/install_docker.sh",
      "sudo /home/${var.ssh_user}/install_docker.sh",
      "sudo usermod -a -G docker ${var.ssh_user}",
      "sudo docker-compose -f /home/${var.ssh_user}/solace/docker-compose.yaml up -d",
      "sudo docker ps"
    ]
  }

}