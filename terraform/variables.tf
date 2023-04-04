variable "pm_api_url" {
  type = string
}

variable "pm_api_token_id" {
  type = string
}

variable "pm_api_token_secret" {
  type = string
}

variable "ssh_key" {
  type = string
}

variable "pm_user" {
  type = string
}

variable "pm_password" {
  type = string
}

variable "target_node" {
  default = "pve"
}