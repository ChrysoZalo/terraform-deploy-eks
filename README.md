# Provision an EKS cluster

AWS's Elastic Kubernetes Service (EKS) is a managed service that lets you deploy, manage, and scale containerized applications on Kubernetes.
In this project, you will deploy an EKS cluster using Terraform.

## Prerequisites

To achive the goal of this project you will need some tools installed in your machine:

- Terraform v1.3+ installed locally.
- An [AWS account](https://portal.aws.amazon.com/billing/signup?nc2=h_ct&src=default&redirect_url=https%3A%2F%2Faws.amazon.com%2Fregistration-confirmation#/start).
- the AWS CLI v2.7.0/v1.24.0 or newer, [installed](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) and [configured](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html)
- [kubectl](https://kubernetes.io/docs/tasks/tools/) v1.24.0 or newer
- [helm](https://helm.sh/docs/intro/install/) v3.14.4 or newer

## Set up and initialize your Terraform workspace

```
$ git clone https://gitlab.com/czaloumis/terraform-deploy.git
$ cd terraform-deploy
```

## EKS Cluster Architecture

This project contains configuration to provision a VPC, security groups, and an EKS cluster with the following architecture:

![alt text](https://developer.hashicorp.com/_next/image?url=https%3A%2F%2Fcontent.hashicorp.com%2Fapi%2Fassets%3Fproduct%3Dtutorials%26version%3Dmain%26asset%3Dpublic%252Fimg%252Fterraform%252Feks%252Foverview.png%26width%3D1522%26height%3D1054&w=1920&q=75)

The configuration defines a new VPC in which to provision the cluster, and uses the public EKS module to create the required resources, including Auto Scaling Groups, security groups, and IAM Roles and Policies.

Additionally the project also deploy into the cluster an AWS Application Load Balancer Controller. The AWS EKS implements the ingress to the cluster with an AWS ALBC which is watching for new ingress events and provisioning an Application Load Balancer with the expected ALB listener, Target groups and Traffic rules.

![alt text](https://miro.medium.com/v2/resize:fit:828/format:webp/0*KC-67M9vH94TJ1Zt.png)

If there is no need for the Application Load Balancer Controller then you can just remove the code under the comment (## code to make rule, policy and deploy the Application Load Balancer Controller) inside the main.tf.

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


## Optional: Deploy an example app

Now that is everything up and running you can deploy an example application.
In ./exampleApp/example.yaml is configuration to deploy an echo server with a service and an Application Load Balancer ingress(If you do not have deployed the ALPC you can remove the ingress resource).

Go to exampleApp folder and deploy the yaml file.
```
cd exampleApp
kubectl apply -f example.yaml
```

Check that all resources deployed successfully.
```
kubectl get all --namespace 1-example
NAME                              READY   STATUS    RESTARTS   AGE
pod/echoserver-6c456d4fcc-8zbqr   1/1     Running   0          37s

NAME                 TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
service/echoserver   NodePort   172.20.73.235   <none>        80:32180/TCP   38s

NAME                         READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/echoserver   1/1     1            1           38s

NAME                                    DESIRED   CURRENT   READY   AGE
replicaset.apps/echoserver-6c456d4fcc   1         1         1       39s

```

Now check if the Application Load Balancer is active from AWS Console 
```
kubectl get ingress/echoserver -n 1-example
NAME         CLASS   HOSTS  ADDRESS                                                                     PORTS   AGE
echoserver   alb     *       k8s-1example-echoserv-180350ba9c-19374850.eu-central-1.elb.amazonaws.com   80      8m26s
```

Copy the address and paste it in browser.(http://ADDRESS) and you should see something like this:
```
Hostname: echoserver-6c456d4fcc-8zbqr

Pod Information:
	-no pod information available-

Server values:
	server_version=nginx: 1.14.2 - lua: 10015

Request Information:
	client_address=10.0.2.4
	method=GET
	real path=/
	query=
	request_version=1.1
	request_scheme=http
	request_uri=http://k8s-1example-echoserv-180350ba9c-19374850.eu-central-1.elb.amazonaws.com:8080/

Request Headers:
	accept=text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7
	accept-encoding=gzip, deflate
	accept-language=en-US,en;q=0.9
	host=k8s-1example-echoserv-180350ba9c-19374850.eu-central-1.elb.amazonaws.com
	upgrade-insecure-requests=1
	user-agent=Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36
	x-amzn-trace-id=Root=1-662bb31d-19650a536b2af1073370bb80
	x-forwarded-for=185.32.231.117
	x-forwarded-port=80
	x-forwarded-proto=http

Request Body:
	-no body in request-
```



## Clean up your workspace

Destroy the resources you created with this project to avoid incurring extra charges. Respond yes to the prompt to confirm the operation.

```
$ terraform destroy
```