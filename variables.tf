variable "env_code" {
  type = string
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

variable "key_name" {
  type    = string
  default = "tf_example"
}
