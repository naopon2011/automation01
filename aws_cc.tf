resource "random_string" "suffix" {
  length  = 8
  upper   = false
  special = false
}

locals {
  userdata = <<USERDATA
[ZSCALER]
CC_URL=${var.cc_vm_prov_url}
SECRET_NAME=${var.secret_name}
HTTP_PROBE_PORT=${var.http_probe_port}
USERDATA
}

module "cc_vm" {
  source                    = "./modules/terraform-zscc-ccvm-aws"
  cc_count                  = 1
  ami_id                    = var.cc_ami
  mgmt_subnet_id            = aws_subnet.private_subnet1.id
  service_subnet_id         = aws_subnet.private_subnet1.id
  instance_key              = var.instance_key
  user_data                 = local.userdata
  ccvm_instance_type        = var.cc_instance_type
  iam_instance_profile      = module.cc_iam.iam_instance_profile_id
  mgmt_security_group_id    = aws_security_group.sg.id
  service_security_group_id = aws_security_group.sg.id
  tag = var.vpc_name
  ebs_volume_type           = var.ebs_volume_type
  ebs_encryption_enabled    = var.ebs_encryption_enabled
  byo_kms_key_alias         = var.byo_kms_key_alias


  depends_on = [
    local_file.user_data_file,
    null_resource.cc_error_checker,
  ]
}

module "cc_iam" {
  source              = "./modules/terraform-zscc-iam-aws"
  iam_count           = 1
  name_prefix         = var.name_prefix
  resource_tag        = random_string.suffix.result
  cc_callhome_enabled = var.cc_callhome_enabled
  secret_name         = var.secret_name
}
