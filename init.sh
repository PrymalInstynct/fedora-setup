#!/bin/bash
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit 1
fi

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
    podman

# podman volume create ara

# podman run --name ara --detach --tty \
#   --volume ara:/opt/ara:z -p 8000:8000 \
#   docker.io/recordsansible/ara-api:latest

# podman generate systemd --new --name ara --restart-policy=always > /etc/systemd/system/container-ara.service

# systemctl daemon-reload

# systemctl enable --now container-ara.service

# echo "# Configure Ansible to use the ARA callback plugin
# ANSIBLE_CALLBACK_PLUGINS="$(python3 -m ara.setup.callback_plugins)"

# # Set up the ARA callback to know where the API server is located
# ARA_API_CLIENT="http"
# ARA_API_SERVER="http://127.0.0.1:8000"" >> /etc/environment

ansible-config init --disabled -t all > /etc/ansible/ansible.cfg

ARA_CALLBACK="$(python3 -m ara.setup.callback_plugins)"
ARA_ACTION="$(python3 -m ara.setup.action_plugins)"
ARA_LOOKUP="$(python3 -m ara.setup.lookup_plugins)"

sed -i -E "s|;callback_plugins(.*)|callback_plugins\1:$ARA_CALLBACK|g" /etc/ansible/ansible.cfg
sed -i -E "s|;action_plugins(.*)|action_plugins\1:$ARA_ACTION|g" /etc/ansible/ansible.cfg
sed -i -E "s|;lookup_plugins(.*)|lookup_plugins\1:$ARA_LOOKUP|g" /etc/ansible/ansible.cfg

sed -i -E "s|;callbacks_enabled.*|callbacks_enabled=profile_tasks, ara_default|g" /etc/ansible/ansible.cfg
sed -i -E "s|;bin_ansible_callbacks=False|bin_ansible_callbacks=True|g" /etc/ansible/ansible.cfg

# sed -i -E "s|;api_client=.*|api_client=http|g" /etc/ansible/ansible.cfg
# sed -i -E "s|;api_server=.*|api_server=http://127.0.0.1:8000|g" /etc/ansible/ansible.cfg
# sed -i -E "s|;api_timeout=False|api_timeout=15|g" /etc/ansible/ansible.cfg
# sed -i -E "s|;callback_threads=.*|callback_threads=4|g" /etc/ansible/ansible.cfg
# sed -i -E "s|;argument_labels=.*|argument_labels=check,tags,subset|g" /etc/ansible/ansible.cfg
# sed -i -E "s|;default_labels=.*|default_labels=prod,deploy|g" /etc/ansible/ansible.cfg
# sed -i -E "s|;ignored_arguments=.*|ignored_arguments=extra_vars,vault_password_files|g" /etc/ansible/ansible.cfg
# sed -i -E "s|;localhost_as_hostname=.*|localhost_as_hostname=true|g" /etc/ansible/ansible.cfg
# sed -i -E "s|;localhost_as_hostname_format=.*|localhost_as_hostname_format=fqdn|g" /etc/ansible/ansible.cfg

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