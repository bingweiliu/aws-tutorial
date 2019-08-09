output "ami" {
  value = "${data.aws_ami.rhel.id}"
}

output "ec2_instance_id" {
  value = "${aws_instance.ec2-instance.id}"
}

output "ec2_instance_private_ip" {
  value = "${aws_instance.ec2-instance.private_ip}"
}

output "ec2_instance_pub_ip" {
  value = "${aws_instance.ec2-instance.public_ip}"
}

output "ec2_instance_key_name" {
  value = "${aws_instance.ec2-instance.key_name}"
}


output "sg-id"{
  value = "${aws_security_group.allow_ssh.id}"
}
