#!/bin/bash

# Validate script is being run by sudo/root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit 1
fi

# Update with DNF
echo "[+] Update OS via DNF"
dnf -y update

# Install DNF Groups
echo "[+] Install/upgrade DNF Groups"
dnf -y group install "Window Managers"
dnf -y group install "Sound and Video"

# Install Dependent Applications with DNF
echo "[+] Install/upgrade DNF dependencies"
dnf -y install git \
    vim \
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
    httpd-tools \
    direnv \
    age \
    perl-Digest-SHA \
    jq \
    dnf-plugins-core \
    golang \
    sddm \
    unzip \
    wget
# Configure Desktop
echo "[+] Configure Desktop Environment"
systemctl enable sddm
systemctl set-default graphical.target
mkdir ~/.config
pushd ~/
cp ~/Projects/fedora-setup/bg.jpg ~/.config
cp -r ~/Projects/fedora-setup/dotconfig/* ~/.config
cp -r ~/Projects/fedora-setup/dotconfig/* ~/.config
echo "[+] Install/upgrade Desktop Packages"
dnf -y install bspwm \
    dconf-editor \
    kitty \
    picom \
    polybar \
    rofi \
    sxhkd \
    thunar \
    nitrogen \
    fontawesome-fonts \
    fontawesome-fonts-web \
    firefox \
    autorandr
cp ~/Projects/fedora-setup/.xinitrc ~/
cp ~/Projects/fedora-setup/.Xnord ~/
cp ~/Projects/fedora-setup/.Xresources ~/
cp ~/Projects/fedora-setup/.bashrc ~/
cp -r ~/Projects/fedora-setup/.bashrc.d/ ~/
cp ~/Projects/fedora-setup/.bash_profile ~/
pushd ~/Projects/fedora-setup/rpm-packages/
dnf -y install ocs-url-3.1.0-1.fc20.x86_64.rpm 
pushd ~/
wget -O FiraCode.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/FiraCode.zip
wget -O Meslo.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Meslo.zip
mkdir .fonts
unzip FiraCode.zip -d .fonts/
unzip Meslo.zip -d .fonts/
chown -R zimmermanc:zimmermanc ~/

# Install Terraform
echo "[+] Install/upgrade Terraform"
dnf config-manager --add-repo https://rpm.releases.hashicorp.com/fedora/hashicorp.repo
dnf -y install terraform
# Install Flux
echo "[+] Install/upgrade Flux"
curl -s https://fluxcd.io/install.sh | bash
# Install Task
echo "[+] Install/upgrade Tasks"
sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b /usr/bin
# Install IPCalc
echo "[+] Install IPCalc"
wget https://jodies.de/ipcalc-archive/ipcalc-0.41/ipcalc -P /usr/bin/
# Install Kubectl
echo "[+] Install/upgrade Kubectl"
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
install -o root -g root -m 0755 kubectl /usr/bin/kubectl
rm -rf kubectl*
# Install Mozilla SOPS
echo "[+] Install/upgrade SOPS"
SOPS_VERSION=$(curl -s https://api.github.com/repos/mozilla/sops/releases/latest | jq .tag_name | tr -d '"')
dnf install -y https://github.com/mozilla/sops/releases/download/${SOPS_VERSION}/sops-${SOPS_VERSION}-1.x86_64.rpm
sops --version
# Install Helm
echo "[+] Install/upgrade Helm"
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
rm -rf get_helm.sh
# Install Kustomize
echo "[+] Install/upgrade Kustomize"
curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash
mv kustomize /usr/bin/
# Install Pre-commit
echo "[+] Install/upgrade pre-commit"
pip3 install pre-commit
# Install Gitleaks
echo "[+] Install/upgrade gitleaks"
GITLEAKS_VERSION=$(curl -s https://api.github.com/repos/zricethezav/gitleaks/releases/latest | jq .tag_name | tr -d '"' | tr -d 'v')
wget -q https://github.com/zricethezav/gitleaks/releases/download/v${GITLEAKS_VERSION}/gitleaks_${GITLEAKS_VERSION}_linux_x64.tar.gz
tar xzf gitleaks_${GITLEAKS_VERSION}_linux_x64.tar.gz -C /usr/bin/
rm -rf gitleaks_${GITLEAKS_VERSION}_linux_x64.tar.gz 

# # Create ARA Container
# echo "[+] Install/upgrade ARA Container"
# podman volume create ara_server
# podman run --name ara_server --detach --tty \
#   --volume ara_server:/opt/ara:z -p 8000:8000 \
#   --env "ARA_TIME_ZONE=America/Denver" \
#   docker.io/recordsansible/ara-api:latest
# podman generate systemd --new --name ara_server --restart-policy=always > /etc/systemd/system/container-ara_server.service
# systemctl daemon-reload
# systemctl enable --now container-ara_server.service

# # Configure Ansible to utilize ARA Plugins
# echo "[+] Configure ARA Plugin within ansible.cfg"
# ansible-config init --disabled -t all > /etc/ansible/ansible.cfg
# ARA_CALLBACK="$(python3 -m ara.setup.callback_plugins)"
# ARA_ACTION="$(python3 -m ara.setup.action_plugins)"
# ARA_LOOKUP="$(python3 -m ara.setup.lookup_plugins)"
# sed -i -E "s|;callback_plugins(.*)|callback_plugins\1:$ARA_CALLBACK|g" /etc/ansible/ansible.cfg
# sed -i -E "s|;action_plugins(.*)|action_plugins\1:$ARA_ACTION|g" /etc/ansible/ansible.cfg
# sed -i -E "s|;lookup_plugins(.*)|lookup_plugins\1:$ARA_LOOKUP|g" /etc/ansible/ansible.cfg
# sed -i -E "s|;callbacks_enabled.*|callbacks_enabled=profile_tasks, ara_default|g" /etc/ansible/ansible.cfg
# sed -i -E "s|;bin_ansible_callbacks=False|bin_ansible_callbacks=True|g" /etc/ansible/ansible.cfg
# echo "
# [ara]
# api_client=http
# api_server=http://127.0.0.1:8000
# api_timeout=15
# callback_threads=0
# argument_labels=check,tags,subset
# default_labels=prod,deploy
# ignored_arguments=extra_vars,vault_password_files
# localhost_as_hostname=true
# localhost_as_hostname_format=fqdn" >> /etc/ansible/ansible.cfg

exit 0