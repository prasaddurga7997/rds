variable "block1" {
  default = "10.0.0.0/16"
  type = string
}

variable "block2" {
  default = "10.0.1.0/24"
  type = string
}

variable "region" {
  default = "eu-north-1a"
  type = string
}

variable "ami" {
  default = "ami-080c90a2022058cce"
  type = string
}

variable "instancetype" {
  default = "t3.micro"
  type = string
}