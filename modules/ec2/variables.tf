variable "name" {}
variable "ami_id" {}
variable "instance_type" {}
variable "subnet_id" {}
variable "security_group_ids" {
  type = list(string)
}
variable "key_name" {}
variable "user_data_path" {}


variable "enabled" {
  type    = bool
  default = true
}