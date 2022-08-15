variable "region" {
  type = string
  default = "us-west1"
}

variable "zone" {
  type = string
  default = "us-central1-a"
}

variable "privatekeypath" {
  type = string
  default = "./ubuntu"          # private key
}

variable "publickeypath" {
  type = string
  default = "./ubuntu.pub"      # public key
}

variable "user" {
  type = string
  default = "ubuntu"            #user
}