#!/bin/bash

# Validate script is being run by sudo/root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit 1
fi

# Install Dependent Applications
dnf -y install git \
    ansible-core \
    ansible-collection-ansible-netcommon \
    ansible-collection-ansible-posix \
    ansible-collection-ansible-utils \
    ansible-collection-community-general \
    ansible-collection-containers-podman \
    ansible-freeipa \
    ansible-core-doc \
    python3-ansible-lint \
    yamllint \
    vim-ansible \
    vim-syntastic-ansible \
    ara \
    podman \
    httpd-tools

# Setup Password file for ARA Proxy Auth
# echo -e "\nSet Password for ARA admin\n"
# htpasswd -c -m ./.htpasswd admin

# Create ARA Pod
# podman volume create ara_server
# podman volume create ara_proxy
# podman pod create --name ara_pod -p 8000:80
# podman run --name ara_server --detach --tty --pod ara_pod \
#   --volume ara_server:/opt/ara:z \
#   --env "ARA_EXTERNAL_AUTH=true" \
#   docker.io/recordsansible/ara-api:latest
# podman run --name ara_proxy --detach --tty --pod ara_pod \
#   --volume ara_proxy:/etc/nginx:z \
#   docker.io/library/nginx:latest
# podman cp ara.conf ara_proxy:/etc/nginx/conf.d/ara.conf
# podman cp .htpasswd ara_proxy:/etc/nginx/.htpasswd
# podman generate systemd --new --name ara_pod --files --restart-policy=always
# mv *.service /etc/systemd/system/
# systemctl daemon-reload
# systemctl enable --now pod-ara_pod.service

# Create ARA Container
podman volume create ara_server
podman run --name ara_server --detach --tty \
  --volume ara_server:/opt/ara:z -p 8000:8000 \
  --env "ARA_TIME_ZONE=America/Denver" \
  docker.io/recordsansible/ara-api:latest

# Configure Ansible to utilize ARA Plugins
ansible-config init --disabled -t all > /etc/ansible/ansible.cfg
ARA_CALLBACK="$(python3 -m ara.setup.callback_plugins)"
ARA_ACTION="$(python3 -m ara.setup.action_plugins)"
ARA_LOOKUP="$(python3 -m ara.setup.lookup_plugins)"
sed -i -E "s|;callback_plugins(.*)|callback_plugins\1:$ARA_CALLBACK|g" /etc/ansible/ansible.cfg
sed -i -E "s|;action_plugins(.*)|action_plugins\1:$ARA_ACTION|g" /etc/ansible/ansible.cfg
sed -i -E "s|;lookup_plugins(.*)|lookup_plugins\1:$ARA_LOOKUP|g" /etc/ansible/ansible.cfg
sed -i -E "s|;callbacks_enabled.*|callbacks_enabled=profile_tasks, ara_default|g" /etc/ansible/ansible.cfg
sed -i -E "s|;bin_ansible_callbacks=False|bin_ansible_callbacks=True|g" /etc/ansible/ansible.cfg
echo "
[ara]
api_client=http
api_server=http://127.0.0.1:8000
api_timeout=15
callback_threads=0
argument_labels=check,tags,subset
default_labels=prod,deploy
ignored_arguments=extra_vars,vault_password_files
localhost_as_hostname=true
localhost_as_hostname_format=fqdn" >> /etc/ansible/ansible.cfg

exit 0