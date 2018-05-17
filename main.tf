###################### provider ##################################
provider "azurerm" {
  subscription_id = "${var.subscription_id}"
  client_id       = "${var.client_id}"
  client_secret   = "${var.client_secret}"
  tenant_id       = "${var.tenant_id}"
  environment     = "${var.environment}"
}

######################### end provider ##########################

######################## resource group vmss ###########################
resource "azurerm_resource_group" "rg_vmss" {
  name     = "${var.rg_vmss_name}"
  location = "${var.rg_vmss_location}"

  tags {
    environment = "${var.environment}"
  }
}

######################## end of resource group vmss ###########################

#################### define vnet and subnet  ###########################
#
resource "azurerm_virtual_network" "my_vnet_test" {
  name                = "my_vnet_test_name"
  resource_group_name = "${azurerm_resource_group.rg_vmss.name}"
  address_space       = ["192.168.0.0/16"]
  location            = "china north"

  # dns_servers         = ["10.0.0.4", "10.0.0.5"]

  tags {
    environment = "${var.environment}"
  }
}

resource "azurerm_subnet" "my_subnet_test" {
  name                 = "my_subnet_test_name"
  resource_group_name  = "${azurerm_resource_group.rg_vmss.name}"
  virtual_network_name = "${azurerm_virtual_network.my_vnet_test.name}"
  address_prefix       = "192.168.1.0/24"
}

# data "azurerm_subnet" "data_subnet" {
#   name                 = "${azurerm_subnet.my_subnet_test.name}"
#   virtual_network_name = "${azurerm_virtual_network.my_vnet_test.name}"
#   resource_group_name  = "${azurerm_resource_group.rg_vmss.name}"
# }
#
# data "azurerm_virtual_network" "data_virtual_network" {
#   name                = "${azurerm_virtual_network.my_vnet_test.name}"
#   resource_group_name = "${azurerm_resource_group.rg_vmss.name}"
# }

#################### end of  define vnet and subnet  ###########################

#########################  create gateway vm #############

#public ip
resource "azurerm_public_ip" "public_ip1" {
  name                         = "gw_public_ip1"
  location                     = "china north"
  resource_group_name          = "${azurerm_resource_group.rg_vmss.name}"
  public_ip_address_allocation = "static"
  idle_timeout_in_minutes      = 30
}

resource "azurerm_network_interface" "instance-nic1" {
  name                = "${var.instance_hostnames}-nic"
  location            = "china north"                            #"China North"
  resource_group_name = "${azurerm_resource_group.rg_vmss.name}"

  ip_configuration {
    name                          = "fixed"
    subnet_id                     = "${data.azurerm_subnet.data_subnet.id}"
    private_ip_address_allocation = "dynamic"

    # private_ip_address            = "${var.private_ip_address}"
    public_ip_address_id = "${azurerm_public_ip.public_ip1.id}"
  }
}

#Create apache vm
resource "azurerm_virtual_machine" "gw_instance" {
  name                  = "${var.instance_hostnames}"
  location              = "${var.vm_location}"                              #"China North"
  resource_group_name   = "${azurerm_resource_group.rg_vmss.name}"
  network_interface_ids = ["${azurerm_network_interface.instance-nic1.id}"]
  vm_size               = "${var.vm_size}"

  #delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  #delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "openlogic"
    offer     = "CentOS"
    sku       = "7.4"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.instance_hostnames}sda"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_data_disk {
    name              = "${var.instance_hostnames}opt"
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "30"
    managed_disk_type = "Premium_LRS"
  }

  os_profile {
    computer_name  = "${var.instance_hostnames}"
    admin_username = "superadmin"
    admin_password = "Dec@thl0n2018"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys = {
      path     = "/home/superadmin/.ssh/authorized_keys"
      key_data = "${file("${var.ssh_cert}")}"
    }
  }
}

#########################  end of create gateway vm #############

