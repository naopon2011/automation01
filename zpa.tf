
terraform {
  required_providers {
    zpa = {
      source = "zscaler/zpa"
      version = "~> 3.0.0"
    }
  }
}
provider "zpa" {
  zpa_client_id         =  var.zpa_client_id
  zpa_client_secret     =  var.zpa_client_secret
  zpa_customer_id       =  var.zpa_customer_id 
  zpa_cloud             =  "PRODUCTION"
}

// Create Application Segment
resource "zpa_application_segment" "windows" {
  name             = "windows_created_by_terraform"
  description      = "windows_created_by_terraform"
  enabled          = true
  health_reporting = "ON_ACCESS"
  bypass_type      = "NEVER"
  is_cname_enabled = true
  tcp_port_ranges   = ["3389", "3389"]
  udp_port_ranges   = ["3389", "3389"]
  domain_names     = ["${aws_instance.windows.private_dns}"]
  segment_group_id = zpa_segment_group.win_app_group.id
  server_groups {
    id = [zpa_server_group.win_servers.id]
  }
}

// Create Server Group
resource "zpa_server_group" "win_servers" {
  name              = "Win Servers Group created by terraform"
  description       = "Win Servers Group created by terraform"
  enabled           = true
  dynamic_discovery = true
  app_connector_groups {
    id = [data.zpa_app_connector_group.dc_connector_group.id]
  }
}

// Create Segment Group
resource "zpa_segment_group" "win_app_group" {
  name            = "Win App group created by terraform"
  description     = "Win App group created by terraform"
  enabled         = true
}

resource "zpa_policy_access_rule" "windows_access_policy" {
  name                          = "Access policy created by terraform"
  description                   = "Access policy created by terraform"
  action                        = "ALLOW"
  operator = "AND"
  policy_set_id = data.zpa_policy_type.access_policy.id

  conditions {
    negated = false
    operator = "OR"
    operands {
      name =  "Example"
      object_type = "APP_GROUP"
      lhs = "id"
      rhs = zpa_segment_group.win_app_group.id
    }
  }
}

// Retrieve App Connector Group
data "zpa_app_connector_group" "dc_connector_group" {
  name = var.ac_group
}

data "zpa_policy_type" "access_policy" {
    policy_type = "ACCESS_POLICY"
}
