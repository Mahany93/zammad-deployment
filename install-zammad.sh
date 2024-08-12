#!/bin/bash

es_user=${1:-admin}
es_password=${2:-P@ssword1!}

# Update /etc/hostname
  echo "Installing Zammad Dependencies".
  apt install -y libimlib2
  apt install -y curl apt-transport-https gnupg


# Install Elasticsearch
  yes '' | sed 5q
  echo "Installing Elasticsearch"
  apt install -y apt-transport-https sudo wget curl gnupg
  echo "deb [signed-by=/etc/apt/trusted.gpg.d/elasticsearch.gpg] https://artifacts.elastic.co/packages/7.x/apt stable main"| \
    tee -a /etc/apt/sources.list.d/elastic-7.x.list > /dev/null
  curl -fsSL https://artifacts.elastic.co/GPG-KEY-elasticsearch | \
    gpg --dearmor | tee /etc/apt/trusted.gpg.d/elasticsearch.gpg> /dev/null
  apt update -y
  apt install -y elasticsearch
  /usr/share/elasticsearch/bin/elasticsearch-plugin install -y ingest-attachment
  systemctl start elasticsearch.service

# Copy Elasticsearch config
  yes '' | sed 5q
  echo "Copying Elasticsearch Config YAML File"
  cp ./config/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml


# Ensure correct locale
  yes '' | sed 5q
  echo "Ensure the correct Locale is set"
  apt install -y locales
  locale-gen en_US.UTF-8
  echo "LANG=en_US.UTF-8" > /etc/default/locale


# Add Repository and install Zammad
  yes '' | sed 5q
  echo "Adding Zammad Repo"
  curl -fsSL https://dl.packager.io/srv/zammad/zammad/key | \
  gpg --dearmor | tee /etc/apt/trusted.gpg.d/pkgr-zammad.gpg> /dev/null
  echo "deb [signed-by=/etc/apt/trusted.gpg.d/pkgr-zammad.gpg] https://dl.packager.io/srv/deb/zammad/zammad/stable/ubuntu 24.04 main"| \
   tee /etc/apt/sources.list.d/zammad.list > /dev/null


# Install Zammad
  yes '' | sed 5q
  echo "Installing Zammad"
  apt update
  apt install -y zammad


# Firewall
  yes '' | sed 5q
  echo "Applying firewall rules"
  ufw allow 80
  ufw allow 443
  ufw reload


# Ensure Services are Started and Enabled
  yes '' | sed 5q
  echo "Enabling Zammad Services"
  # Zammads internal puma server (relevant for displaying the web app)
  systemctl start zammad-web && systemctl enable zammad-web
  # Zammads background worker - relevant for all delayed- and background jobs
  systemctl start zammad-worker && systemctl enable zammad-worker
  # Zammads websocket server for session related information
  systemctl start zammad-websocket && systemctl enable zammad-websocket
  # Zammad service to start all services at once
    systemctl start zammad && systemctl enable zammad


# Connect Zammad to Elasticsearch
  yes '' | sed 5q
  echo "Connecting Zammad to Elasticsearch"
  # Set the Elasticsearch server address
    zammad run rails r "Setting.set('es_user', '$es_user')"
    zammad run rails r "Setting.set('es_password', '$es_password')"
    zammad run rails r "Setting.set('es_url', 'http://localhost:9200')"
    zammad run rails r "Setting.set('es_ssl_verify', false)"

  # Build the search index
    zammad run rake zammad:searchindex:rebuild
    zammad run rails r "Setting.set('es_index', Socket.gethostname.downcase + '_zammad')"

# Configure the webserver
  yes '' | sed 5q
  echo "Configuring Nginx"
  #Prepare the configuration parameters
  hostfqdn=$(hostname)
  mkdir -p /certs && cd /certs
  openssl req -newkey rsa:4096 -nodes -x509 -days 1825 \
      -subj "/C=EG/ST=Cairo/L=Cairo/O=Service Desk/OU=IT Department/CN=$hostfqdn" -keyout key.pem -out certificate.pem
  cp /opt/zammad/contrib/nginx/zammad_ssl.conf /etc/nginx/sites-available/zammad.conf

  # Apply the nginx configuration
  sed -i "s/server_name example\.com;/server_name $hostfqdn;/g" /etc/nginx/sites-available/zammad.conf
  sed -i '/ssl_certificate .*/c\\  ssl_certificate /certs/certificate.pem;' /etc/nginx/sites-available/zammad.conf
  sed -i '/ssl_certificate_key .*/c\\  ssl_certificate_key /certs/key.pem;' /etc/nginx/sites-available/zammad.conf
  sed -i '/^ssl_dhparam /s/^/#/'  /etc/nginx/sites-available/zammad.conf
  sed -i '/^ssl_trusted_certificate /s/^/#/'  /etc/nginx/sites-available/zammad.conf
  systemctl reload nginx