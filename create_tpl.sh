#! /bin/bash
apt update -y
apt install libguestfs-tools -y
wget https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img
virt-customize -a focal-server-cloudimg-amd64.img --install qemu-guest-agent
qm create 1000 --name "ubuntu-2004-cloudinit-template" --memory 8192 --cores 2 --net0 virtio,bridge=vmbr0
#qm set 1000 --scsi0 VMs:vm-1000-disk-0,import-from=focal-server-cloudimg-amd64.img
qm importdisk 1000 focal-server-cloudimg-amd64.img VMs
qm set 1000 --scsihw virtio-scsi-pci --scsi0 VMs:1000/vm-1000-disk-0.raw
qm set 1000 --boot c --bootdisk scsi0
qm set 1000 --ide2 VMs:cloudinit
qm set 1000 --serial0 socket --vga serial0
qm set 1000 --agent enabled=1
qm template 1000
