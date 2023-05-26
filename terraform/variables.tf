variable "vpc_name" {
    description = "The name of the VPC"
    type        = string
    default     = "sentinel-vpc"
}

variable "vpc_cidr" {
    description = "The CIDR block for the VPC"
    type        = string
    default     = "10.0.0.0/16"
}

variable "availability_zones" {
    description = "The availability zones to use for the VPC"
    type        = list(string)
    default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "public_subnets" {
    description = "The public subnets to use for the VPC"
    type        = list(string)
}