############################ define network infrastructure ###################
# resource "azurerm_virtual_network" "vn_vmss" {
#   name                = "${var.vn_vmss_name}"
#   address_space       = ["192.168.0.0/16"]
#   location            = "${var.vn_vmss_location}"
#   resource_group_name = "${azurerm_resource_group.rg_vmss.name}"
#
#   tags {
#     environment = "${var.environment}"
#   }
# }
#
# resource "azurerm_subnet" "sb_vmss" {
#   name                 = "${var.sb_vmss_name}"
#   resource_group_name  = "${azurerm_resource_group.rg_vmss.name}"
#   virtual_network_name = "${azurerm_virtual_network.vn_vmss.name}"
#   address_prefix       = "192.168.1.0/24"
# }

resource "azurerm_public_ip" "public_ip_vmss_ip0" {
  name                         = "${var.public_ip_vmss_name_01}"
  location                     = "${var.public_ip_vmss_location}"
  resource_group_name          = "${azurerm_resource_group.rg_vmss.name}"
  public_ip_address_allocation = "static"
  idle_timeout_in_minutes      = 30

  #domain_name_label            = "${azurerm_resource_group.rg_vmss.name}"

  tags {
    environment = "${var.environment}"
  }
}

resource "azurerm_public_ip" "public_ip_vmss_ip1" {
  name                         = "${var.public_ip_vmss_name_02}"
  location                     = "${var.public_ip_vmss_location}"
  resource_group_name          = "${azurerm_resource_group.rg_vmss.name}"
  public_ip_address_allocation = "static"
  idle_timeout_in_minutes      = 30

  #domain_name_label            = "${azurerm_resource_group.rg_vmss.name}"

  tags {
    environment = "${var.environment}"
  }
}

resource "azurerm_public_ip" "public_ip_vmss_ip2" {
  name                         = "${var.public_ip_vmss_name_03}"
  location                     = "${var.public_ip_vmss_location}"
  resource_group_name          = "${azurerm_resource_group.rg_vmss.name}"
  public_ip_address_allocation = "static"
  idle_timeout_in_minutes      = 30

  #domain_name_label            = "${azurerm_resource_group.rg_vmss.name}"

  tags {
    environment = "${var.environment}"
  }
}

resource "azurerm_public_ip" "public_ip_vmss_ip3" {
  name                         = "${var.public_ip_vmss_name_04}"
  location                     = "${var.public_ip_vmss_location}"
  resource_group_name          = "${azurerm_resource_group.rg_vmss.name}"
  public_ip_address_allocation = "static"
  idle_timeout_in_minutes      = 30

  #domain_name_label            = "${azurerm_resource_group.rg_vmss.name}"

  tags {
    environment = "${var.environment}"
  }
}

############################ end of define network infrastructure ###################

# ############################ define vm scaleset for API ###################
resource "azurerm_lb" "lb_vmss_test" {
  name                = "${var.lb_vmss_name}"
  location            = "${var.lb_vmss_location}"
  resource_group_name = "${azurerm_resource_group.rg_vmss.name}"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = "${azurerm_public_ip.public_ip_vmss_ip0.id}"
  }

  tags {
    environment = "${var.environment}"
  }
}

resource "azurerm_lb_backend_address_pool" "bpepool_vmss_test" {
  resource_group_name = "${azurerm_resource_group.rg_vmss.name}"
  loadbalancer_id     = "${azurerm_lb.lb_vmss_test.id}"
  name                = "BackEndAddressPool"
}

resource "azurerm_lb_probe" "lb_probe_vmss_test" {
  resource_group_name = "${azurerm_resource_group.rg_vmss.name}"
  loadbalancer_id     = "${azurerm_lb.lb_vmss_test.id}"
  name                = "ssh-running-probe"
  port                = "${var.application_port}"
}

