# Infrastructure

![alt text](eks-infra.svg)


## Infrastructure Setup Guide for EKS and Related Services

This document outlines the steps to create and configure the infrastructure required for an EKS cluster, along with necessary services like VPC, Security Groups, RDS, ACM, ALB, ECR, and CDN. The steps also include admin activities related to Bastion Host and accessing the cluster and RDS.

## Infrastructure Setup Sequence

### 1. **VPC** (Required)
   - Create the VPC first as the foundation of your network.
  
### 2. **Security Groups and Rules** (Required)
   - Define all security groups and rules after creating the VPC.

### 3. **Bastion Host** (Required)
   - Create a Bastion Host to connect to RDS and EKS cluster.

### 4. **VPN** (Optional)
   - Configure VPN for direct access to RDS and EKS from a Windows laptop.

### 5. **EKS Cluster** (Required)
   - Create the EKS cluster to host your Kubernetes workloads.

### 6. **RDS** (Required)
   - Set up RDS, as databases are not created inside the Kubernetes cluster.

### 7. **ACM (AWS Certificate Manager)** (Required)
   - ACM is needed to obtain SSL certificates for the ALB Ingress controller.

### 8. **Ingress ALB** (Required)
   - Set up the ALB as the ingress controller to expose applications to the outside world.

### 9. **ECR** (Required)
   - Create an ECR repository to store your application images.

### 10. **CDN** (Optional)
   - Set up a CDN (Content Delivery Network), though it is optional, it is recommended for performance.

---

## Admin Activities

### **Bastion Host**
- **SSH into the Bastion Host**:
  - Once the Bastion Host is created, SSH into it to configure the credentials.

  ```bash
  aws configure
  ```

- **Get Kubernetes config**:
  - Update your kubeconfig to allow access to the EKS cluster.

  ```bash
  aws eks update-kubeconfig --region us-east-1 --name <YOUR-CLUSTER-NAME>
  ```

- **Verify connection to Kubernetes cluster**:
  - After configuring, verify the connection by listing the nodes in the cluster.

  ```bash
  kubectl get nodes
  ```

---

### **RDS**

- **Connect to RDS**:
  - Use the Bastion Host to connect to RDS using MySQL.

  ```bash
  mysql -h <DB-R53-ADDRESS> -u root -pExpenseApp1
  ```

- **Create Tables**:
  - When setting up RDS, the schema is created during the RDS creation process. However, the tables should be created manually. Refer to `backend.sql` for creating necessary tables.

  ```bash
  CREATE TABLE user (
    ...
  );
  FLUSH PRIVILEGES;
  ```

---

### **Ingress Controller**

For setting up the AWS Load Balancer Controller as an ingress controller for Kubernetes, follow these steps:

1. **Connect to the Kubernetes Cluster**:
   - Use the Bastion Host to connect to the Kubernetes cluster.

2. **Create an IAM OIDC provider** (if not already created):
   - This step associates the OIDC provider for the cluster.

   ```bash
   eksctl utils associate-iam-oidc-provider --region us-east-1 --cluster <your-cluster-name> --approve
   ```

3. **Download the IAM policy**:
   - Download the IAM policy for the AWS Load Balancer Controller.

   ```bash
   curl -o iam-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.8.1/docs/install/iam_policy.json
   ```

4. **Create IAM Policy**:
   - Create the IAM policy using the downloaded file.

   ```bash
   aws iam create-policy --policy-name AWSLoadBalancerControllerIAMPolicy --policy-document file://iam-policy.json
   ```

5. **Create IAM Role and ServiceAccount for the Load Balancer Controller**:
   - Use `eksctl` to create an IAM service account for the AWS Load Balancer controller.

   ```bash
   eksctl create iamserviceaccount    --cluster=<cluster-name>    --namespace=kube-system    --name=aws-load-balancer-controller    --attach-policy-arn=arn:aws:iam::<AWS_ACCOUNT_ID>:policy/AWSLoadBalancerControllerIAMPolicy    --override-existing-serviceaccounts    --approve
   ```

6. **Add Helm Chart Repo**:
   - Add the EKS chart repository to Helm.

   ```bash
   helm repo add eks https://aws.github.io/eks-charts
   ```

7. **Install the AWS Load Balancer Controller**:
   - Install the AWS Load Balancer Controller on the EKS cluster using Helm.

   ```bash
   helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set clusterName=<cluster-name> --set serviceAccount.create=false --set serviceAccount.name=aws-load-balancer-controller
   ```

8. **Verify the Controller**:
   - Check that the AWS Load Balancer Controller is running in the `kube-system` namespace.

   ```bash
   kubectl get pods -n kube-system
   ```

---

### Reference:
- [AWS Load Balancer Controller Documentation](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.8/)

---

### Notes:
- The sequence of steps for setting up services (VPC, EKS, RDS, etc.) is crucial to ensure all dependencies are correctly configured.
- Always verify IAM roles and policies to ensure proper security and access control.
