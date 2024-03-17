# Booted into the archiso environment through Ventoy
  - check that cloud-init configured everything
    - Keyboard (press ä,ö,ü to check latin1 is working)
    - Pacman (pacman -Sy)
  - mount /dev/mapper/ventoy to /mnt
  - copy /mnt/wildcard-os to /root/wildcard-os

# Take some notes
  - block devices
    - lsblk is your friend here
    - remember the target: /dev/sdb or /dev/nvme0n1 or something else
    - do not erase your Ventoy!!
    - double check everything, otherwise you will take responsibility for data losses
  - where do you want your mountpoint for systemd-nspawn to execute everything
    - /var/lib/machines/archlinux could be a valid option
  - what system do you want to install to? Write down the taglist.
    - Host: target_host
    - Virtual Environment: target_guest
    - Container: target_nspawn
  - which flavour do you want to install? Write down the taglist
    - with encryption: encryption
    - dual boot preparation with windows: dualboot
      - install windows after linux, windows will find the correct partitions
      - reenable the boot partition in efi boot order as windows creates a temporary key
      - the linux files on the efi partition will be untouched by windows setup, so rest assured
      - after windows setup and efi correction the systemd-boot entry for windows boot should be displayed
    - server environment: bootstrap
    - graphical environment: bootstrap,graphical,cinnamon
    - archlinux as base: archlinux
    - ubuntu as base: ubuntu

# Let's get started
```
# ATTENTION!!! ONLY EXECUTE WHEN YOU ARE READY!!!
# !!!DATA LOSS!!!
dd if=/dev/zero of=/dev/nvme0n1 bs=1M count=16
cd /root/wildcard-os/install
./main.sh -d /dev/nvme0n1 -m /var/lib/machines/archlinux -v -t target_host,archlinux,encryption,bootstrap,graphical,cinnamon
```
