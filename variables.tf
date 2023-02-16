variable "location" {
  type        = string
  description = "resource location"
  default     = "westeurope"
}

variable "azure_pub_key" {
  description = "Public key para VM na Azure"
  type        = string
}
