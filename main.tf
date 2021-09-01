
# This code is auto generated and any changes will be lost if it is regenerated.

terraform {
    required_version = ">= 0.12.0"
}

# -- Copyright: Copyright (c) 2020, 2021, Oracle and/or its affiliates.
# ---- Author : Andrew Hopkinson (Oracle Cloud Solutions A-Team)
# ------ Connect to Provider
provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = "us-ashburn-1"
}

# ------ Retrieve Regional / Cloud Data
# -------- Get a list of Availability Domains
data "oci_identity_availability_domains" "AvailabilityDomains" {
    compartment_id = var.compartment_ocid
}
data "template_file" "AvailabilityDomainNames" {
    count    = length(data.oci_identity_availability_domains.AvailabilityDomains.availability_domains)
    template = data.oci_identity_availability_domains.AvailabilityDomains.availability_domains[count.index]["name"]
}
# -------- Get a list of Fault Domains
data "oci_identity_fault_domains" "FaultDomainsAD1" {
    availability_domain = element(data.oci_identity_availability_domains.AvailabilityDomains.availability_domains, 0)["name"]
    compartment_id = var.compartment_ocid
}
data "oci_identity_fault_domains" "FaultDomainsAD2" {
    availability_domain = element(data.oci_identity_availability_domains.AvailabilityDomains.availability_domains, 1)["name"]
    compartment_id = var.compartment_ocid
}
data "oci_identity_fault_domains" "FaultDomainsAD3" {
    availability_domain = element(data.oci_identity_availability_domains.AvailabilityDomains.availability_domains, 2)["name"]
    compartment_id = var.compartment_ocid
}
# -------- Get Home Region Name
data "oci_identity_region_subscriptions" "RegionSubscriptions" {
    tenancy_id = var.tenancy_ocid
}
data "oci_identity_regions" "Regions" {
}
data "oci_identity_tenancy" "Tenancy" {
    tenancy_id = var.tenancy_ocid
}

locals {
#    HomeRegion = [for x in data.oci_identity_region_subscriptions.RegionSubscriptions.region_subscriptions: x if x.is_home_region][0]
    home_region = lookup(
        {
            for r in data.oci_identity_regions.Regions.regions : r.key => r.name
        },
        data.oci_identity_tenancy.Tenancy.home_region_key
    )
}
# ------ Get List Service OCIDs
data "oci_core_services" "RegionServices" {
}
# ------ Get List Images
data "oci_core_images" "InstanceImages" {
    compartment_id           = var.compartment_ocid
}

# ------ Home Region Provider
provider "oci" {
    alias            = "home_region"
    tenancy_ocid     = var.tenancy_ocid
    user_ocid        = var.user_ocid
    fingerprint      = var.fingerprint
    private_key_path = var.private_key_path
    region           = local.home_region
}

# ------ Root Compartment
locals {
    DeploymentCompartment_id              = var.compartment_ocid
}

output "DeploymentCompartmentId" {
    value = local.DeploymentCompartment_id
}

# ------ Create Virtual Cloud Network
resource "oci_core_vcn" "Cas_Lhr_Prd_Vcn" {
    # Required
    compartment_id = local.DeploymentCompartment_id
    cidr_blocks    = ["10.18.0.0/16"]
    # Optional
    dns_label      = var.Cas_Lhr_Prd_Vcn_dns_label
    display_name   = var.Cas_Lhr_Prd_Vcn_display_name
}

locals {
    Cas_Lhr_Prd_Vcn_id                       = oci_core_vcn.Cas_Lhr_Prd_Vcn.id
    Cas_Lhr_Prd_Vcn_dhcp_options_id          = oci_core_vcn.Cas_Lhr_Prd_Vcn.default_dhcp_options_id
    Cas_Lhr_Prd_Vcn_domain_name              = oci_core_vcn.Cas_Lhr_Prd_Vcn.vcn_domain_name
    Cas_Lhr_Prd_Vcn_default_dhcp_options_id  = oci_core_vcn.Cas_Lhr_Prd_Vcn.default_dhcp_options_id
    Cas_Lhr_Prd_Vcn_default_security_list_id = oci_core_vcn.Cas_Lhr_Prd_Vcn.default_security_list_id
    Cas_Lhr_Prd_Vcn_default_route_table_id   = oci_core_vcn.Cas_Lhr_Prd_Vcn.default_route_table_id
}


