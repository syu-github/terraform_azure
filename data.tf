# data "azurerm_subnet" "data_subnet" {
#   name                 = "${var.subnet_name}"
#   virtual_network_name = "${var.virtual_network_name}"
#   resource_group_name  = "${var.network_rg_name}"
# }
#
# data "azurerm_virtual_network" "data_virtual_network" {
#   name                = "${var.virtual_network_name}"
#   resource_group_name = "${var.network_rg_name}"
# }

data "azurerm_subnet" "data_subnet" {
  name                 = "my_subnet_test_name"
  virtual_network_name = "${azurerm_virtual_network.my_vnet_test.name}"
  resource_group_name  = "${azurerm_resource_group.rg_vmss.name}"
}

data "azurerm_virtual_network" "data_virtual_network" {
  name                = "${azurerm_virtual_network.my_vnet_test.name}"
  resource_group_name = "${azurerm_resource_group.rg_vmss.name}"
}
