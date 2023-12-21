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
  type    = list(string)
  default = []
}

variable "exec_enabled" {
  type    = bool
  default = false
}

variable "exec" {
  type    = string
  default = null
}

variable "environment" {
  type    = map(any)
  default = {}
}

variable "local_exec_interpreter" {
  type    = list(string)
  default = ["/bin/bash", "-c"]
}

