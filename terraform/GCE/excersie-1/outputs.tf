output "instance_public_ip" {
  description = "The public External IP address of the GCE instance"
  value       = google_compute_instance.vm.network_interface[0].access_config[0].nat_ip
}

output "website_url" {
  description = "The URL to access the Nginx web server"
  value       = "http://${google_compute_instance.vm.network_interface[0].access_config[0].nat_ip}"
}

output "instance_name" {
  description = "The name of the created GCE instance"
  value       = google_compute_instance.vm.name
}