# ------ Create Internet Gateway
resource "oci_core_internet_gateway" "Cas_Lhr_Prd_Igw" {
    # Required
    compartment_id = local.DeploymentCompartment_id
    vcn_id         = local.Cas_Lhr_Prd_Vcn_id
    # Optional
    enabled        = var.Cas_Lhr_Prd_Igw_enabled
    display_name   = var.Cas_Lhr_Prd_Igw_display_name
}

locals {
    Cas_Lhr_Prd_Igw_id = oci_core_internet_gateway.Cas_Lhr_Prd_Igw.id
}


# ------ Create NAT Gateway
resource "oci_core_nat_gateway" "Cas_Lhr_Prd_Ngw" {
    # Required
    compartment_id = local.DeploymentCompartment_id
    vcn_id         = local.Cas_Lhr_Prd_Vcn_id
    # Optional
    display_name   = var.Cas_Lhr_Prd_Ngw_display_name
    block_traffic  = var.Cas_Lhr_Prd_Ngw_block_traffic
}

locals {
    Cas_Lhr_Prd_Ngw_id = oci_core_nat_gateway.Cas_Lhr_Prd_Ngw.id
}


# ------ Create Security List
resource "oci_core_security_list" "Cas_Lhr_Prd_Pub_Lbr_Slt" {
    # Required
    compartment_id = local.DeploymentCompartment_id
    vcn_id         = local.Cas_Lhr_Prd_Vcn_id
    # Optional
    display_name   = var.Cas_Lhr_Prd_Pub_Lbr_Slt_display_name
}

locals {
    Cas_Lhr_Prd_Pub_Lbr_Slt_id = oci_core_security_list.Cas_Lhr_Prd_Pub_Lbr_Slt.id
}


# ------ Create Security List
resource "oci_core_security_list" "Cas_Lhr_Prd_Pri_App_Slt" {
    # Required
    compartment_id = local.DeploymentCompartment_id
    vcn_id         = local.Cas_Lhr_Prd_Vcn_id
    # Optional
    display_name   = var.Cas_Lhr_Prd_Pri_App_Slt_display_name
}

locals {
    Cas_Lhr_Prd_Pri_App_Slt_id = oci_core_security_list.Cas_Lhr_Prd_Pri_App_Slt.id
}


# ------ Create Security List
resource "oci_core_security_list" "Cas_Lhr_Prd_Pri_Dbs_Slt" {
    # Required
    compartment_id = local.DeploymentCompartment_id
    vcn_id         = local.Cas_Lhr_Prd_Vcn_id
    # Optional
    display_name   = var.Cas_Lhr_Prd_Pri_Dbs_Slt_display_name
}

locals {
    Cas_Lhr_Prd_Pri_Dbs_Slt_id = oci_core_security_list.Cas_Lhr_Prd_Pri_Dbs_Slt.id
}


# ------ Create Security List
resource "oci_core_security_list" "Cas_Lhr_Ppd_Pub_Lbr_Slt" {
    # Required
    compartment_id = local.DeploymentCompartment_id
    vcn_id         = local.Cas_Lhr_Prd_Vcn_id
    # Optional
    display_name   = var.Cas_Lhr_Ppd_Pub_Lbr_Slt_display_name
}

locals {
    Cas_Lhr_Ppd_Pub_Lbr_Slt_id = oci_core_security_list.Cas_Lhr_Ppd_Pub_Lbr_Slt.id
}


