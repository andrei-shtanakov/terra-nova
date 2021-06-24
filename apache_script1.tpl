#!/bin/bash
apt update -y
apt install apache2 -y
apt install php libapache2-mod-php php-mysql -y
apt install mysql-client-core-8.0 -y




sudo systemctl start httpd.service
sudo systemctl enable httpd.service
sudo systemctl status httpd.service


sudo mkdir /var/www/wordpress
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${fs_name}.efs.eu-central-1.amazonaws.com:/ /var/www/wordpress


