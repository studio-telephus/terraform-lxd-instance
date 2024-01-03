locals {
  files = flatten(tolist([for d in var.mount_dirs : [for f in fileset(d, "**") : {
    source = "${d}/${f}"
    target = "/${f}"
    }
    if !endswith(f, ".git") && !endswith(f, ".DS_Store")
  ]]))

  config = merge({
    "boot.autostart" = false
  }, { for key, value in var.environment : "environment.${key}" => value })
}

resource "lxd_instance" "lxd_instance" {
  name      = var.name
  image     = var.image
  profiles  = var.profiles
  ephemeral = false
  config    = local.config

  device {
    name       = var.nic.name
    type       = "nic"
    properties = var.nic.properties
  }

  dynamic "device" {
    for_each = var.volumes
    content {
      type = "disk"
      name = var.volumes[count.index].volume_name
      properties = {
        path   = var.volumes[count.index].path
        source = var.volumes[count.index].volume_name
        pool   = var.volumes[count.index].pool
      }
    }
  }

  dynamic "file" {
    for_each = local.files
    content {
      source             = file.value.source
      target_file        = file.value.target
      create_directories = true
    }
  }
}

resource "terraform_data" "local_exec_condition" {
  count = var.exec_enabled ? 1 : 0
  provisioner "local-exec" {
    when        = create
    command     = <<-EXEC
      lxc exec ${var.name} -- bash -xe -c 'chmod +x ${var.exec} && ${var.exec}'
    EXEC
    interpreter = var.local_exec_interpreter
  }
  depends_on = [lxd_instance.lxd_instance]
}
