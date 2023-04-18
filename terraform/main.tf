provider "proxmox" {
    pm_tls_insecure = true
    pm_api_url = var.pm_api_url
    #pm_api_token_id = var.pm_api_token_id
    #pm_api_token_secret = var.pm_api_token_secret
    pm_user = var.pm_user
    pm_password = var.pm_password
}

#resource "proxmox_vm_qemu" "example" {
#    name = "servy-mcserverface"
#    desc = "A test for using terraform and vagrant"
#    target_node = "pve"
#}

resource "proxmox_vm_qemu" "kube-server" {
  count = 1
  name = "kube-server-0${count.index + 1}"
  target_node = var.target_node
  vmid = "40${count.index + 1}"
  clone = "ubuntu-2004-cloudinit-template"
  agent = 1
  os_type = "cloud-init"
  cores = 2
  sockets = 1
  cpu = "host"
  memory = 8192
  scsihw = "virtio-scsi-pci"
  bootdisk = "scsi0"
  disk {
    slot = 0
    size = "256G"
    type = "scsi"
    storage = "VMs"
    #storage_type = "zfspool"
    iothread = 0
  }
  network {
    model = "virtio"
    bridge = "vmbr0"
  }
  
  network {
    model = "virtio"
    bridge = "vmbr17"
  }
  lifecycle {
    ignore_changes = [
      network,
    ]
  }
  ipconfig0 = "ip=192.168.77.10${count.index + 1}/24,gw=192.168.77.1"
  ipconfig1 = "ip=10.17.0.10${count.index + 1}/24"
  sshkeys = <<EOF
  ${var.ssh_key}
  EOF
}
resource "proxmox_vm_qemu" "kube-agent" {
  count = 2
  name = "kube-agent-0${count.index + 1}"
  target_node = var.target_node
  vmid = "50${count.index + 1}"
  clone = "ubuntu-2004-cloudinit-template"
  agent = 1
  os_type = "cloud-init"
  cores = 2
  sockets = 1
  cpu = "host"
  memory = 8192
  scsihw = "virtio-scsi-pci"
  bootdisk = "scsi0"
  disk {
    slot = 0
    size = "192G"
    type = "scsi"
    storage = "VMs"
    #storage_type = "zfspool"
    iothread = 0
  }
  network {
    model = "virtio"
    bridge = "vmbr0"
  }
  
  network {
    model = "virtio"
    bridge = "vmbr17"
  }
  lifecycle {
    ignore_changes = [
      network,
    ]
  }
  ipconfig0 = "ip=192.168.77.11${count.index + 1}/24,gw=192.168.77.1"
  ipconfig1 = "ip=10.17.0.11${count.index + 1}/24"
  sshkeys = <<EOF
  ${var.ssh_key}
  EOF
}
resource "proxmox_vm_qemu" "kube-storage" {
  count = 1
  name = "kube-storage-0${count.index + 1}"
  target_node = var.target_node
  vmid = "60${count.index + 1}"
  clone = "ubuntu-2004-cloudinit-template"
  agent = 1
  os_type = "cloud-init"
  cores = 2
  sockets = 1
  cpu = "host"
  memory = 4096
  scsihw = "virtio-scsi-pci"
  bootdisk = "scsi0"
  disk {
    slot = 0
    size = "128G"
    type = "scsi"
    storage = "VMs"
    #storage_type = "zfspool"
    iothread = 0
  }
  network {
    model = "virtio"
    bridge = "vmbr0"
  }
  
  network {
    model = "virtio"
    bridge = "vmbr17"
  }
  lifecycle {
    ignore_changes = [
      network,
    ]
  }
  ipconfig0 = "ip=192.168.77.12${count.index + 1}/24,gw=192.168.77.1"
  ipconfig1 = "ip=10.17.0.12${count.index + 1}/24"
  sshkeys = <<EOF
  ${var.ssh_key}
  EOF
}