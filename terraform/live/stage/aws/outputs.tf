output "bastion_public_ip" {
  value = "${aws_instance.bastion.public_ip}"
}

output "ssh_username" {
  value = "centos"
}

output "private_key" {
  value = "${tls_private_key.node-key.private_key_pem}"
}

output "addresses" {
  value = ["${aws_instance.rke-node.*.private_ip}"]
  description = "The Private IP addresses of the RKE nodes"
}
