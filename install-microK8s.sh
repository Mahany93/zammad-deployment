#!/bin/bash

# Enable the EPEL repository.
    sudo dnf install -y epel-release

# Install snapd.
    sudo dnf install -y snapd

# create a symbolic link for classic snap support.
    sudo ln -s /var/lib/snapd/snap /snap

# Export the snaps $PATH.
    echo 'export PATH=$PATH:/var/lib/snapd/snap/bin' | sudo tee -a /etc/profile.d/snap.sh
    source /etc/profile.d/snap.sh

# Start and enable the service.
    sudo systemctl start snapd.socket
    sudo systemctl enable --now snapd.socket

# Set SELinux in permissive mode.
    echo 'Applying SELinux settings'
    sudo setenforce 0
    sudo sed -i 's/^SELINUX=.*/SELINUX=permissive/g' /etc/selinux/config

# Wait to snapd service to load correctly to avoid device not yet seeded error
    systemctl restart snapd.seeded.service
    echo 'Waiting to snapd service to load. Sleeping for 1 minute'
    sleep 1m

# Install Microk8s package.
    echo 'Installing Microk8s'
    sudo snap install microk8s --classic --channel=1.29/stable

# Set the below permissions.
    sudo usermod -a -G microk8s $USER
    sudo chown -f -R $USER ~/.kube

# Apply the changes.
    newgrp microk8s
    microk8s enable hostpath-storage
    
echo "Please reboot the system to apply the changes.

# Restart Microk8s services
    echo 'restarting Microk8s services'
    microk8s stop
    microk8s start

# Get the available nodes.
    microk8s kubectl get nodes