# ------ Create Security List
resource "oci_core_security_list" "Cas_Lhr_Ppd_Pri_App_Slt" {
    # Required
    compartment_id = local.DeploymentCompartment_id
    vcn_id         = local.Cas_Lhr_Prd_Vcn_id
    # Optional
    display_name   = var.Cas_Lhr_Ppd_Pri_App_Slt_display_name
}

locals {
    Cas_Lhr_Ppd_Pri_App_Slt_id = oci_core_security_list.Cas_Lhr_Ppd_Pri_App_Slt.id
}


# ------ Create Security List
resource "oci_core_security_list" "Cas_Lhr_Ppd_Pri_Dbs_Slt" {
    # Required
    compartment_id = local.DeploymentCompartment_id
    vcn_id         = local.Cas_Lhr_Prd_Vcn_id
    # Optional
    display_name   = var.Cas_Lhr_Ppd_Pri_Dbs_Slt_display_name
}

locals {
    Cas_Lhr_Ppd_Pri_Dbs_Slt_id = oci_core_security_list.Cas_Lhr_Ppd_Pri_Dbs_Slt.id
}


# ------ Create Route Table
resource "oci_core_route_table" "Cas_Lhr_Prd_Pub_Lbr_Rtb" {
    # Required
    compartment_id = local.DeploymentCompartment_id
    vcn_id         = local.Cas_Lhr_Prd_Vcn_id
    route_rules    {
        destination_type  = var.Cas_Lhr_Prd_Pub_Lbr_Rtb_route_rule_01_destination_type
        destination       = var.Cas_Lhr_Prd_Pub_Lbr_Rtb_route_rule_01_destination
        network_entity_id = local.Cas_Lhr_Prd_Igw_id
        description       = var.Cas_Lhr_Prd_Pub_Lbr_Rtb_route_rule_01_description
    }
    # Optional
    display_name   = var.Cas_Lhr_Prd_Pub_Lbr_Rtb_display_name
}

locals {
    Cas_Lhr_Prd_Pub_Lbr_Rtb_id = oci_core_route_table.Cas_Lhr_Prd_Pub_Lbr_Rtb.id
}


# ------ Create Route Table
resource "oci_core_route_table" "Cas_Lhr_Prd_Pri_App_Rtb" {
    # Required
    compartment_id = local.DeploymentCompartment_id
    vcn_id         = local.Cas_Lhr_Prd_Vcn_id
    route_rules    {
        destination_type  = var.Cas_Lhr_Prd_Pri_App_Rtb_route_rule_01_destination_type
        destination       = var.Cas_Lhr_Prd_Pri_App_Rtb_route_rule_01_destination
        network_entity_id = local.Cas_Lhr_Prd_Ngw_id
        description       = var.Cas_Lhr_Prd_Pri_App_Rtb_route_rule_01_description
    }
    route_rules    {
        destination_type  = var.Cas_Lhr_Prd_Pri_App_Rtb_route_rule_02_destination_type
        destination       = lookup([for x in data.oci_core_services.RegionServices.services: x if substr(x.name, 0, 3) == var.Cas_Lhr_Prd_Pri_App_Rtb_route_rule_02_destination][0], "cidr_block")
        network_entity_id = local.Cas_Lhr_Prd_Sgw_id
        description       = var.Cas_Lhr_Prd_Pri_App_Rtb_route_rule_02_description
    }
    # Optional
    display_name   = var.Cas_Lhr_Prd_Pri_App_Rtb_display_name
}

locals {
    Cas_Lhr_Prd_Pri_App_Rtb_id = oci_core_route_table.Cas_Lhr_Prd_Pri_App_Rtb.id
}


