variable "lab_name" {
  description = "One-place name for every resource created by this lab."
  type        = string
  default     = "terraform-docker-lab"

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9_-]*$", var.lab_name))
    error_message = "lab_name must contain lowercase letters, digits, underscores, or hyphens and start with a letter or digit."
  }
}

variable "image_tag" {
  description = "Pinned nginx image tag used by the lab."
  type        = string
  default     = "1.27.5-alpine"
}

variable "host_port" {
  description = "Loopback-only host port that publishes nginx."
  type        = number
  default     = 18080

  validation {
    condition     = var.host_port >= 1024 && var.host_port <= 65535
    error_message = "host_port must be between 1024 and 65535."
  }
}
