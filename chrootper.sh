ln -sf /usr/share/zoneinfo/America/Lima /etc/localtime
hwclock --systohc

idioma="es_PE.UTF-8"
clear
echo ""
echo "Sistema en español"
echo ""
echo \"$idioma UTF-8\" > /etc/locale.gen
vim /etc/locale.gen
locale-gen
echo \"LANG=$idioma\" > /etc/locale.conf
vim /etc/locale.conf
echo \"es\" > /etc/vconsole.conf
vim /etc/vconsole.conf
echo ""
sleep 3

#hosts
clear
#NOmbre de computador
hostname=archusb
(echo '$hostname') > /etc/hostname
vim /etc/hostname
(echo '127.0.0.1 localhost') >> /etc/hosts
(echo '::1 localhost') >> /etc/hosts
(echo '127.0.1.1 $hostname.localdomain $hostname')>> /etc/hosts
vim /etc/hosts

clear
echo "Hostname: $(cat /mnt/etc/hostname)"
echo ""
echo "Hosts: $(cat /mnt/etc/hosts)"
echo ""
clear

sleep 3
clear

#USUARIO Y ADMIN

(echo $rootpasswd ; echo $rootpasswd) | passwd root

#Instalación del kernel
pacman -S grub efibootmgr networkmanager network-manager-applet mtools dosfstools reflector git base-devel linux-headers pulseaudio bluez bluez-utils cups xdg-utils xdg-user-dirs --noconfirm

#cambiar los hooks
echo"Cambie el orden de los hooks de block y keyboard despues de udev"
sleep 4
vim /etc/mkinitcpio.conf
mkinitcpio -p linux
#instalar el grub

grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB --removable --recheck
grub-mkconfig -o /boot/grub/grub.cfg

#ACTIVAR SERVICIOS
systemctl enable NetworkManager
systemctl enable bluetooth
systemctl enable cups

useradd -mG wheel $user
(echo $userpasswd ; echo $userpasswd) | passwd $user
echo"descomentar el wheel all"
sleep 2
EDITOR=vim visudo

clear
exit
umount -a
reboot