# ------ Create Route Table
resource "oci_core_route_table" "Cas_Lhr_Prd_Pri_Dbs_Rtb" {
    # Required
    compartment_id = local.DeploymentCompartment_id
    vcn_id         = local.Cas_Lhr_Prd_Vcn_id
    route_rules    {
        destination_type  = var.Cas_Lhr_Prd_Pri_Dbs_Rtb_route_rule_01_destination_type
        destination       = var.Cas_Lhr_Prd_Pri_Dbs_Rtb_route_rule_01_destination
        network_entity_id = local.Cas_Lhr_Prd_Ngw_id
        description       = var.Cas_Lhr_Prd_Pri_Dbs_Rtb_route_rule_01_description
    }
    route_rules    {
        destination_type  = var.Cas_Lhr_Prd_Pri_Dbs_Rtb_route_rule_02_destination_type
        destination       = lookup([for x in data.oci_core_services.RegionServices.services: x if substr(x.name, 0, 3) == var.Cas_Lhr_Prd_Pri_Dbs_Rtb_route_rule_02_destination][0], "cidr_block")
        network_entity_id = local.Cas_Lhr_Prd_Sgw_id
        description       = var.Cas_Lhr_Prd_Pri_Dbs_Rtb_route_rule_02_description
    }
    # Optional
    display_name   = var.Cas_Lhr_Prd_Pri_Dbs_Rtb_display_name
}

locals {
    Cas_Lhr_Prd_Pri_Dbs_Rtb_id = oci_core_route_table.Cas_Lhr_Prd_Pri_Dbs_Rtb.id
}


# ------ Create Route Table
resource "oci_core_route_table" "Cas_Lhr_Ppd_Pub_Lbr_Rtb" {
    # Required
    compartment_id = local.DeploymentCompartment_id
    vcn_id         = local.Cas_Lhr_Prd_Vcn_id
    route_rules    {
        destination_type  = var.Cas_Lhr_Ppd_Pub_Lbr_Rtb_route_rule_01_destination_type
        destination       = var.Cas_Lhr_Ppd_Pub_Lbr_Rtb_route_rule_01_destination
        network_entity_id = local.Cas_Lhr_Prd_Igw_id
        description       = var.Cas_Lhr_Ppd_Pub_Lbr_Rtb_route_rule_01_description
    }
    # Optional
    display_name   = var.Cas_Lhr_Ppd_Pub_Lbr_Rtb_display_name
}

locals {
    Cas_Lhr_Ppd_Pub_Lbr_Rtb_id = oci_core_route_table.Cas_Lhr_Ppd_Pub_Lbr_Rtb.id
}


# ------ Create Route Table
resource "oci_core_route_table" "Cas_Lhr_Ppd_Pri_App_Rtb" {
    # Required
    compartment_id = local.DeploymentCompartment_id
    vcn_id         = local.Cas_Lhr_Prd_Vcn_id
    route_rules    {
        destination_type  = var.Cas_Lhr_Ppd_Pri_App_Rtb_route_rule_01_destination_type
        destination       = var.Cas_Lhr_Ppd_Pri_App_Rtb_route_rule_01_destination
        network_entity_id = local.Cas_Lhr_Prd_Ngw_id
        description       = var.Cas_Lhr_Ppd_Pri_App_Rtb_route_rule_01_description
    }
    route_rules    {
        destination_type  = var.Cas_Lhr_Ppd_Pri_App_Rtb_route_rule_02_destination_type
        destination       = lookup([for x in data.oci_core_services.RegionServices.services: x if substr(x.name, 0, 3) == var.Cas_Lhr_Ppd_Pri_App_Rtb_route_rule_02_destination][0], "cidr_block")
        network_entity_id = local.Cas_Lhr_Prd_Sgw_id
        description       = var.Cas_Lhr_Ppd_Pri_App_Rtb_route_rule_02_description
    }
    # Optional
    display_name   = var.Cas_Lhr_Ppd_Pri_App_Rtb_display_name
}

locals {
    Cas_Lhr_Ppd_Pri_App_Rtb_id = oci_core_route_table.Cas_Lhr_Ppd_Pri_App_Rtb.id
}