resource "azurerm_lb_rule" "lbnatrule_vmss_test" {
  resource_group_name            = "${azurerm_resource_group.rg_vmss.name}"
  loadbalancer_id                = "${azurerm_lb.lb_vmss_test.id}"
  name                           = "http"
  protocol                       = "Tcp"
  frontend_port                  = "${var.application_port}"
  backend_port                   = "${var.application_port}"
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.bpepool_vmss_test.id}"
  frontend_ip_configuration_name = "PublicIPAddress"
  probe_id                       = "${azurerm_lb_probe.lb_probe_vmss_test.id}"
}

resource "azurerm_virtual_machine_scale_set" "vmss_test_api" {
  name                = "${var.vmss_name_api}"
  location            = "${var.rg_vmss_location}"
  resource_group_name = "${azurerm_resource_group.rg_vmss.name}"
  upgrade_policy_mode = "Manual"

  sku {
    name     = "Standard_A0"
    tier     = "Standard"
    capacity = 2
  }

  storage_profile_image_reference {
    id = "/subscriptions/99b70366-069c-41a0-a0d8-8f30911c14eb/resourceGroups/RG-OMX-PAAS-PRD-TF/providers/Microsoft.Compute/images/ordmax_api_img"
  }

  #
  # storage_profile_image_reference {
  #   publisher = "Canonical"
  #   offer     = "UbuntuServer"
  #   sku       = "16.04-LTS"
  #   version   = "latest"
  # }
  storage_profile_os_disk {
    name          = ""
    caching       = "ReadWrite"
    create_option = "FromImage"

    managed_disk_type = "Standard_LRS"

    # image = "/subscriptions/99b70366-069c-41a0-a0d8-8f30911c14eb/resourceGroups/RG-OMX-PAAS-PRD-TF/providers/Microsoft.Compute/images/ordmax_api_img"
  }

  os_profile {
    computer_name_prefix = "vmlab"
    admin_username       = "syu"
    admin_password       = "syu123"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/syu/.ssh/authorized_keys"
      key_data = "${file("${var.ssh_cert}")}"
    }
  }

  network_profile {
    name    = "terraformnetworkprofile"
    primary = true

    ip_configuration {
      name                                   = "IPConfiguration"
      subnet_id                              = "${data.azurerm_subnet.data_subnet.id}"
      load_balancer_backend_address_pool_ids = ["${azurerm_lb_backend_address_pool.bpepool_vmss_test.id}"]
    }
  }

  tags {
    environment = "${var.environment}"
  }
}

# ############################ end of define vm scaleset  ###################

# ############################ define vm scaleset for web ###################
resource "azurerm_lb" "lb_vmss_test_web" {
  name                = "${var.lb_vmss_name_web}"
  location            = "${var.lb_vmss_location_web}"
  resource_group_name = "${azurerm_resource_group.rg_vmss.name}"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = "${azurerm_public_ip.public_ip_vmss_ip2.id}"
  }

  tags {
    environment = "${var.environment}"
  }
}

resource "azurerm_lb_backend_address_pool" "bpepool_vmss_test_web" {
  resource_group_name = "${azurerm_resource_group.rg_vmss.name}"
  loadbalancer_id     = "${azurerm_lb.lb_vmss_test_web.id}"
  name                = "BackEndAddressPool"
}

resource "azurerm_lb_probe" "lb_probe_vmss_test_web" {
  resource_group_name = "${azurerm_resource_group.rg_vmss.name}"
  loadbalancer_id     = "${azurerm_lb.lb_vmss_test_web.id}"
  name                = "ssh-running-probe"
  port                = "${var.application_port}"
}

resource "azurerm_lb_rule" "lbnatrule_vmss_test_web" {
  resource_group_name            = "${azurerm_resource_group.rg_vmss.name}"
  loadbalancer_id                = "${azurerm_lb.lb_vmss_test_web.id}"
  name                           = "http"
  protocol                       = "Tcp"
  frontend_port                  = "${var.application_port}"
  backend_port                   = "${var.application_port}"
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.bpepool_vmss_test_web.id}"
  frontend_ip_configuration_name = "PublicIPAddress"
  probe_id                       = "${azurerm_lb_probe.lb_probe_vmss_test_web.id}"
}

