y#!/bin/sh

echo "Modifying the Sudoers file"

sudo apt update
sudo apt install nginx -y

######################
# STATIC WEB PAGE
######################

sudo mkdir /var/www/demo -p
#sudo chmod 0755  /etc/nginx/www/demo
sudo tee -a /var/www/demo/index.html > /dev/null <<'EOF'
<!doctype html>
<html>
<head>
    <meta charset="utf-8">
    <title>Hello, Nginx!</title>
</head>
<body>
    <h1>Hello, Nginx!</h1>
    <p>
      This webpage is part of a lab and is served through Nginx web server on Ubuntu Server!
    </p>
</body>
</html>
EOF
#chmod 0755  /etc/nginx/www
#chmod 644 /etc/nginx/www/demo/index.html
echo "index webpage created "  >> /tmp/debug.log

mkdir /etc/nginx/sites-enabled -p
sudo rm /etc/nginx/sites-enabled/default
sudo tee -a /etc/nginx/sites-enabled/demo > /dev/null <<'EOF'
server {
       listen 80;
       listen [::]:80;

       server_name example.ubuntu.com;

       root /var/www/demo;
       index index.html;

       location / {
               try_files $uri $uri/ =404;
       }
}
EOF

sudo service nginx restart

sudo rm /etc/sudoers.d/aad_admins
echo '%aad_admins ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/aad_admins

