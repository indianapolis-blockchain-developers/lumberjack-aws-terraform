module "nodes" {
  source = "./aws"

  # region        = "us-east-1"
  # instance_type = "t2.micro"
  # cluster_id    = "rke"
}

resource rke_cluster "cluster" {
  # Disable port check validation between nodes
  disable_port_check = true

  ###############################################
  # Kubernetes nodes
  ###############################################
  cloud_provider {
    name = "aws"
  }

#########################################################
# Network(CNI) - supported: flannel/calico/canal/weave
#########################################################
# There are several network plug-ins that work, but we default to canal
  network {
    plugin = "flannel"
}

  nodes = [
    {
      address = "${module.nodes.addresses[0]}"
      user    = "${module.nodes.ssh_username}"
      ssh_key = "${module.nodes.private_key}"
      role    = ["controlplane", "etcd"]
    },
    {
      address = "${module.nodes.addresses[1]}"
      user    = "${module.nodes.ssh_username}"
      ssh_key = "${module.nodes.private_key}"
      role    = ["worker"]
    },
    {
      address = "${module.nodes.addresses[2]}"
      user    = "${module.nodes.ssh_username}"
      ssh_key = "${module.nodes.private_key}"
      role    = ["worker"]
    },
    {
      address = "${module.nodes.addresses[3]}"
      user    = "${module.nodes.ssh_username}"
      ssh_key = "${module.nodes.private_key}"
      role    = ["worker"]
    },
  ]

  # If set to true, RKE will not fail when unsupported Docker version are found
  ignore_docker_version = false

  ###############################################
  # Bastion/Jump host configuration
  ###############################################
  bastion_host = {
    address      = "${module.nodes.bastion_public_ip}"
    user         = "centos"
    ssh_key_path = "~/.ssh/bastion_key.pem"
    #or
    #ssh_key      = "${file("~/.ssh/bastion_key.pem")}"
    port         = 22
  }

}







resource "local_file" "kube_cluster_yaml" {
  filename = "./kube_config_cluster.yml"
  content  = "${rke_cluster.cluster.kube_config_yaml}"
}