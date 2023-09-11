##  Create EKS Cluster that uses AWS Load Balancer  ##


AWS-Load-Balancer-Controller GitHub ( v2.6.0 ):

# Installation
https://github.com/kubernetes-sigs/aws-load-balancer-controller/blob/v2.6.0/docs/deploy/installation.md

# YAML Files
https://github.com/kubernetes-sigs/aws-load-balancer-controller/tree/v2.6.0/docs/install


1. Create Base Architecture

    1. VPC module
    2. EKS Cluster
    3. Node Group
    4. OIDC Provider

    * Same process as cluster-autoscaler


2. Create IAM Role & Policy, and Connect via OIDC Provider

    1. IAM Policy Document Data Source

        - connect OIDC with EKS Cluster ServiceAccount for AWS Load Balancer
        * the Assume Role Policy will be attached to this ServiceAccount
    
    2. Create IAM Role for AWS Load Balancer

        - assume_role_policy --> IAM Policy Document Data Source

    3. Create IAM Policy ( Copy from AWS Load Balancer GitHub )

        - because Policy is large, copy to a file in the same directory
        - reference the file as the policy

    4. Attach Policy / Output IAM Role's ARN

        - will be used in the YAML definition file later


3. Apply Terraform to Create IAM Resources and Connect OIDC Provider

    $ terraform init
    $ terraform apply


4. Connect to EKS Cluster and Update Kubeconfig

    $ aws eks update-kubeconfig --region us-east-1 --name eks-lb
    $ kubectl get svc


##############################################################################


5. Create and Deploy AWS Load Balancer Controller Definition File

            - 3 Options: YAML, Helm, or Terraform -


    ##  YAML  ##


    1. Deploy Cert Manager YAML File

        $ kubectl apply --validate=false -f \
            https://github.com/jetstack/cert-manager/releases/download/v1.5.4/cert-manager.yaml

        $ kubectl get pods -n cert-manager 
            ( should be 3 pods )
    

    2. Download the YAML files for the Load Balancer Controller

        $ wget https://github.com/kubernetes-sigs/aws-load-balancer-controller/releases/download/v2.6.0/v2_6_0_full.yaml

        1. Save YAML file and Edit it

          # ServiceAccount ( line 655-664 ): 
            
            * add <Role ARN> to annotation 
              
              ...
              metadata:
                name: aws-load-balancer-controller
                namespace: kube-system
                annotations:
                * eks.amazonaws.com/role-arn: <IAM ROLE ARN for AWS LB>

                * arn:aws:iam::600005164000:role/aws-load-balancer-controller-role
                
          # Deployment ( line 903-965 ):

            * add <Cluster Name> under "container:" --> "args:" 
            
              spec:
                containers:
                - args:
                - --cluster-name=<Cluster Name>
                - --ingress-class=alb
            
            * eks-aws-lb


    3. Deploy YAML file 

        * You will have to run it twice, because it is trying to create resources
          and use them at the same time

          $ kubectl apply -f ../../aws-lb/v2_6_0_full.yaml 

        * May also required IngressClass & IngressClassParams YAML file

          $ wget https://github.com/kubernetes-sigs/aws-load-balancer-controller/releases/download/v2.6.0/v2_6_0_ingclass.yaml

          $ kubectl apply -f ../../k8s/v2_6_0_ingclass.yaml

    
    ##  Helm  ##

    https://github.com/aws/eks-charts/blob/master/stable/aws-load-balancer-controller/README.md


    1. Add EKS Cluster to Helm Repo

        $ heml repo add eks https://aws.github.io/eks-charts

    
    2. Create and Deploy ServiceAccount YAML file

        1. Create ServiceAccount ( helm-service-account.yaml )

          ---
          apiVersion: v1
          kind: ServiceAccount
          metadata:
            name: aws-load-balancer-controller
            namespace: kube-system
            annotations:
              eks.amazonaws.com/role-arn: <IAM Role ARN for AWS LB Controller>

            * arn:aws:iam::600005164000:role/aws-load-balancer-controller-role

        2. Apply ServiceAccount

          $ kubectl apply -f ../../k8s/helm-servce-account.yaml
    
    
    3. Install ( for Clusters with IRSA / OIDC Connect )

        $ helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
            -n kube-system \
            --set clusterName=eks-aws-lb \
            --set serviceAccount.create=false \
            --set serviceAccount.name=aws-load-balancer-controller
    

    ##  Terraform ( Helm must be installed )  ##


    1. Create Terraform config file for Helm

        1. Create Provider and set config options
        
        2. Create "helm_release" resource & "set" proper values and "depends_on"

            * set
            - clusterName
            - image.tag
            - serviceAccount.name
            - serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn

            * depends_on
            - VPC                   ( if Controller is created at the same time as VPC )
            - EKS               ( if Controller is created at the same time as EKS Cluster )
            - EKS Node Group
            - IAM Policy Document for Load Balancer Controller


    2. Apply Terraform to create Helm Resources

        $ terraform init
        $ terraform apply

    
    3. Confirm "helm_release" resource was deployed

        $ helm list -n kube-system

        * should show aws-load-balancer-controller


    4. Get LB Controller Logs before you deploy an Ingress resource

        $ kubectl logs -f -n kube-system \
            -l app.kubernetes.io/name=aws-load-balancer-controller


##############################################################################


6. Create an Ingress Resource

    1. Create Ingress YAML file and suppporting Objects

        - Namespace
        - Deployment
        - Service
        - Ingress

    2. 
