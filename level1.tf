# Create the resource groups to host the blueprint
module "resource_group" {
    source                  = "git://github.com/LaurentLesle/azure_terraform_blueprint_modules_resource_group.git"
  
    prefix                  = "${var.prefix}"
    resource_groups         = "${var.resource_groups}"
    location                = "${var.location_map["region1"]}"
}

# Create the Azure Monitor workspace
module "monitoring_workspace" {
    source                  = "git://github.com/LaurentLesle/azure_terraform_blueprint_modules_log_analytics.git?ref=v1.3.3"
    
    prefix                  = "${var.prefix}-"
    name                    = "${var.analytics_workspace_name}"
    resource_group_name     = "${module.resource_group.names["level1"]}"
    location                = "${var.location_map["region1"]}"
}
module "security_center" {
    source                  = "git://github.com/LaurentLesle/azure_terraform_blueprint_modules_security_center.git?ref=v1.0"
  
    contact_email           = "${var.security_center["contact_email"]}"
    contact_phone           = "${var.security_center["contact_phone"]}"
    scope_id                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
    workspace_id            = "${module.monitoring_workspace.id}"
}