resource "azurerm_virtual_machine_scale_set" "vmss_test_web" {
  name                = "${var.vmss_name_web}"
  location            = "${var.rg_vmss_location}"
  resource_group_name = "${azurerm_resource_group.rg_vmss.name}"
  upgrade_policy_mode = "Manual"

  sku {
    name     = "Standard_A0"
    tier     = "Standard"
    capacity = 2
  }

  storage_profile_image_reference {
    id = "/subscriptions/99b70366-069c-41a0-a0d8-8f30911c14eb/resourceGroups/RG-OMX-PAAS-PRD-TF/providers/Microsoft.Compute/images/ordmax_web_img"
  }

  #
  # storage_profile_image_reference {
  #   publisher = "Canonical"
  #   offer     = "UbuntuServer"
  #   sku       = "16.04-LTS"
  #   version   = "latest"
  # }
  storage_profile_os_disk {
    name          = ""
    caching       = "ReadWrite"
    create_option = "FromImage"

    managed_disk_type = "Standard_LRS"

    # image = "/subscriptions/99b70366-069c-41a0-a0d8-8f30911c14eb/resourceGroups/RG-OMX-PAAS-PRD-TF/providers/Microsoft.Compute/images/ordmax_api_img"
  }

  os_profile {
    computer_name_prefix = "vmlab"
    admin_username       = "syu"
    admin_password       = "syu123"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/syu/.ssh/authorized_keys"
      key_data = "${file("${var.ssh_cert}")}"
    }
  }

  network_profile {
    name    = "terraformnetworkprofile"
    primary = true

    ip_configuration {
      name                                   = "IPConfiguration"
      subnet_id                              = "${data.azurerm_subnet.data_subnet.id}"
      load_balancer_backend_address_pool_ids = ["${azurerm_lb_backend_address_pool.bpepool_vmss_test_web.id}"]
    }
  }

  tags {
    environment = "${var.environment}"
  }
}

# ############################ end of define vm scaleset  ###################

# ############################  define autoscale  ###################

# resource "azurerm_application_insights" "test_insights" {
#   name                = "tf-test-appinsights"
#   location            = "china north"
#   resource_group_name = "${azurerm_resource_group.rg_vmss.name}"
#   application_type    = "Web"
#
#   tags {
#     environment = "${var.environment}"
#   }
# }