# ------ Create Route Table
resource "oci_core_route_table" "Cas_Lhr_Ppd_Pri_Dbs_Rtb" {
    # Required
    compartment_id = local.DeploymentCompartment_id
    vcn_id         = local.Cas_Lhr_Prd_Vcn_id
    route_rules    {
        destination_type  = var.Cas_Lhr_Ppd_Pri_Dbs_Rtb_route_rule_01_destination_type
        destination       = var.Cas_Lhr_Ppd_Pri_Dbs_Rtb_route_rule_01_destination
        network_entity_id = local.Cas_Lhr_Prd_Ngw_id
        description       = var.Cas_Lhr_Ppd_Pri_Dbs_Rtb_route_rule_01_description
    }
    route_rules    {
        destination_type  = var.Cas_Lhr_Ppd_Pri_Dbs_Rtb_route_rule_02_destination_type
        destination       = lookup([for x in data.oci_core_services.RegionServices.services: x if substr(x.name, 0, 3) == var.Cas_Lhr_Ppd_Pri_Dbs_Rtb_route_rule_02_destination][0], "cidr_block")
        network_entity_id = local.Cas_Lhr_Prd_Sgw_id
        description       = var.Cas_Lhr_Ppd_Pri_Dbs_Rtb_route_rule_02_description
    }
    # Optional
    display_name   = var.Cas_Lhr_Ppd_Pri_Dbs_Rtb_display_name
}

locals {
    Cas_Lhr_Ppd_Pri_Dbs_Rtb_id = oci_core_route_table.Cas_Lhr_Ppd_Pri_Dbs_Rtb.id
}


# ------ Create Route Table
resource "oci_core_route_table" "Okit_Rt007" {
    # Required
    compartment_id = local.DeploymentCompartment_id
    vcn_id         = local.Cas_Lhr_Prd_Vcn_id
    # Optional
    display_name   = var.Okit_Rt007_display_name
}

locals {
    Okit_Rt007_id = oci_core_route_table.Okit_Rt007.id
}


# ------ Get List Service OCIDs
locals {
    Cas_Lhr_Prd_SgwServiceId = lookup([for x in data.oci_core_services.RegionServices.services: x if substr(x.name, 0, 3) == var.Cas_Lhr_Prd_Sgw_service_name][0], "id")
}

# ------ Create Service Gateway
resource "oci_core_service_gateway" "Cas_Lhr_Prd_Sgw" {
    # Required
    compartment_id = local.DeploymentCompartment_id
    vcn_id         = local.Cas_Lhr_Prd_Vcn_id
    services {
        service_id = local.Cas_Lhr_Prd_SgwServiceId
    }
    # Optional
    display_name   = var.Cas_Lhr_Prd_Sgw_display_name
}

locals {
    Cas_Lhr_Prd_Sgw_id = oci_core_service_gateway.Cas_Lhr_Prd_Sgw.id
}


# ------ Create Dhcp Options
resource "oci_core_dhcp_options" "Okit_Do001" {
    # Required
    compartment_id = local.DeploymentCompartment_id
    vcn_id         = local.Cas_Lhr_Prd_Vcn_id
    options    {
        type  = var.Okit_Do001_dhcp_option_01_type
        server_type = var.Okit_Do001_dhcp_option_01_server_type
        custom_dns_servers       = []
    }
    # Optional
    display_name   = var.Okit_Do001_display_name
}

locals {
    Okit_Do001_id = oci_core_dhcp_options.Okit_Do001.id
}


# ------ Create Subnet
# ---- Create Public Subnet
resource "oci_core_subnet" "Cas_Lhr_Prd_Pub_Lbr_Sub" {
    # Required
    compartment_id             = local.DeploymentCompartment_id
    vcn_id                     = local.Cas_Lhr_Prd_Vcn_id
    cidr_block                 = var.Cas_Lhr_Prd_Pub_Lbr_Sub_cidr_block
    # Optional
    display_name               = var.Cas_Lhr_Prd_Pub_Lbr_Sub_display_name
    dns_label                  = var.Cas_Lhr_Prd_Pub_Lbr_Sub_dns_label
    security_list_ids          = [local.Cas_Lhr_Prd_Pub_Lbr_Slt_id]
    route_table_id             = local.Cas_Lhr_Prd_Pub_Lbr_Rtb_id
    dhcp_options_id            = local.Okit_Do001_id
    prohibit_public_ip_on_vnic = var.Cas_Lhr_Prd_Pub_Lbr_Sub_prohibit_public_ip_on_vnic
}

