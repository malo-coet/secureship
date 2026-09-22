# Tunables. Override any of these in a terraform.tfvars file or with -var flags.

variable "prefix" {
  description = "Short name prefixed to every resource. Lowercase letters/numbers only."
  type        = string
  default     = "secureship"
}

variable "location" {
  description = "Azure region. westeurope and francecentral both work well from France."
  type        = string
  default     = "westeurope"
}

variable "node_count" {
  description = "Number of worker nodes. Keep at 1-2 to save credits."
  type        = number
  default     = 2
}

variable "node_size" {
  description = "VM size for the nodes. B-series are burstable and cheap."
  type        = string
  default     = "Standard_B2s"
}
