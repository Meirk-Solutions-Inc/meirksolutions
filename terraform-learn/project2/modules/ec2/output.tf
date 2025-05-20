output "ec2_instance_id" {
  value = aws_instance.try-app.id
}
output "ec2_instance_public_ip" {
  value = aws_instance.try-app.public_ip
  
}