locals {
    Cas_Lhr_Prd_Pub_Lbr_Sub_id              = oci_core_subnet.Cas_Lhr_Prd_Pub_Lbr_Sub.id
    Cas_Lhr_Prd_Pub_Lbr_Sub_domain_name     = oci_core_subnet.Cas_Lhr_Prd_Pub_Lbr_Sub.subnet_domain_name
}


# ------ Create Subnet
# ---- Create Public Subnet
resource "oci_core_subnet" "Cas_Lhr_Prd_Pri_App_Sub" {
    # Required
    compartment_id             = local.DeploymentCompartment_id
    vcn_id                     = local.Cas_Lhr_Prd_Vcn_id
    cidr_block                 = var.Cas_Lhr_Prd_Pri_App_Sub_cidr_block
    # Optional
    display_name               = var.Cas_Lhr_Prd_Pri_App_Sub_display_name
    dns_label                  = var.Cas_Lhr_Prd_Pri_App_Sub_dns_label
    security_list_ids          = [local.Cas_Lhr_Prd_Pri_App_Slt_id]
    route_table_id             = local.Cas_Lhr_Prd_Pri_App_Rtb_id
    dhcp_options_id            = local.Okit_Do001_id
    prohibit_public_ip_on_vnic = var.Cas_Lhr_Prd_Pri_App_Sub_prohibit_public_ip_on_vnic
}

locals {
    Cas_Lhr_Prd_Pri_App_Sub_id              = oci_core_subnet.Cas_Lhr_Prd_Pri_App_Sub.id
    Cas_Lhr_Prd_Pri_App_Sub_domain_name     = oci_core_subnet.Cas_Lhr_Prd_Pri_App_Sub.subnet_domain_name
}


# ------ Create Subnet
# ---- Create Public Subnet
resource "oci_core_subnet" "Cas_Lhr_Prd_Pri_Dbs_Sub" {
    # Required
    compartment_id             = local.DeploymentCompartment_id
    vcn_id                     = local.Cas_Lhr_Prd_Vcn_id
    cidr_block                 = var.Cas_Lhr_Prd_Pri_Dbs_Sub_cidr_block
    # Optional
    display_name               = var.Cas_Lhr_Prd_Pri_Dbs_Sub_display_name
    dns_label                  = var.Cas_Lhr_Prd_Pri_Dbs_Sub_dns_label
    security_list_ids          = [local.Cas_Lhr_Prd_Pri_Dbs_Slt_id]
    route_table_id             = local.Cas_Lhr_Prd_Pri_Dbs_Rtb_id
    dhcp_options_id            = local.Okit_Do001_id
    prohibit_public_ip_on_vnic = var.Cas_Lhr_Prd_Pri_Dbs_Sub_prohibit_public_ip_on_vnic
}

locals {
    Cas_Lhr_Prd_Pri_Dbs_Sub_id              = oci_core_subnet.Cas_Lhr_Prd_Pri_Dbs_Sub.id
    Cas_Lhr_Prd_Pri_Dbs_Sub_domain_name     = oci_core_subnet.Cas_Lhr_Prd_Pri_Dbs_Sub.subnet_domain_name
}


