resource "azurerm_resource_group" "test" {
  name     = "acceptanceTestResourceGroup1"
  location = "West US"
}

resource "azurerm_network_security_group" "test" {
  name                = "acceptanceTestSecurityGroup1"
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"
}

resource "azurerm_network_security_rule" "test" {
  name                        = "Port_80"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "80"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.test.name}"
  network_security_group_name = "${azurerm_network_security_group.test.name}"
}

resource "azurerm_ddos_protection_plan" "test" {
  name                = "ddospplan1"
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"
}

resource "azurerm_public_ip" "test" {
  name                = "PublicIPForLB"
  location            = "West US"
  resource_group_name = "${azurerm_resource_group.test.name}"
  allocation_method   = "Static"
}

resource "azurerm_lb" "test" {
  name                = "TestLoadBalancer"
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = "${azurerm_public_ip.test.id}"
  }
}

resource "azurerm_lb_backend_address_pool" "test" {
  resource_group_name = "${azurerm_resource_group.test.name}"
  loadbalancer_id     = "${azurerm_lb.test.id}"
  name                = "BackEndAddressPool"
}

resource "azurerm_lb_probe" "test" {
 resource_group_name = "${azurerm_resource_group.test.name}"
 loadbalancer_id     = "${azurerm_lb.test.id}"
 name                = "ssh-running-probe"
 port                = "80"
}

resource "azurerm_lb_rule" "test" {
  resource_group_name            = "${azurerm_resource_group.test.name}"
  loadbalancer_id                = "${azurerm_lb.test.id}"
  name                           = "LBRule"
  protocol                       = "Tcp"
  frontend_port                  = 22
  backend_port                   = 22
  frontend_ip_configuration_name = "PublicIPAddress"
}

resource "azurerm_virtual_network" "test" {
  name                = "demovirtualNetwork1"
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"
  address_space       = ["10.0.0.0/22"]

  ddos_protection_plan {
    id     = "${azurerm_ddos_protection_plan.test.id}"
    enable = true
  }

  subnet {
    name           = "demosubnet1"
    address_prefix = "10.0.1.0/24"
  }

  subnet {
    name           = "demosubnet2"
    address_prefix = "10.0.2.0/24"
  }

  subnet {
    name           = "demosubnet3"
    address_prefix = "10.0.3.0/24"
    security_group = "${azurerm_network_security_group.test.id}"
  }

  tags = {
    environment = "Production"
  }
 }
