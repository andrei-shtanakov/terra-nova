#!/bin/bash
#!/bin/bash
yum -y update
yum -y install httpd

cat <<EOF > /var/www/html/index.html
<html>
<h2>Build by Power of Terraform <font color="red"> v0.12</font></h2><br>
Owner Abra Kadabra <br>
</html>
EOF


sudo systemctl start httpd.service
sudo systemctl enable httpd.service
sudo systemctl status httpd.service
