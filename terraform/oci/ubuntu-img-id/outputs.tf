output "id" {
  description = "ID of the Image"
  value       = lookup(data.oci_core_images.node_pool_images.images[0], "id")
}