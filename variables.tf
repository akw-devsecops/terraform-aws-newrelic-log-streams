variable "nr_account" {
  type        = string
  description = "The account id from the target NewRelic account."
}

variable "nr_license_key" {
  type        = string
  description = "The NewRelic ingest license key."
}

variable "log_group_subscriptions" {
  type        = set(string)
  description = "List of log groups to subscribe."
  default     = []
}

variable "tags" {
  type = map(string)
}

variable "common_attributes" {
  type        = map(string)
  description = "Describes the metadata sent to the HTTP endpoint destination."
  default = {}
}
