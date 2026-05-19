variable "resource_group_name" {}

variable "location" {}

variable "github_org" {
  type = string
}

variable "github_repo" {
  type = string
}

variable "production_environment" {
  type    = string
  default = "production"
}

variable "main_branch" {
  type    = string
  default = "main"
}

variable "subscription_id" {
  type = string
}

variable "tfstate_storage_account_id" {
  type = string
}