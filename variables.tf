variable "name" {
  type = string
}

variable "image" {
  type = string
}

variable "profiles" {
  type    = list(string)
  default = []
}

variable "nic" {
  type = object({
    name       = string
    properties = map(string)
  })
}

variable "volumes" {
  type = list(object({
    pool        = string
    volume_name = string
    path        = string
  }))
  default = []
}

variable "autostart" {
  type    = bool
  default = false
}

variable "mount_dirs" {
  type = list(string)
}

variable "exec_enabled" {
  type    = bool
  default = false
}

variable "exec" {
  type = list(object({
    entrypoint  = string
    environment = map(any)
  }))
  default = []
}

