output "alb_dns_name" {
  description = "DNS name of the application load balancer"
  value       = module.alb.alb_dns_name
}

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = module.compute.instance_id
}

output "instance_private_ip" {
  description = "Private IP of the EC2 instance"
  value       = module.compute.instance_private_ip
}

output "ssm_connect_command" {
  description = "Example AWS SSM connect command"
  value       = "aws ssm start-session --target ${module.compute.instance_id}"
}
