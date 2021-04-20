variable "region" {
  default = "ap-northeast-2"
}

variable "amazon_linux" {
  type    = string
  default = "ami-0a93a08544874b3b7"
}

variable "availabilityZoneA" {
  default = "ap-northeast-2a"
}

variable "availabilityZoneC" {
  default = "ap-northeast-2c"
}

variable "instanceTenancy" {
  default = "default"
}

variable "dnsSupport" {
  default = true
}

variable "dnsHostNames" {
  default = true
}

variable "bucket_name" {
  type    = string
  default = "tfendpoint"
}

variable "dev_key_name" {
  type    = string
  default = "yeumkey"
}