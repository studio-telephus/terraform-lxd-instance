locals {
  files = flatten(tolist([for d in var.mount_dirs : [for f in fileset(d, "**") : {
    source = "${d}/${f}"
    target = "/${f}"
  }]]))
}

resource "lxd_instance" "lxd_instance" {
  name      = var.name
  image     = var.image
  profiles  = var.profiles
  ephemeral = false

  config = {
    "boot.autostart" = var.autostart
  }

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

resource "null_resource" "local_exec_condition" {
  count = var.exec_enabled ? length(var.exec) : 0
  provisioner "local-exec" {
    command     = <<-EXEC
      while IFS='=' read -r key value ; do
        lxc config set ${var.name} $value
      done < <(env | grep "G76HJU3RFV_")
      lxc exec ${var.name} -- bash -xe -c 'chmod +x ${var.exec[count.index].entrypoint} && ${var.exec[count.index].entrypoint}'
    EXEC
    interpreter = ["/bin/bash", "-c"]
    environment = { for key, value in var.exec[count.index].environment : "G76HJU3RFV_${key}" => "environment.${key}=${value}" }
  }
  depends_on = [lxd_instance.lxd_instance]
}
