resource "azurerm_resource_group" "this" {
  name     = var.name
  location = var.location

  tags =  {
      environment = var.environment
      owner       = var.owner
    }
}
