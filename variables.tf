############################### variable for provider #####################
variable "subscription_id" {
  description = "subscription_id"
  type        = "string"
}

variable "client_id" {
  description = "client_id"
  type        = "string"
}

variable "client_secret" {
  description = "client_secret"
  type        = "string"
}

variable "tenant_id" {
  description = "tenant_id"
  type        = "string"
}

variable "environment" {
  description = "environment"
  type        = "string"
}

############################### end  variable for provider #####################

################################ variable for resouce group vmss #################
variable "rg_vmss_name" {
  description = "resouce group vmss name "
  type        = "string"
}

variable "rg_vmss_location" {
  description = "location of resouce group vmss "
  type        = "string"
}

################################ end of variable for resouce group vmss #################
###########################  variable for  gateway vm ###################
variable "instance_hostnames" {
  description = "instance hostnames"
  type        = "string"
}

variable "vm_size" {
  description = "vm size"
  type        = "string"
}

variable "vm_location" {
  description = "vm location" #location = "China North"
  type        = "string"
}

variable "ssh_cert" {
  description = "SSH key of the administrator user."
  default     = "data/ssh_keys/azure_preprod.pub"
}

###########################  end of variable for  gateway vm ###################

#############  variable for data source ##############
variable "subnet_name" {
  description = " the name of the subnet "
  type        = "string"
}

variable "virtual_network_name" {
  description = " the name of the virtual network "
  type        = "string"
}

variable "network_rg_name" {
  description = " the name of the virtual network resource group  "
  type        = "string"
}

########## end of variable data source ##########

################################ variable for virtualnetwork  #################
# variable "vn_vmss_name" {
#   description = " name of the virtual network "
#   type        = "string"
# }
#
# variable "vn_vmss_location" {
#   description = "location of virtual network  "
#   type        = "string"
# }
#
# variable "sb_vmss_name" {
#   description = " name of virtual subnet  "
#   type        = "string"
# }

variable "public_ip_vmss_name_01" {
  description = " public ip 01 for vmss "
  type        = "string"
}

variable "public_ip_vmss_name_02" {
  description = " public ip 02 for vmss "
  type        = "string"
}

variable "public_ip_vmss_name_03" {
  description = " public ip 03 for vmss "
  type        = "string"
}

variable "public_ip_vmss_name_04" {
  description = " public ip 04 for vmss "
  type        = "string"
}

variable "public_ip_vmss_location" {
  description = " location of public ip for vmss  "
  type        = "string"
}

################################ end of variable for virtualnetwork #################

################################ variable for scaleset for API  #################
variable "lb_vmss_name" {
  description = " name of the lb "
  type        = "string"
}

variable "lb_vmss_location" {
  description = "location of lb  "
  type        = "string"
}

variable "vmss_name_api" {
  description = " name of the vmss  "
  type        = "string"
}

variable "application_port" {
  description = " port of app  "
}

# variable "packer_image_name" {
#   description = " name of the image "
#   type        = "string"
# }

# variable "ssh_cert" {
#   description = " ssh cert file location "
#   type        = "string"
# }

################################ end of variable for scaleset for API  #################

################################ variable for scaleset for WEB  #################
variable "lb_vmss_name_web" {
  description = " name of the lb "
  type        = "string"
}

variable "lb_vmss_location_web" {
  description = "location of lb  "
  type        = "string"
}

variable "vmss_name_web" {
  description = " name of the vmss  "
  type        = "string"
}

# variable "application_port" {
#   description = " port of app  "
# }


# variable "packer_image_name" {
#   description = " name of the image "
#   type        = "string"
# }
#
# variable "ssh_cert" {
#   description = " ssh cert file location "
#   type        = "string"
# }


################################ end of variable for scaleset for WEB  #################

