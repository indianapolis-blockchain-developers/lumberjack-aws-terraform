resource "aws_instance" "bastion" {
    ami                                 = "${var.packer-ami}"
    key_name                            = "${aws_key_pair.bastion_key.key_name}"
    instance_type                       = "t3.micro"
    vpc_security_group_ids              = ["${aws_security_group.bastion-sg.id}"]
    private_ip                          = "10.0.128.5"
    associate_public_ip_address         = true
    subnet_id = "${aws_subnet.public.id}"
    root_block_device {
        delete_on_termination = true
    }
    tags {
        Name = "bastion"
    }

    provisioner "file" {
        content = "${tls_private_key.node-key.private_key_pem}"
        destination = "/home/centos/.ssh/rke_private.pem" 
    }
    
    provisioner "remote-exec" {
        inline = [
            "sudo chown centos /home/centos/.ssh/rke_private.pem",
            "sudo chmod 400 /home/centos/.ssh/rke_private.pem"   
        ]     
    }

        connection {
            type = "ssh"
            user = "centos"
            private_key = "${file("~/.ssh/bastion_key.pem")}"
        }

}

     
#     vpc_security_group_ids              = ["${aws_security_group.bastion-sg.id}"]
     
resource "aws_instance" "rke-node" {
  count = 4
  ami                    = "ami-02eac2c0129f6376b"
  instance_type          = "t2.small"
  key_name               = "${aws_key_pair.rke-node-key.id}"
  iam_instance_profile   = "${aws_iam_instance_profile.rke-aws.name}"
  vpc_security_group_ids = ["${aws_security_group.private_sg.id}"]
  subnet_id              = "${aws_subnet.private.id}"

  root_block_device {
      delete_on_termination = true
  }
  tags                       = "${
        map(
            "Name", "rke-${count.index}",
            "kubernetes.io/cluster/${var.cluster_id}", "owned",
            "role", "k8s-cluster"
        )
    }"
  provisioner "remote-exec" {
    connection {
            bastion_host        = "${aws_instance.bastion.public_ip}"
            bastion_user        = "centos"
            bastion_private_key = "${file("~/.ssh/bastion_key.pem")}"
            type                = "ssh"
            user                = "centos"
            private_key         = "${tls_private_key.node-key.private_key_pem}"
        }
    
    inline = [
      "sudo yum update -y openssh",
      "curl releases.rancher.com/install-docker/18.09.2.sh| bash",
      "sudo usermod -aG docker centos",
      "sudo systemctl start docker",
      "sudo systemctl status docker",
      "sudo systemctl enable docker"
    ]
  }
}


