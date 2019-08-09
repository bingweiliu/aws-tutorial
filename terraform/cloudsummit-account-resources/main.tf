# general account settings
variable aws_region {}
variable aws_profile {}

variable instance_profile_name {}
variable external_role_arn {}

variable vpc_id  {}

# tags
variable application {}
variable environment {}
variable subnet {}
variable ec2_instance_type {}

variable ec2_tag_name {}
variable ec2_key_pair {}

provider "aws" {
  profile = "${var.aws_profile}"
  region = "us-east-1"
}

resource "aws_iam_instance_profile" "ec2-instance-profile" {
  name = "${var.instance_profile_name}"
  role = "${aws_iam_role.role.name}"
}

resource "aws_iam_role" "role" {
  name = "${var.instance_profile_name}"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow ssh inbound traffic"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}


data "aws_ami" "rhel" {
  most_recent      = true
  filter {
    name   = "name"
    values = ["RHEL-7.?*GA*"]
  }

  owners     = ["309956199498"]
}

resource "aws_instance" "ec2-instance" {
  ami           = "${data.aws_ami.rhel.id}"
  instance_type = "${var.ec2_instance_type}"

  root_block_device {
    volume_size = 20
  }

  vpc_security_group_ids  = [ "${aws_security_group.allow_ssh.id}"]
  iam_instance_profile = "${var.instance_profile_name}"

  subnet_id = "${var.subnet}"
  key_name = "${var.ec2_key_pair}"

  user_data = <<USERDATA
#!/bin/bash
yum install wget unzip git -y
cd /tmp
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh -b -p /opt/miniconda3
sed -i 's/pathmunge \/usr\/local\/sbin$/pathmunge \/usr\/local\/sbin\n    pathmunge \/opt\/miniconda3\/bin/g' /etc/profile
sed -i 's/pathmunge \/usr\/sbin after$/pathmunge \/usr\/sbin after\n    pathmunge \/opt\/miniconda3\/bin after/g' /etc/profile

wget https://releases.hashicorp.com/terraform/0.12.6/terraform_0.12.6_linux_amd64.zip
unzip terraform_0.12.6_linux_amd64.zip -d /usr/local/bin

export PATH=$PATH:/opt/miniconda3/bin
source activate base
conda install git -y
conda install -c conda-forge awscli boto3 -y
conda install -c conda-forge 

for i in `seq 30`
do
  username=user$i
  useradd $username
  pw=`openssl rand -base64 6`
  echo -e "$pw\n$pw" | passwd $username
  echo "$username,$pw" >> /root/user_pass.txt
done

sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
systemctl restart sshd
USERDATA

  tags = {
    Name = "${var.ec2_tag_name}"
    Environment = "${var.environment}"
    Application = "${var.application}"
  }
}
