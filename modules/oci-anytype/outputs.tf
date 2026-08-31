output "instance_public_ip" {
  description = "Public IP of the Anytype server"
  value       = oci_core_instance.anytype_server.public_ip
}

output "ssh_command" {
  description = "Command to SSH into the instance"
  value       = "ssh -i <your-private-key-path> ubuntu@${oci_core_instance.anytype_server.public_ip}"
}

output "client_config_fetch_command" {
  description = "Run this after cloud-init finishes (check /var/log/anytype-bootstrap-done.log on the VM first) to pull down the client config to import into Anytype apps"
  value       = "scp -i <your-private-key-path> ubuntu@${oci_core_instance.anytype_server.public_ip}:/opt/any-sync-bundle/data/client-config.yml ./client-config.yml"
}
