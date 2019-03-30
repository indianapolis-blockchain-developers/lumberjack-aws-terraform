resource "aws_key_pair" "bastion_key" {
    key_name   = "bastion_key.pem"
    public_key = "${var.bastion_public_key}"
}

resource tls_private_key "node-key" {
  algorithm = "RSA"
}

resource "aws_key_pair" "rke-node-key" {
  key_name   = "rke-node-key"
  public_key = "${tls_private_key.node-key.public_key_openssh}"
}

/* resource "local_file" "k8s-private-key" {
    content = "${tls_private_key.node-key.private_key_pem}"
    filename = "~/.ssh/rke_private.pem"
} */