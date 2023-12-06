variable "compartment_id" {
  description = "Compartment OCID"
}

variable "node_pool_shape" {
  default     = "VM.Standard.E3.Flex"
  description = "A shape is a template that determines the number of OCPUs, amount of memory, and other resources allocated to a newly created instance."
}

variable "image_operating_system" {
  default     = "Canonical Ubuntu"
  description = "The OS/image installed on all nodes in the node pool."
}
variable "image_operating_system_version" {
  default     = "20.04"
  description = "The OS/image version installed on all nodes in the node pool."
}