resource "azurerm_template_deployment" "test_autoscale" {
  name                = "acctesttemplate-01"
  resource_group_name = "${azurerm_resource_group.rg_vmss.name}"

  template_body = <<DEPLOY
  {
    "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json",
    "contentVersion": "1.0.0.0",
    "parameters": {   },
    "variables": {    },
    "resources": [

      {
        "id": "/subscriptions/99b70366-069c-41a0-a0d8-8f30911c14eb/resourceGroups/rg_vmss_test/providers/microsoft.insights/autoscalesettings/Profile1",
        "name": "Profile1",
        "type": "Microsoft.Insights/autoscaleSettings",
        "apiVersion": "2015-04-01",
        "location": "chinanorth",
        "tags": {  "$type": "Microsoft.WindowsAzure.Management.Common.Storage.CasePreservedDictionary, Microsoft.WindowsAzure.Management.Common.Storage"  },

          "properties": {
              "name": "Profile1",
              "enabled": true,
              "targetResourceUri": "/subscriptions/99b70366-069c-41a0-a0d8-8f30911c14eb/resourceGroups/rg_vmss_test/providers/Microsoft.Compute/virtualMachineScaleSets/vmss_test_api",
              "profiles": [
                  {
                      "name": "Auto created scale condition",
                      "capacity": {  "minimum": "2",  "maximum": "10",  "default": "2"  },
                      "rules": [
                          {
                              "scaleAction": {  "direction": "Increase",  "type": "ChangeCount",  "value": "1",  "cooldown": "PT5M"  },
                              "metricTrigger": {
                                  "metricName": "Percentage CPU",
                                  "metricNamespace": "",
                                  "metricResourceUri": "/subscriptions/99b70366-069c-41a0-a0d8-8f30911c14eb/resourceGroups/rg_vmss_test/providers/Microsoft.Compute/virtualMachineScaleSets/vmss_test_api",
                                  "operator": "GreaterThan",
                                  "statistic": "Average",
                                  "threshold": 4,
                                  "timeAggregation": "Average",
                                  "timeGrain": "PT1M",
                                  "timeWindow": "PT10M"
                              }
                          },
                          {
                              "scaleAction": {  "direction": "Decrease",  "type": "ChangeCount",  "value": "1",  "cooldown": "PT5M"  },
                              "metricTrigger": {
                                  "metricName": "Percentage CPU",
                                  "metricNamespace": "",
                                  "metricResourceUri": "/subscriptions/99b70366-069c-41a0-a0d8-8f30911c14eb/resourceGroups/rg_vmss_test/providers/Microsoft.Compute/virtualMachineScaleSets/vmss_test_api",
                                  "operator": "LessThan",
                                  "statistic": "Average",
                                  "threshold": 5,
                                  "timeAggregation": "Average",
                                  "timeGrain": "PT1M",
                                  "timeWindow": "PT10M"
                              }
                          }
                      ]
                  }
              ],
              "notifications": [
                  {
                      "operation": "Scale",
                      "email": {  "sendToSubscriptionAdministrator": false,  "sendToSubscriptionCoAdministrators": false,  "customEmails": []   },
                      "webhooks": []
                  }
              ],
              "targetResourceLocation": "chinanorth"
          }

      },

      {
        "id": "/subscriptions/99b70366-069c-41a0-a0d8-8f30911c14eb/resourceGroups/rg_vmss_test/providers/microsoft.insights/autoscalesettings/Profile2",
        "name": "Profile2",
        "type": "Microsoft.Insights/autoscaleSettings",
        "apiVersion": "2015-04-01",
        "location": "chinanorth",
        "tags": {
              "$type": "Microsoft.WindowsAzure.Management.Common.Storage.CasePreservedDictionary, Microsoft.WindowsAzure.Management.Common.Storage"
          },

          "properties": {
              "name": "Profile2",
              "enabled": true,
              "targetResourceUri": "/subscriptions/99b70366-069c-41a0-a0d8-8f30911c14eb/resourceGroups/rg_vmss_test/providers/Microsoft.Compute/virtualMachineScaleSets/vmss_test_web",
              "profiles": [
                  {
                      "name": "Auto created scale condition",
                      "capacity": {
                          "minimum": "2",
                          "maximum": "10",
                          "default": "2"
                      },
                      "rules": [
                          {
                              "scaleAction": {
                                  "direction": "Increase",
                                  "type": "ChangeCount",
                                  "value": "1",
                                  "cooldown": "PT5M"
                              },
                              "metricTrigger": {
                                  "metricName": "Percentage CPU",
                                  "metricNamespace": "",
                                  "metricResourceUri": "/subscriptions/99b70366-069c-41a0-a0d8-8f30911c14eb/resourceGroups/rg_vmss_test/providers/Microsoft.Compute/virtualMachineScaleSets/vmss_test_web",
                                  "operator": "GreaterThan",
                                  "statistic": "Average",
                                  "threshold": 4,
                                  "timeAggregation": "Average",
                                  "timeGrain": "PT1M",
                                  "timeWindow": "PT10M"
                              }
                          },
                          {
                              "scaleAction": {
                                  "direction": "Decrease",
                                  "type": "ChangeCount",
                                  "value": "1",
                                  "cooldown": "PT5M"
                              },
                              "metricTrigger": {
                                  "metricName": "Percentage CPU",
                                  "metricNamespace": "",
                                  "metricResourceUri": "/subscriptions/99b70366-069c-41a0-a0d8-8f30911c14eb/resourceGroups/rg_vmss_test/providers/Microsoft.Compute/virtualMachineScaleSets/vmss_test_web",
                                  "operator": "LessThan",
                                  "statistic": "Average",
                                  "threshold": 5,
                                  "timeAggregation": "Average",
                                  "timeGrain": "PT1M",
                                  "timeWindow": "PT10M"
                              }
                          }
                      ]
                  }
              ],
              "notifications": [
                  {
                      "operation": "Scale",
                      "email": {
                          "sendToSubscriptionAdministrator": false,
                          "sendToSubscriptionCoAdministrators": false,
                          "customEmails": []
                      },
                      "webhooks": []
                  }
              ],
              "targetResourceLocation": "chinanorth"
          }
      }


    ]

  }

DEPLOY

  deployment_mode = "Incremental" #  Incremental  ,Complete
}

