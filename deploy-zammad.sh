#!/bin/bash

# Reference "https://github.com/zammad/zammad-helm/blob/main/zammad/README.md"

microk8s helm repo add zammad https://zammad.github.io/zammad-helm
microk8s helm upgrade --install zammad zammad/zammad
