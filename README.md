# Terraform-EKS
Deploy EKS via Terraform

1. Use AWS VPC module for:
    - VPC
    - IGW
    - NAT & EIP

2. Deploy EKS using EKS Cluster and Node Group resources

3. Use AWS IAM Role & Policy Attachment resources

4. Deploy AWS ALB Ingress Controller and accompanying resources:
    - https://github.com/kubernetes-sigs/aws-load-balancer-controller/blob/main/docs/deploy/installation.md

    - https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.6/deploy/installation/


1. 
eksctl utils associate-iam-oidc-provider \
    --region <region-code> \
    --cluster <your-cluster-name> \
    --approve

2. 
aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://manifests/alb-policy.json

3. 
eksctl create iamserviceaccount \
--cluster=tf-cluster \
--namespace=kube-system \
--name=aws-load-balancer-controller \
--attach-policy-arn=arn:aws:iam::600005164000:policy/AWSLoadBalancerControllerIAMPolicy \
--override-existing-serviceaccounts \
--region us-east-1 \
--approve

4. 
kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v1.5.4/cert-manager.yaml

# NOTE: wait for the cert manager to be fully operational before deploying ALB 
# ( https://github.com/kubernetes-sigs/aws-load-balancer-controller/issues/2359 )

5. 
kubectl apply -f manifests/v2_6_0_full.yaml

6. 
kubectl apply -f manifests/v2_6_0_ingclass.yaml


# Current Error:

    MountVolume.SetUp failed for volume "cert" : secret "aws-load-balancer-webhook-tls" not found

    * NOTE: Possibly an error with cert-manager 