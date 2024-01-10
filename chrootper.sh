arch-chroot /mnt /bin/bash -c "ln -sf /usr/share/zoneinfo/America/Lima /etc/localtime"
arch-chroot /mnt /bin/bash -c "hwclock --systohc"

idioma="es_PE.UTF-8"
clear
echo ""
echo "Sistema en español"
echo ""
arch-chroot /mnt /bin/bash -c "echo \"$idioma UTF-8\" > /etc/locale.gen"
arch-chroot /mnt /bin/bash -c "vim /etc/locale.gen"
arch-chroot /mnt /bin/bash -c "locale-gen"
arch-chroot /mnt /bin/bash -c "echo \"LANG=$idioma\" > /etc/locale.conf"
arch-chroot /mnt /bin/bash -c "vim /etc/locale.conf"
arch-chroot /mnt /bin/bash -c "export LANG=$idioma"
arch-chroot /mnt /bin/bash -c "echo \"es\" > /etc/vconsole.conf"
arch-chroot /mnt /bin/bash -c "vim /etc/vconsole.conf"
echo ""
sleep 3

#hosts
clear
#NOmbre de computador
hostname=archusb
arch-chroot /mnt /bin/bash -c "(echo '$hostname') > /etc/hostname"
arch-chroot /mnt /bin/bash -c "vim /etc/hostname"
arch-chroot /mnt /bin/bash -c "(echo '127.0.0.1 localhost') >> /etc/hosts"
arch-chroot /mnt /bin/bash -c "(echo '::1 localhost') >> /etc/hosts"
arch-chroot /mnt /bin/bash -c "(echo '127.0.1.1 $hostname.localdomain $hostname')>> /etc/hosts"
arch-chroot /mnt /bin/bash -c "vim /etc/hosts"

clear
echo "Hostname: $(cat /mnt/etc/hostname)"
echo ""
echo "Hosts: $(cat /mnt/etc/hosts)"
echo ""
clear

sleep 3
clear

#USUARIO Y ADMIN

arch-chroot /mnt /bin/bash -c "(echo $rootpasswd ; echo $rootpasswd) | passwd root"

#Instalación del kernel
arch-chroot /mnt /bin/bash -c "pacman -S grub efibootmgr networkmanager network-manager-applet mtools dosfstools reflector git base-devel linux-headers pulseaudio bluez bluez-utils cups xdg-utils xdg-user-dirs --noconfirm"

#cambiar los hooks
echo"Cambie el orden de los hooks de block y keyboard despues de udev"
sleep 4
arch-chroot /mnt /bin/bash -c "vim /etc/mkinitcpio.conf"
arch-chroot /mnt /bin/bash -c "mkinitcpio -p linux"
#instalar el grub

arch-chroot /mnt /bin/bash -c "grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB --removable --recheck"
arch-chroot /mnt /bin/bash -c "grub-mkconfig -o /boot/grub/grub.cfg"


#ACTIVAR SERVICIOS
arch-chroot /mnt /bin/bash -c "systemctl enable NetworkManager"
arch-chroot /mnt /bin/bash -c "systemctl enable bluetooth"
arch-chroot /mnt /bin/bash -c "systemctl enable cups"


arch-chroot /mnt /bin/bash -c "useradd -mG wheel $user"
arch-chroot /mnt /bin/bash -c "(echo $userpasswd ; echo $userpasswd) | passwd $user"
echo"descomentar el wheel all"
sleep 2
arch-chroot /mnt /bin/bash -c "EDITOR=vim visudo"

clear

umount -a
poweroff
