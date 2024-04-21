#!/bin/bash

# Function to install required packages
function install_packages {
    # Check if certbot is installed
    if ! command -v certbot &> /dev/null; then
        echo "Installing certbot..."
        sudo apt-get update
        sudo apt-get install certbot -y
    fi

    # Check if python3-certbot-nginx is installed
    if ! dpkg -s python3-certbot-nginx &> /dev/null; then
        echo "Installing python3-certbot-nginx..."
        sudo apt-get update
        sudo apt-get install python3-certbot-nginx -y
    fi

    # Check if python3-certbot-apache is installed
    if ! dpkg -s python3-certbot-apache &> /dev/null; then
        echo "Installing python3-certbot-apache..."
        sudo apt-get update
        sudo apt-get install python3-certbot-apache -y
    fi
}

# Function to issue or renew SSL/TLS certificates
function issue_or_renew_certificate {
    DOMAIN=$1

    # Check if certificate exists for the domain
    CERT_FILE="/etc/letsencrypt/live/$DOMAIN/fullchain.pem"
    if [ -f "$CERT_FILE" ]; then
        echo "Certificate already exists for $DOMAIN."
        # Check certificate expiration
        check_certificate_expiration "$DOMAIN"
    else
        echo "Issuing certificate for $DOMAIN..."
        # Issue certificate using Certbot
        sudo certbot certonly --nginx -d "$DOMAIN"
        # Check if certificate issuance was successful
        if [ $? -eq 0 ]; then
            echo "Certificate issued successfully for $DOMAIN."
        else
            echo "Failed to issue certificate for $DOMAIN."
            exit 1
        fi
    fi
}

# Function to check certificate expiration
function check_certificate_expiration {
    DOMAIN=$1

    # Calculate days until certificate expiration
    EXP_LIMIT=30 # Expiration limit in days
    DATE_NOW=$(date +%s)
    EXP_DATE=$(date -d "`openssl x509 -in /etc/letsencrypt/live/$DOMAIN/fullchain.pem -text -noout | grep 'Not After' | cut -d':' -f2-`" +%s)
    EXP_DAYS=$(( ($EXP_DATE - $DATE_NOW) / 86400 ))

    # Check if certificate expiration is within the limit
    if [ $EXP_DAYS -le $EXP_LIMIT ]; then
        echo "Certificate for $DOMAIN is about to expire in $EXP_DAYS days. Renewing..."
        renew_certificate "$DOMAIN"
    else
        echo "Certificate for $DOMAIN is up to date. Expiration in $EXP_DAYS days."
    fi
}

# Function to renew certificate
function renew_certificate {
    DOMAIN=$1

    # Renew certificate using Certbot
    sudo certbot renew --nginx
    # Check if renewal was successful
    if [ $? -eq 0 ]; then
        echo "Certificate renewed successfully for $DOMAIN."
    else
        echo "Failed to renew certificate for $DOMAIN."
        exit 1
    fi
}

# Main script

# Install required packages
install_packages

# Prompt user to enter domain name
read -p "Enter your domain name: " DOMAIN_NAME

# Issue or renew certificate
issue_or_renew_certificate "$DOMAIN_NAME"

