variable "env_code" {
  type = string
}

variable "region" {
  type    = string
}

variable "public_subnets" {
  type = list(string)
}

variable "private_subnets" {
  type = list(string)
}

variable "ami" {
  type    = string
  default = "ami-04823729c75214919"
}

variable "eks_ami" {
  type    = string
  default = "ami-0bc4534a93057f9fb"
}

variable "ami_type" {
  type    = string
  default = "AL2_x86_64"
}

variable "instance_types" {
  type    = list(string)
  default = ["t2.micro"]
}

variable "iam_instance_profile" {
  type    = string
  default = "EC2FullAccess"
}

variable "key_name" {
  type    = string
  default = "tf_example"
}
