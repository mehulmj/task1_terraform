provider "aws"{
	profile="mehul1"
	region="ap-south-1"
}
//First launch or create an instance
resource "aws_instance" "instance1"{
	ami="ami-052c08d70def0ac62"
	instance_type="t2.micro"
	key_name="thirdKey"
	security_groups=["launch-wizard-5"]
	tags={
		Name="Mehul_OS1"
	}
}
//now we create a ebs volume
resource "aws_ebs_volume" "Mehul_ebs1" {
  availability_zone = aws_instance.instance1.availability_zone
  size              = 1

  tags = {
    Name = "Mehul_ebs1"
  }
}
//now we attach attach ebs volume to the instance
resource "aws_volume_attachment" "attach_ebs_mehulos" {
  device_name = "/dev/sdh"
  volume_id   = "${aws_ebs_volume.Mehul_ebs1.id}"
  instance_id = "${aws_instance.instance1.id}"
}
//Now we mount the volume
resource "null_resource" "nullremote3"  {

	depends_on = [
    			aws_volume_attachment.attach_ebs_mehulos,
  		]


	connection{
		type     = "ssh"
    		user     = "ec2-user"
    		private_key = file("C:/Users/Mehul Jain/Downloads/thirdkey.pem")
    		host     = aws_instance.instance1.public_ip
	}

	provisioner "remote-exec" {
    	inline = [
      		"sudo yum install httpd php python3 git -y",
      		"sudo systemctl restart httpd",
      		"sudo systemctl enable httpd",
      		"sudo mkfs.ext4  /dev/xvdh",
      		"sudo mount  /dev/xvdh  /var/www/html",
      		"sudo rm -rf /var/www/html/*",
      		"sudo git clone https://github.com/mehulmj/task1_terraform.git /var/www/html/"
    		]
 	}
}