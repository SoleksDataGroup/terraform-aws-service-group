// Module: aws/service-group
// Description:
//

locals {
  instance_subnet = flatten([
    for subnet in var.subnet_ids: [
      for i in range(var.group_size): subnet
    ]
  ])
}

resource "aws_security_group" "service-group-sg" {
  name = "${var.name_prefix}-${var.service_type}-sg"
  vpc_id = var.vpc_id

  dynamic "ingress" {
    for_each  = var.security_group_ingress
    content {
      self = lookup(ingress.value, "self", null)
      description = lookup(ingress.value, "description", null)
      protocol = lookup(ingress.value, "protocol", "-1")
      from_port = lookup(ingress.value, "from_port", -1)
      to_port = lookup(ingress.value, "to_port", -1)
      cidr_blocks = lookup(ingress.value, "cidr_blocks", [])
      ipv6_cidr_blocks = lookup(ingress.value, "ipv6_cidr_blocks", [])
      prefix_list_ids =  lookup(ingress.value, "ip_list_ids", [])
      security_groups = lookup(ingress.value, "security_groups", [])
    }
  }
  
  dynamic "egress" {
    for_each  = var.security_group_egress
    content {
      self = lookup(egress.value, "self", null)
      description = lookup(egress.value, "description", null)
      protocol = lookup(egress.value, "protocol", "-1")
      from_port = lookup(egress.value, "from_port", -1)
      to_port = lookup(egress.value, "to_port", -1)
      cidr_blocks = lookup(egress.value, "cidr_blocks")
      ipv6_cidr_blocks = lookup(egress.value, "ipv6_cidr_blocks", [])
      prefix_list_ids =  lookup(egress.value, "ip_list_ids", [])
      security_groups = lookup(egress.value, "security_groups", [])
    }
  }
}

data "aws_ami" "service-group-ami" {
  name_regex = var.ami_name
  owners = ["self"]
}

data "cloudinit_config" "service-group-cloud-init" {
  gzip = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/templates/service-group-cloud-init.yaml.tpl",{})
  }
}

resource "aws_launch_template" "service-group-launch-tmpl" {
  name_prefix = "${var.name_prefix}-${var.service_type}"

  image_id =  data.aws_ami.service-group-ami.id
  instance_type = var.instance_type

  block_device_mappings {
    device_name = var.block_device_name
    ebs {
      volume_type = var.block_device_type
      volume_size = var.block_device_size
      delete_on_termination = var.block_device_delete_on_termination
    }
  }
  iam_instance_profile {
    arn = "${var.instance_iam_profile_arn}"
  }

  user_data = data.cloudinit_config.service-group-cloud-init.rendered

  vpc_security_group_ids = [aws_security_group.service-group-sg.id]

  tag_specifications {
    resource_type = "instance"
    tags = merge(
      {  "Name"  = format("%s-%s", var.name_prefix, var.service_type)},
      var.tags
      )
  }

  monitoring {
    enabled = true
  }
}

resource "aws_autoscaling_group" "service-group-asg" {
  count = length(var.subnet_ids)
  name_prefix = "${var.name_prefix}-${var.service_type}"

  target_group_arns = var.target_group_arns

  max_size = var.group_size
  min_size = var.group_size

  vpc_zone_identifier = [var.subnet_ids[count.index]]

  launch_template {
    id = aws_launch_template.service-group-launch-tmpl.id
    version = "$Latest"
  }
}
