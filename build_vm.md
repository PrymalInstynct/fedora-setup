# Build a Fedora VM

### Command to create a Fedora 36 VM that will use the OSTree for install
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
