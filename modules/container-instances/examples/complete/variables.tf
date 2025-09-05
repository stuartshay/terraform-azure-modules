# Complete Example Variables

variable "acr_password" {
  description = "Password for Azure Container Registry authentication"
  type        = string
  sensitive   = true
}
