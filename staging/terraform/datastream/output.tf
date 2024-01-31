output "vpc_id" {
  value = data.google_compute_network.vpc.id
}

output "vm_jmeter_public_ip" {
  value = google_compute_instance.vm_jmeter.network_interface[0].access_config[0].nat_ip
}

output "vm_jmeter_private_ip" {
  value = google_compute_instance.vm_jmeter.network_interface.0.network_ip
}

# output "vm_br_public_ip" {
#   value = google_compute_instance.vm_br.network_interface[0].access_config[0].nat_ip
# }

# output "vm_br_private_ip" {
#   value = google_compute_instance.vm_br.network_interface.0.network_ip
# }