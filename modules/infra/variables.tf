variable "main_vpc_id" {
    description     =  "ID of main VPC."
    type            = string
}

variable "private_subnet1" {
    type            = string
}

variable "private_subnet2" {
    type            = string
}

variable "private_subnet3" {
    type            = string
}

variable "cluster_role_arn" {
    type            = string
}

variable "eks_sg" {
    type = string
}

variable "node_role_arn" {
    type = string
}

variable "api_cluster2_sec_grp" {
    type = string
}