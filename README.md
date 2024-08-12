# **Deploy Zammad - Help Desk and Ticket System on Ubuntu Linux**
>This was tested on Ubuntu 24.04 LTS .\
After Installation, you can access your Zammad instance on the following URL: "**https://<Zammad_Server_IP>>**"

## Deploy Zammad using bash scripts.
First we need to run the script "rename-server.sh" to rename the linux server and add localhost entry to /etc/hosts
>Note: If you did not specify a hostname during the script execution, the default value of "**zammad01.home.local**" will be used.
```
1. mkdir -p /zammadSource && cd /zammadSource
2. Save the script to a file, e.g., rename-server.sh.
3. Make the script executable:
    chmod +x rename-server.sh
4. Run the script with the new hostname as an argument:
    sudo ./rename-server.sh <new_fqdn>
    Replace <new_fqdn> with the desired hostname and domain name for your server.
5. Restart the server with "reboot" command to apply the new hostname. 
```

Next, run the script "install-zammad.sh" to start deploying zammad and its dependencies.
>Note: If you did not specify a username and password during the script execution, the default values of user ***"admin"*** & password ***"P@ssword1!"*** will be used.
```
1. Copy the script "install-zammad.sh" to the directory /k8sSource.
2. Make the script executable:
    chmod +x install-zammad.sh
3. Run the script following the below syntax:
    sudo ./install-zammad.sh <admin-username> <password>
```