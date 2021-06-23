#!/bin/bash
yum -y update
yum -y install httpd
yum -y install install php-mysqlnd php-fpm tar curl php-json mysql


cat <<EOF > /var/www/html/index.html
<html>
<h2>Build by Power of Terraform <font color="red"> v0.12</font></h2><br>
Owner ${f_name} ${l_name} <br>
</html>
EOF

cat <<EOF > mount.sh
#!/bin/bash
sudo mkdir /var/www/html/wordpress
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${fs_name}.efs.eu-central-1.amazonaws.com:/ /var/www/html/wordpress
EOF

chmod +x mount.sh

sudo systemctl start httpd.service
sudo systemctl enable httpd.service
sudo systemctl status httpd.service


sudo mkdir /var/www/html/wordpress
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${fs_name}.efs.eu-central-1.amazonaws.com:/ /var/www/html/wordpress



cat <<EOF > /etc/httpd/conf.d/wordpress.conf
<VirtualHost *:80>
ServerAdmin root@localhost
DocumentRoot "/var/www/html/wordpress/"

<Directory "/var/www/html/wordpress/">
        Options Indexes FollowSymLinks
        AllowOverride all
        Require all granted
</Directory>
ErrorLog /var/log/httpd/wordpress_error.log
CustomLog /var/log/httpd/wordpress_access.log common
</VirtualHost>
EOF
chown -R apache:apache /var/www/html

systemctl restart httpd

