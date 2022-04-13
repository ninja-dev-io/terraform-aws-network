locals {
  base_path = "./easy-rsa/easyrsa3"
  certs     = concat([for client in var.vpn.clients : "${client}.${var.env}.${var.vpn.domain}"], ["server.${var.env}.${var.vpn.domain}", "ca"])
}


resource "null_resource" "clone_repo" {
  provisioner "local-exec" {
    command = "git clone https://github.com/OpenVPN/easy-rsa.git"
  }
}

resource "null_resource" "init_pki" {
  provisioner "local-exec" {
    command     = "./easyrsa init-pki"
    working_dir = local.base_path
  }
  depends_on = [null_resource.clone_repo]
}

resource "null_resource" "set_var" {
  provisioner "local-exec" {
    command     = <<-EOT
          echo "set_var EASYRSA_BATCH	\"yes\"" >> ./pki/vars
          echo "set_var EASYRSA_DN	\"cn_only\"" >> ./pki/vars
         EOT
    working_dir = local.base_path
  }
  depends_on = [null_resource.clone_repo, null_resource.init_pki]
}

resource "null_resource" "build_ca" {
  provisioner "local-exec" {
    command     = "./easyrsa build-ca nopass"
    working_dir = local.base_path
  }
  depends_on = [null_resource.clone_repo, null_resource.init_pki, null_resource.set_var]
}

resource "null_resource" "build_server_cert" {
  provisioner "local-exec" {
    command     = "./easyrsa build-server-full server.${var.env}.${var.vpn.domain} nopass"
    working_dir = local.base_path
  }
  depends_on = [null_resource.clone_repo, null_resource.init_pki, null_resource.set_var, null_resource.build_ca]
}

resource "null_resource" "build_client_cert" {
  for_each = { for index, client in var.vpn.clients : index => client }
  provisioner "local-exec" {
    command     = "./easyrsa build-client-full ${each.value}.${var.env}.${var.vpn.domain} nopass"
    working_dir = local.base_path
  }
  depends_on = [null_resource.clone_repo, null_resource.init_pki, null_resource.set_var, null_resource.build_ca]
}

data "local_file" "private_key" {
  for_each   = { for cert in local.certs : cert => cert }
  filename   = "${local.base_path}/pki/private/${each.value}.key"
  depends_on = [null_resource.clone_repo, null_resource.init_pki, null_resource.set_var, null_resource.build_server_cert, null_resource.build_client_cert]
}

data "local_file" "crt" {
  for_each   = { for cert in local.certs : cert => cert }
  filename   = "${local.base_path}/pki${each.key != "ca" ? "/issued" : ""}/${each.value}.crt"
  depends_on = [null_resource.clone_repo, null_resource.init_pki, null_resource.set_var, null_resource.build_server_cert, null_resource.build_client_cert]
}

resource "aws_acm_certificate" "certs" {
  for_each          = { for cert in local.certs : cert => cert }
  private_key       = data.local_file.private_key[each.value].content
  certificate_body  = data.local_file.crt[each.value].content
  certificate_chain = lookup(data.local_file.crt, "ca").content
  depends_on        = [data.local_file.private_key, data.local_file.crt]
}

resource "aws_ec2_client_vpn_endpoint" "vpn" {
  description            = "Client VPN endpoint"
  client_cidr_block      = var.vpn.client_cidr_block
  split_tunnel           = var.vpn.split_tunnel
  server_certificate_arn = lookup(aws_acm_certificate.certs, "server.${var.env}.${var.vpn.domain}").arn

  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = lookup(aws_acm_certificate.certs, "ca").arn
  }

  connection_log_options {
    enabled = false
  }
  depends_on = [aws_acm_certificate.certs]

}

resource "aws_ec2_client_vpn_network_association" "private" {
  for_each               = aws_subnet.private_subnets
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn.id
  subnet_id              = each.value.id
  security_groups        = [for security_group in var.vpn.security_groups : lookup(local.security_groups, security_group)]
  depends_on             = [aws_subnet.private_subnets, aws_security_group.depth_zero, aws_security_group.depth_one, aws_security_group.depth_two, aws_security_group.depth_three]
}

resource "aws_ec2_client_vpn_authorization_rule" "vpn_auth_rule" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn.id
  target_network_cidr    = aws_vpc.vpc.cidr_block
  authorize_all_groups   = true
}


