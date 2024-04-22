Script for automating the process of TLS certificate issuance using Let's Encrypt. The script simplifies the process by allowing users to provide their domain's DNS A record, assuming NGINX is already configured on the server.

Instructions for use:

#Clone the repository:
git clone https://github.com/Beast1610/certbot_auto.git

#Navigate to the directory:
cd certbot_auto

#Provide permission for execution
chmod +x certbot_auto.sh

#Run the script and follow the prompts:
./script.sh
