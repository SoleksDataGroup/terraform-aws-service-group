// Module: aws/service-group
// Descriprion: module input variables
//

variable "vpc_id" {
  description = "Service  group VPC ID"
  type = string
  default = ""
}

variable "group_size" {
  description = "Service group size per availabelity zone"
  type = number
  default = 3
}

variable "name_prefix" {
  description = "Service group name prefix"
  type = string
  default = "service-group"
}

variable "service_type" {
  description = "Service group service type"
  type = string
  default = ""
}

variable "ami_name" {
  description = "Service group AMI name"
  type = string
  default = ""
}

variable "instance_type" {
  description = "Service group instance type"
  type = string
  default = ""
}

variable "block_device_name" {
  description = "Name of the additional block device"
  type = string
  default = "/dev/sdb"
}

variable "block_device_type" {
  description = "Type of the additional block device"
  type = string
  default = "gp2"
}

variable "block_device_size" {
  description = "Size of the additional block device (in GB)."
  type = number
  default = 8
}

variable "block_device_delete_on_termination" {
  description = "Whether the volume should be destroyed on instance termination."
  type = bool
  default = true
}

variable "instance_iam_profile_arn" {
  description = "Service group instance iam profile arn"
  type = string
  default = ""
}

variable "subnet_ids" {
  description = "Service group subnet IDs"
  type = list(string)
  default = []
}

variable "dns_zone_id" {
  description = "Nomad agents DNS zone id"
  type = string
  default = ""
}

variable "tags" {
  description = "Nomad agent resources tags"
  type = map
  default = {}
}

variable "target_group_arns" {
  description = "Target group ARNs to attach to service group ASG"
  type = list
  default = []
}

variable "security_group_ingress" {
  description = "Ingress traffic security rules"
  type = list(object({
    protocol = string
    from_port = number
    to_port = number
    cidr_blocks = optional(list(string))
    description = optional(string)
    ipv6_cidr_blocks = optional(list(string))
    prefix_list_ids = optional(list(string))
    security_groups = optional(list(string))
    self = optional(string)
  }))
  default = []
}

variable "security_group_egress" {
  description = "Engress traffic security rules"
  type = list(object({
    protocol = string
    from_port = number
    to_port = number
    cidr_blocks = optional(list(string))
    description = optional(string)
    ipv6_cidr_blocks = optional(list(string))
    prefix_list_ids = optional(list(string))
    security_groups = optional(list(string))
    self = optional(string)
  }))
  default = []
}

variable "user_data" {
  description = "Cloudinit userdata in base64 format"
  type = string
  default = ""
}
