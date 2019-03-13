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

* Two subnets, one public and one private (Completed)
* Single EC2 instance as bastion host in public subnet (Completed)
* Single EC2 instance as master node in private subnet (In-progress)
* The master node is an auto-recoving EC2 instance (Not Started)
* Three EC2 instances as K8s nodes in private subnet (In-progress)
* 1-10 EC2 instances available for K8s node Auto Scaling group (Not Started)
* Single ELB Load Balancer for HTTPS Kubernetes API access (In-progress)
* kubeadm for bootstraping K8s on Linux (Not Started)
* Docker for container runtime (completed)
* Calico for pod networking (Not Started)
* CoreDNS for cluster DNS (Not Started)
* Port 22 SSH access to bastion host (Completed)
* Port 6443 for HTTPS access for K8s API (Not Started)
* CentOS 7 for EC2 instances (Completed)
