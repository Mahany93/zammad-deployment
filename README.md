# **Deploy Zammad - Help Desk and Ticket System on K8s Cluster**
>This was tested on Rocky Linux v9.4 .

## Deploy Zammad using bash scripts.
First we need to run the script "rename-server.sh" to rename the linux server and add localhost entry to /etc/hosts

```
1. mkdir /zammadSource && cd /zammadSource
2. Save the script to a file, e.g., rename-server.sh.
3. Make the script executable:
    chmod +x rename-server.sh
4. Run the script with the new hostname as an argument:
    sudo ./rename-server.sh <new_fqdn>
    Replace <new_fqdn> with the desired hostname and domain name for your server.
5. Restart the server with "reboot" command to apply the new hostname. 
```

Then we have to run the script "install-microK8s.sh" to install snapd, microK8s and apply new SELinux settings.
```
1. Save the script to a file, e.g., install-microK8s.sh.
2. Make the script executable:
    chmod +x install-microK8s.sh
3. Run the script:
    sudo ./install-microK8s.sh
4. Restart the server with "reboot" command.
5. Run the below commands to confirm that Microk8s is working as expected.
    microk8s status
    microk8s kubectl get nodes
```
===========================================================================

The below steps will configure the K8s cluster and deploy zammad using manual method. 
## Rename the server and update /etc/hosts file

```
1. Rename the server to zammad01
    hostnamectl set-hostname zammad01
    echo "zammad01" > /etc/hostname
3. Update /etc/hosts
    sed -i "s/127\.0\.1\.1.*/127.0.1.1 zammad01/" /etc/hosts
4. Restart the server with "reboot" command to apply the new hostname. 
```
---
## Install Snapd
Microk8s is a snap package and so snapd is required on the Rocky Linux 9 system.
The below commands can be used to install snapd on Rocky Linux 9.
```
1.  Enable the EPEL repository.
    sudo dnf install -y epel-release

2.  Install snapd.
    sudo dnf install -y snapd

3.  create a symbolic link for classic snap support.
    sudo ln -s /var/lib/snapd/snap /snap

4.  Export the snaps $PATH.
    echo 'export PATH=$PATH:/var/lib/snapd/snap/bin' | sudo tee -a /etc/profile.d/snap.sh
    source /etc/profile.d/snap.sh

5.  Start and enable the service.
    sudo systemctl enable --now snapd.socket

6.  Set SELinux in permissive mode.
    sudo setenforce 0
    sudo sed -i 's/^SELINUX=.*/SELINUX=permissive/g' /etc/selinux/config
```
---

## Install Microk8s
```
1.  Install Microk8s package.
    sudo snap install -y microk8s --classic 

2.  Set the below permissions.
    sudo usermod -a -G microk8s $USER
    sudo chown -f -R $USER ~/.kube

3.  Apply the changes.
    newgrp microk8s
    microk8s status

4.  Get the available nodes.
    microk8s kubectl get nodes
```