# ------ Create Subnet
# ---- Create Public Subnet
resource "oci_core_subnet" "Cas_Lhr_Ppd_Pub_Lbr_Sub" {
    # Required
    compartment_id             = local.DeploymentCompartment_id
    vcn_id                     = local.Cas_Lhr_Prd_Vcn_id
    cidr_block                 = var.Cas_Lhr_Ppd_Pub_Lbr_Sub_cidr_block
    # Optional
    display_name               = var.Cas_Lhr_Ppd_Pub_Lbr_Sub_display_name
    dns_label                  = var.Cas_Lhr_Ppd_Pub_Lbr_Sub_dns_label
    security_list_ids          = [local.Cas_Lhr_Ppd_Pub_Lbr_Slt_id]
    route_table_id             = local.Cas_Lhr_Ppd_Pub_Lbr_Rtb_id
    dhcp_options_id            = local.Okit_Do001_id
    prohibit_public_ip_on_vnic = var.Cas_Lhr_Ppd_Pub_Lbr_Sub_prohibit_public_ip_on_vnic
}

locals {
    Cas_Lhr_Ppd_Pub_Lbr_Sub_id              = oci_core_subnet.Cas_Lhr_Ppd_Pub_Lbr_Sub.id
    Cas_Lhr_Ppd_Pub_Lbr_Sub_domain_name     = oci_core_subnet.Cas_Lhr_Ppd_Pub_Lbr_Sub.subnet_domain_name
}


# ------ Create Subnet
# ---- Create Public Subnet
resource "oci_core_subnet" "Cas_Lhr_Ppd_Pri_App_Sub" {
    # Required
    compartment_id             = local.DeploymentCompartment_id
    vcn_id                     = local.Cas_Lhr_Prd_Vcn_id
    cidr_block                 = var.Cas_Lhr_Ppd_Pri_App_Sub_cidr_block
    # Optional
    display_name               = var.Cas_Lhr_Ppd_Pri_App_Sub_display_name
    dns_label                  = var.Cas_Lhr_Ppd_Pri_App_Sub_dns_label
    security_list_ids          = [local.Cas_Lhr_Ppd_Pri_App_Slt_id]
    route_table_id             = local.Cas_Lhr_Ppd_Pri_App_Rtb_id
    dhcp_options_id            = local.Okit_Do001_id
    prohibit_public_ip_on_vnic = var.Cas_Lhr_Ppd_Pri_App_Sub_prohibit_public_ip_on_vnic
}

locals {
    Cas_Lhr_Ppd_Pri_App_Sub_id              = oci_core_subnet.Cas_Lhr_Ppd_Pri_App_Sub.id
    Cas_Lhr_Ppd_Pri_App_Sub_domain_name     = oci_core_subnet.Cas_Lhr_Ppd_Pri_App_Sub.subnet_domain_name
}


# ------ Create Subnet
# ---- Create Public Subnet
resource "oci_core_subnet" "Cas_Lhr_Ppd_Pri_Dbs_Sub" {
    # Required
    compartment_id             = local.DeploymentCompartment_id
    vcn_id                     = local.Cas_Lhr_Prd_Vcn_id
    cidr_block                 = var.Cas_Lhr_Ppd_Pri_Dbs_Sub_cidr_block
    # Optional
    display_name               = var.Cas_Lhr_Ppd_Pri_Dbs_Sub_display_name
    dns_label                  = var.Cas_Lhr_Ppd_Pri_Dbs_Sub_dns_label
    security_list_ids          = [local.Cas_Lhr_Ppd_Pri_Dbs_Slt_id]
    route_table_id             = local.Cas_Lhr_Ppd_Pri_Dbs_Rtb_id
    dhcp_options_id            = local.Okit_Do001_id
    prohibit_public_ip_on_vnic = var.Cas_Lhr_Ppd_Pri_Dbs_Sub_prohibit_public_ip_on_vnic
}

locals {
    Cas_Lhr_Ppd_Pri_Dbs_Sub_id              = oci_core_subnet.Cas_Lhr_Ppd_Pri_Dbs_Sub.id
    Cas_Lhr_Ppd_Pri_Dbs_Sub_domain_name     = oci_core_subnet.Cas_Lhr_Ppd_Pri_Dbs_Sub.subnet_domain_name
}

