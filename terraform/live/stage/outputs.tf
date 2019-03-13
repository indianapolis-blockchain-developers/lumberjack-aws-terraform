output "bastion_public_ip" {
  value = "${aws_instance.bastion.public_ip}"
}

output "ssh_username" {
  value = "centos"
}

output "rke_private_key" {
  value = "${tls_private_key.node-key.private_key_pem}"
}
