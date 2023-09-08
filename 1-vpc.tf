module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.1"

  name = "eks-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.0.0/24", "10.0.1.0/24"]
  public_subnets  = ["10.0.2.0/24", "10.0.3.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  nat_gateway_tags = {
    Name = "nat"
  }

  igw_tags = {
    Name = "igw"
  }

  public_subnet_tags = {
    Name                                          = "public subnet"
    "kubernetes.io/role/elb"                      = "1"
    "kubernetes.io/cluster/${local.cluster_name}" = "owned"
  }

  private_subnet_tags = {
    Name                                          = "private subnet"
    "kubernetes.io/role/internal-elb"             = "1"
    "kubernetes.io/cluster/${local.cluster_name}" = "owned"
  }

  public_route_table_tags = {
    Name = "public route"
  }

  private_route_table_tags = {
    Name = "private route"
  }

  tags = {
    Terraform = "true"
  }
}
