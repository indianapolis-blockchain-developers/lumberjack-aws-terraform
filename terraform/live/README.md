# Lumberjack K8s AWS Cluster

## Description

Creates an Kubernetes (K8s) Cluster in Amazon Virtual Private Cloud (VPC) in a single availablilty zone.


## Networking

|      VPC CIDR      | 10.0.0.0/16   |
|:------------------:|---------------|
| Public subnet      | 10.0.128.0/20 |
| Private subnet     | 10.0.0.0/19   |
| Linux bastion host | 10.0.128.5    |

## Details

* Two subnets, one public and one private
* Single EC2 instance as bastion host in public subnet
* Single EC2 instance as master node in private subnet
* The master node is an auto-recoving EC2 instance
* Two EC2 instances as K8s nodes in private subnet
* 1-10 EC2 instances available for K8s node Auto Scaling group
* Single ELB Load Balancer for HTTPS Kubernetes API access
* kubeadm for bootstraping K8s on Linux
* Docker for container runtime
* Calico for pod networking
* CoreDNS for cluster DNS
* Port 22 SSH access to bastion host
* Port 6443 for HTTPS access for K8s API
* CentOS 7 for EC2 instances