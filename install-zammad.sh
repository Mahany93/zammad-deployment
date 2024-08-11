#!/bin/bash

es_user=${1:-admin}
es_password=${2:-P@ssword1!}

# Update /etc/hostname
echo "Installing Zammad Dependencies".
apt install libimlib2
apt install curl apt-transport-https gnupg


# Install Elasticsearch
  apt install apt-transport-https sudo wget curl gnupg
  echo "deb [signed-by=/etc/apt/trusted.gpg.d/elasticsearch.gpg] https://artifacts.elastic.co/packages/7.x/apt stable main"| \
    tee -a /etc/apt/sources.list.d/elastic-7.x.list > /dev/null
  curl -fsSL https://artifacts.elastic.co/GPG-KEY-elasticsearch | \
    gpg --dearmor | tee /etc/apt/trusted.gpg.d/elasticsearch.gpg> /dev/null
  apt update
  apt install elasticsearch
  /usr/share/elasticsearch/bin/elasticsearch-plugin install ingest-attachment


# Copy Elasticsearch config
  cp ./config/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml


# Ensure correct locale
  apt install locales
  locale-gen en_US.UTF-8
  echo "LANG=en_US.UTF-8" > /etc/default/locale


# Add Repository and install Zammad
  curl -fsSL https://dl.packager.io/srv/zammad/zammad/key | \
  gpg --dearmor | tee /etc/apt/trusted.gpg.d/pkgr-zammad.gpg> /dev/null
  echo "deb [signed-by=/etc/apt/trusted.gpg.d/pkgr-zammad.gpg] https://dl.packager.io/srv/deb/zammad/zammad/stable/ubuntu 24.04 main"| \
   tee /etc/apt/sources.list.d/zammad.list > /dev/null


# Install Zammad
  apt update
  apt install zammad


# Firewall
  ufw allow 80
  ufw allow 443
  ufw reload


# Ensure Services are Started and Enabled
  # Zammads internal puma server (relevant for displaying the web app)
  systemctl start zammad-web && systemctl enable zammad-web

  # Zammads background worker - relevant for all delayed- and background jobs
  systemctl start zammad-worker && systemctl enable zammad-worker

  # Zammads websocket server for session related information
  systemctl start zammad-websocket && systemctl enable zammad-websocket

  # Zammad service to start all services at once
    systemctl start zammad && systemctl enable zammad


# Connect Zammad to Elasticsearch
  # Set the Elasticsearch server address
    zammad run rails r "Setting.set('es_user', '$es_user')"
    zammad run rails r "Setting.set('es_password', '$es_password')"
    zammad run rails r "Setting.set('es_url', 'http://localhost:9200')"
    zammad run rails r "Setting.set('es_ssl_verify', false)"

  # Build the search index
    zammad run rake zammad:searchindex:rebuild
    zammad run rails r "Setting.set('es_index', Socket.gethostname.downcase + '_zammad')"

