

resource "aws_instance" "bastion" {
    ami                                 = "${lookup(var.amis, var.aws_region)}"
    key_name                            = "${aws_key_pair.bastion_key.key_name}"
    instance_type                       = "${var.InstanceType}"
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
            "sudo yum -y update",
            "sudo yum -y install epel-release",
            "sudo yum -y install ansible",
            "sudo yum -y install python-boto",
            "sudo yum -y install vim",
            "sudo yum -y install git",
            "git init",
            "git clone https://github.com/injectedfusion/lumberjack-ansible",
            "chmod +x /home/centos/lumberjack-ansible/module_utils/ec2.py",
            "cd /etc/ansible/roles",
            "sudo git clone https://github.com/geerlingguy/ansible-role-docker",
            "sudo mv -f /home/centos/lumberjack-ansible/ansible.cfg /etc/ansible/ansible.cfg",  
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
  ami                    = "${lookup(var.amis, var.aws_region)}"
  instance_type          = "${var.InstanceType}"
  key_name               = "${aws_key_pair.rke-node-key.id}"
  iam_instance_profile   = "${aws_iam_instance_profile.rke-aws.name}"
  vpc_security_group_ids = ["${aws_security_group.private_sg.id}"]
  subnet_id              = "${aws_subnet.private.id}"

  root_block_device {
      delete_on_termination = true
  }  
  tags {
      Name = "rke-${count.index}"
      role = "k8s-cluster"
    }


}

