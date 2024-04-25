# Provision an EKS cluster

AWS's Elastic Kubernetes Service (EKS) is a managed service that lets you deploy, manage, and scale containerized applications on Kubernetes.
In this project, you will deploy an EKS cluster using Terraform.

## Prerequisites

To achive the goal of this project you will need some tools installed in your machine:

- Terraform v1.3+ installed locally.
- An [AWS account](https://portal.aws.amazon.com/billing/signup?nc2=h_ct&src=default&redirect_url=https%3A%2F%2Faws.amazon.com%2Fregistration-confirmation#/start).
- the AWS CLI v2.7.0/v1.24.0 or newer, [installed](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) and [configured](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html)
- [kubectl](https://kubernetes.io/docs/tasks/tools/) v1.24.0 or newer


## Set up and initialize your Terraform workspace

```
$ git clone https://gitlab.com/czaloumis/terraform-deploy.git
$ cd terraform-deploy
```

This project contains configuration to provision a VPC, security groups, and an EKS cluster with the following architecture:

![alt text](https://developer.hashicorp.com/_next/image?url=https%3A%2F%2Fcontent.hashicorp.com%2Fapi%2Fassets%3Fproduct%3Dtutorials%26version%3Dmain%26asset%3Dpublic%252Fimg%252Fterraform%252Feks%252Foverview.png%26width%3D1522%26height%3D1054&w=1920&q=75)

## Initialize configuration

Open variables.tf and set the AWS region you want to deploy the resources.

Then Initialize this configuration.

```
$ terraform init
```

## Provision the EKS cluster

Run the following command to create your cluster and other necessary resources. Confirm the operation with yes.

This proccess can take up to 15 minutes.

```
$ terraform apply
```

## Configure kubectl

Run the following command to retrieve the access credentials for your cluster and configure kubectl.

```
$ aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_name)
```

## Verify the Cluster

Use kubectl commands to verify your cluster configuration.
Verify that all three worker nodes are part of the cluster.

```
$ kubectl get nodes
```

You have verified that you can connect to your cluster using kubectl and that all three worker nodes are healthy. Your cluster is ready to use.

## Clean up your workspace

Destroy the resources you created with this project to avoid incurring extra charges. Respond yes to the prompt to confirm the operation.

```
$ terraform destroy
```