# ############################ end of define autoscale  ###################


############################# define application_gateway  ###################
#
# resource "azurerm_public_ip" "public_ip_vmss_gw" {
#   name                         = "public_ip_vmss_gw_name"
#   location                     = "${var.public_ip_vmss_location}"
#   resource_group_name          = "${azurerm_resource_group.rg_vmss.name}"
#   public_ip_address_allocation = "Dynamic"
#   idle_timeout_in_minutes      = 30
#
#   #domain_name_label            = "${azurerm_resource_group.rg_vmss.name}"
#
#   tags {
#     environment = "${var.environment}"
#   }
# }
#
# # resource "azurerm_subnet" "subnet_gw" {
# #   name                 = "my_subnet_gw"
# #   resource_group_name  = "${azurerm_resource_group.rg.name}"
# #   virtual_network_name = "${azurerm_virtual_network.vnet.name}"
# #   address_prefix       = "10.254.2.0/24"
# # }
#
# resource "azurerm_application_gateway" "app_gw" {
#   name                = "my-application-gateway-12345"
#   resource_group_name = "${azurerm_resource_group.rg_vmss.name}"
#   location            = "${var.rg_vmss_location}"
#
#   sku {
#     name     = "Standard_Small"
#     tier     = "Standard"
#     capacity = 2
#   }
#
#   gateway_ip_configuration {
#     name      = "my-gateway-ip-configuration"
#     subnet_id = "${data.azurerm_virtual_network.data_virtual_network.id}/subnets/${data.azurerm_subnet.data_subnet.name}"
#   }
#
#   frontend_port {
#     name = "${data.azurerm_virtual_network.data_virtual_network.name}-feport"
#     port = 80
#   }
#
#   frontend_ip_configuration {
#     name                 = "${data.azurerm_virtual_network.data_virtual_network.name}-feip"
#     public_ip_address_id = "${azurerm_public_ip.public_ip_vmss_gw.id}"
#   }
#
#   backend_address_pool {
#     name = "${data.azurerm_virtual_network.data_virtual_network.name}-beap"
#   }
#
#   backend_http_settings {
#     name                  = "${data.azurerm_virtual_network.data_virtual_network.name}-be-htst"
#     cookie_based_affinity = "Disabled"
#     port                  = 80
#     protocol              = "Http"
#     request_timeout       = 1
#   }
#
#   http_listener {
#     name                           = "${data.azurerm_virtual_network.data_virtual_network.name}-httplstn"
#     frontend_ip_configuration_name = "${data.azurerm_virtual_network.data_virtual_network.name}-feip"
#     frontend_port_name             = "${data.azurerm_virtual_network.data_virtual_network.name}-feport"
#     protocol                       = "Http"
#   }
#
#   request_routing_rule {
#     name                       = "${data.azurerm_virtual_network.data_virtual_network.name}-rqrt"
#     rule_type                  = "Basic"
#     http_listener_name         = "${data.azurerm_virtual_network.data_virtual_network.name}-httplstn"
#     backend_address_pool_name  = "${data.azurerm_virtual_network.data_virtual_network.name}-beap"
#     backend_http_settings_name = "${data.azurerm_virtual_network.data_virtual_network.name}-be-htst"
#   }
# }


############################# end of define autoscale  ###################

