# "timestamp" template function replacement
locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

#variables {

#  host="${env("VC_HOST")}"
#  template_vm="${env("VC_TEMPLATE")}"
#  vcenter="${env("VC_VCENTER")}"
#  vm="${env("VC_VM")}"
#  cluster="${env("VC_CLUSTER")}"
#}


variable "template" {

  default= env("PKR_VAR_VC_TEMPLATE")

}

variable "vm" {

  default= env("PKR_VAR_VC_VM")
}

variable "host" {

  default= env("PKR_VAR_VC_HOST")
}

variable "cluster" {

  default= env("PKR_VAR_VC_CLUSTER")
}

variable "vcenter" {

  default= env("PKR_VAR_VC_VCENTER")
}

variable "datastore" {

  default= env("PKR_VAR_VC_DS")
}

variable "datacenter" {

  default= env("PKR_VAR_VC_DC")
}

variable "folder" {

  default= env("PKR_VAR_VC_FD")
}

# source blocks are analogous to the "builders" in json templates. They are used
# in build blocks. A build block runs provisioners and post-processors on a
# source. Read the documentation for source blocks here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/source
source "vsphere-clone" "MGlobal" {
  communicator        = "ssh"
  host                = "${var.host}"
  insecure_connection = "true"
  password            = "Password1!"
  template            = "${var.template}"
  username            = "administrator@vsphere.local"
  vcenter_server      = "vcsa-01.lab.com"
  cluster             = "${var.cluster}"
  vm_name             = "${var.vm}"
  notes               = "Template created on ${local.timestamp}"
  convert_to_template = "true"
  ssh_username        = "root"
  ssh_password        = "Password1"
  datacenter          = "${var.datacenter}"
  datastore           = "${var.datastore}"
  folder              = "${var.folder}"
}

# a build block invokes sources and runs provisioning steps on them. The
# documentation for build blocks can be found here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/build
build {
  sources = ["source.vsphere-clone.MGlobal"]

  provisioner "shell" {
    inline = ["cat /etc/passwd", "yum install httpd -y"]
  }

  provisioner "ansible" {
    playbook_file = "./default-config.yml"
      extra_arguments = ["-v"]

    }
}