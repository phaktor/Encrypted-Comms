# MatrixDeployer
Hello! This repository is intended to setup an encrypted Matrix/Riot/Jitsi communication environment.

## Prerequisites:
* Download Terraform and install it
* Download the Matrix Server code and adjust to your domains
* Make sure you are signed up for an AWS account
* Obtain or create a new IAM Access Code
* Create a DNS entry for www, matrix, riot and jitsi - then wait about 15 minutes before starting the script

## Steps:
1) First we will setup the infrastructure which will be independent from our bash scripts. To achieve this, first create a file called "secret-variables.auto.tfvars" in the project folder and enter the below lines.
```
        aws_access_key_id = "your_access_key_id_here"
        aws_secret_access_key = "your_secret_access_key_here"
```

2) Now run the below command to start the installation of the infrastructure. These terraform codes will launch an Amazon EC2 instance with Linux in it. It will also adjust the firewall rules accordingly to set the communication between tools.
```
        terraform init
        terraform apply 
        #then type "yes" as input
```
3) Setup your domain to point to the Amazon EC2 instance and wait for it to register before proceeding.

4) After our infrastructure is created successfully, we will start the first script which will build the Nginx server, LetsEncrypt and certbot for HTTPS access. We will need to connect to the EC2 instance and perform all of the following steps with "root" user. Type "sudo su" to switch to root user before starting.
```
        - First update the OS: "sudo apt -y update && sudo apt -y upgrade"
        - Install Nginx: "apt -y install nginx"
        - Copy the below virtual host information to the /etc/nginx/sites-enabled directory and save/configure for each dns entry: matrix.example.com, riot.example.com and example.com (add both www and without it). Rename server_name and point root to dns directory (example.com will also have www.example.com). For matrix, replace the location block with "proxy_pass http://localhost:8008;" and on a new line "proxy_set_header X-Forwarded-For $remote_addr;"
        
        
        
# Virtual Host configuration for example.com
#
# You can move that to a different file under sites-available/ and symlink that
# to sites-enabled/ to enable it.
#
server {
       listen 80;
       listen [::]:80;

       server_name example.com;

       root /var/www/example.com;
       index index.html;

       location / {
               try_files $uri $uri/ =404;
       }
}        
 
              
        
        - Perform the following to install certbot for domains above and select option 2 for Redirect at the end: 

sudo apt-get -y install software-properties-common
sudo add-apt-repository universe
sudo add-apt-repository ppa:certbot/certbot
sudo apt-get -y update
sudo apt-get -y install certbot python-certbot-nginx

certbot --nginx -d example.com -d riot.example.com -d matrix.example.com
```

5) On the first installation, you will have a registration form to start with - enter your email and answer Agree to Terms and Yes to IP Address log (required). Automated discovery should work if set up correctly.

6) Install Matrix synapse.
```
        - Type: "vi matrix.sh"
        - Insert the content from the matrix file under Scripts.
        - Run the script
        
        - Edit the homeserver.yaml file at /etc/matrix-synapse/homeserver.yaml to enable registration and restart the synapse server "systemctl restart matrix-synapse"
``` 

7) The next step is to create a cron job script to renew the Lets Encrypt cert. Add the following text in the script:
```
        "sudo vi /etc/cron.daily/letsencrypt-renew"

#!/bin/sh
if certbot renew > /var/log/letsencrypt/renew.log 2>&1 ; then
    nginx -s reload
fi
exit
        
        "sudo chmod +x /etc/cron.daily/letsencrypt-renew"
        "sudo crontab -e"
            - Add "01 02,14 * * * /etc/cron.daily/letsencrypt-renew"
            - Then save and exit
```

8) Install Riot client.
```
        - Type: "vi riot.sh"
        - Insert the content from the riot file under Scripts.
        - Run the script
        
        - Then tweak the config.json to change the base_url of the homeserver to be https://matrix.example.com and change the server_name to be example.com.
```

9) Install Jitsi client.
```
        - Type: "vi jitsi.sh"
        - Insert the content from the jitsi file under Scripts.
        - Run the script
        
        - Give the installer a hostname of jitsi.example.com
```

10) To add jitsi to the riot application, edit the config.json at /var/www/riot.example.com/riot/config.json and change the preferredDomain of the jitsi block to your domain.


11) Sign in from the Riot app on the server or the mobile client, connecting to the Matrix on the server. You can create a jitsi meeting from the site or through riot.

## Clean Up:
When finished with the server and wanting to clean up AWS, send the command within terminal: 
```
terraform destroy
```