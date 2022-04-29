# Fedora Setup

## Build a Fedora VM

### Command to create a LibVirt Fedora 36 VM
- Using VNC as the graphical connection & the OSTree to NetBoot
```
virt-install --name fedora-36-test \
    --ram 8192 \
    --arch x86_64 \
    --os-variant fedora-unknown \
    --boot uefi \
    --disk size=50 \
    --graphics vnc,listen=0.0.0.0 --noautoconsole \
    --location https://iad.mirror.rackspace.com/fedora/releases/test/36_Beta/Server/x86_64/os/
  ```

### OS Installation
- Set the Timezone
- Set the Network including Hostname
- Select the installation type
- Configure partitioning
- Create a user
- Set root password (if wanted)
- Initial installation
- Reboot

### OS Setup
- Copy SSH Key in place
- `sudo dnf -y update`
- `sudo dnf -y install git ansible-core ansible-collection-ansible-posix ansible-collection-ansible-utils ansible-collection-community-general`
- `mkdir ~/Projects && cd ~/Projects && git clone git@github.com:PrymalInstynct/fedora-setup.git`
- `cd ~/Projects/fedora-setup`
- `sudo ./init.sh`