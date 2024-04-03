#!/bin/bash

#para USB uefi

#Disco
cd ..
loadkeys la-latin
echo ""
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' _
echo "Rutas de Disco disponible: "
echo ""
echo "print devices" | parted | grep /dev/ | awk '{if (NR!=1) {print}}'
echo ""
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' _

# Ingresar Datos de usuario
read -p "Introduce tu disco a instalar Arch: " disco
echo ""
read -p "Introduce la clave de Administrador: " rootpasswd
echo ""
read -p "Introduce Nombre usuario Nuevo: " user
echo ""
read -p "Introduce la clave de $user: " userpasswd
echo ""

# Escritorio


# Mostrar datos guardados
clear
echo ''
echo "Selección de Disco: $disco"
echo ''
echo "Tu usuario: $user"
echo ''
echo "Clave de usuario: $userpasswd"
echo ''
echo "Clave de Administrador: $rootpasswd"
echo ''
sleep 4
echo ''

#Actualización de llaves y mirror list
clear
pacman -Syy reflector 
sleep 3
clear
echo ""
echo "Actualizando lista de MirrorList"
echo ""
reflector --verbose --latest 10 --sort rate --save /etc/pacman.d/mirrorlist
pacman -Syy
clear
cat /etc/pacman.d/mirrorlist
sleep 3
clear


uefi=$( ls /sys/firmware/efi/ | grep -ic efivars )

if [ $uefi == 1 ]
then
	clear
	echo "Sistema UEFI"
	echo ""
	#Fuente: https://wiki.archlinux.org/index.php/GPT_fdisk
	#Metodo con EFI - ROOT
	
	sgdisk --zap-all ${disco}
	parted ${disco} mklabel gpt
	sgdisk ${disco} -n=1:0:+300M -t=1:ef00
	sgdisk ${disco} -n=2:0:0
	fdisk -l ${disco} > /tmp/partition
	echo ""
	cat /tmp/partition
	sleep 3

	partition="$(cat /tmp/partition | grep /dev/ | awk '{if (NR!=1) {print}}' | sed 's/*//g' | awk -F ' ' '{print $1}')"

	echo $partition | awk -F ' ' '{print $1}' >  boot-efi
	echo $partition | awk -F ' ' '{print $2}' >  root-efi

	echo ""
	echo "Partición EFI es:" 
	cat boot-efi
	echo ""
	echo "Partición ROOT es:"
	cat root-efi
	echo ""

	sleep 3

	clear
	echo ""
	echo "Formateando Particiones"
	echo ""
	sleep 4
	mkfs.fat -F32 $(cat boot-efi) 
	mkfs.ext4 -O "^has_journal" $(cat root-efi) 
 	
	mount $(cat root-efi) /mnt 
	mkdir -p /mnt/boot/efi 
	mount $(cat boot-efi) /mnt/boot/efi 
	sleep 4

	clear
	echo ""
	echo "Revise en punto de montaje en MOUNTPOINT"
	echo ""
	lsblk 
	sleep 4
else
	echo "No support for BIOS"
fi






echo ""
echo "Instalando Sistema base con vim"
echo ""
pacman -S archlinux-keyring
pacstrap /mnt base linux linux-firmware vim
sleep 4
echo ""
echo "Archivo FSTAB"
echo ""
echo ""

genfstab -U /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab
sleep 4
clear
sleep 4
#Horario idioma

arch-chroot /mnt

sleep 4

arch-chroot /mnt /bin/bash -c ln -sf /usr/share/zoneinfo/America/Lima /etc/localtime
arch-chroot /mnt /bin/bash -c hwclock --systohc

idioma="es_PE.UTF-8"
arch-chroot /mnt /bin/bash -c clear
arch-chroot /mnt /bin/bash -c echo ""
arch-chroot /mnt /bin/bash -c echo "Sistema en español"
arch-chroot /mnt /bin/bash -c echo ""
arch-chroot /mnt /bin/bash -c vim /etc/locale.gen
arch-chroot /mnt /bin/bash -c locale-gen
arch-chroot /mnt /bin/bash -c echo \"LANG=es_PE.UTF-8\" > /etc/locale.conf
arch-chroot /mnt /bin/bash -c vim /etc/locale.conf
arch-chroot /mnt /bin/bash -c echo \"KEYMAP=es\" > /etc/vconsole.conf
arch-chroot /mnt /bin/bash -c vim /etc/vconsole.conf
arch-chroot /mnt /bin/bash -c sleep 3

#hosts
arch-chroot /mnt /bin/bash -c clear
#NOmbre de computador
hostname=archusb
arch-chroot /mnt /bin/bash -c (echo '$hostname') > /etc/hostname
arch-chroot /mnt /bin/bash -c vim /etc/hostname
arch-chroot /mnt /bin/bash -c (echo '127.0.0.1 localhost') >> /etc/hosts
arch-chroot /mnt /bin/bash -c (echo '::1 localhost') >> /etc/hosts
arch-chroot /mnt /bin/bash -c (echo '127.0.1.1 archusb.localdomain archusb')>> /etc/hosts
arch-chroot /mnt /bin/bash -c vim /etc/hosts

arch-chroot /mnt /bin/bash -c sleep 4
arch-chroot /mnt /bin/bash -c clear

#USUARIO Y ADMIN

arch-chroot /mnt /bin/bash -c (echo $userpasswd ; echo $userpasswd) | passwd

arch-chroot /mnt /bin/bash -c sleep 4

#Instalación del kernel
arch-chroot /mnt /bin/bash -c pacman -S grub efibootmgr networkmanager network-manager-applet mtools dosfstools reflector git base-devel linux-headers pulseaudio bluez bluez-utils cups xdg-utils xdg-user-dirs --noconfirm

arch-chroot /mnt /bin/bash -c sleep 4
#cambiar los hooks
arch-chroot /mnt /bin/bash -c echo"Cambie el orden de los hooks de block y keyboard despues de udev"
arch-chroot /mnt /bin/bash -c sleep 4
arch-chroot /mnt /bin/bash -c vim /etc/mkinitcpio.conf
arch-chroot /mnt /bin/bash -c mkinitcpio -p linux
#instalar el grub

arch-chroot /mnt /bin/bash -c grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB --removable --recheck
arch-chroot /mnt /bin/bash -c grub-mkconfig -o /boot/grub/grub.cfg

#ACTIVAR SERVICIOS
arch-chroot /mnt /bin/bash -c systemctl enable NetworkManager
arch-chroot /mnt /bin/bash -c systemctl enable bluetooth
arch-chroot /mnt /bin/bash -c systemctl enable cups

arch-chroot /mnt /bin/bash -c useradd -mG wheel $user
arch-chroot /mnt /bin/bash -c sleep 3
arch-chroot /mnt /bin/bash -c (echo $userpasswd ; echo $userpasswd) | passwd $user
arch-chroot /mnt /bin/bash -c echo"descomentar el wheel all"
arch-chroot /mnt /bin/bash -c sleep 2
arch-chroot /mnt /bin/bash -c EDITOR=vim visudo

arch-chroot /mnt /bin/bash -c clear
arch-chroot /mnt /bin/bash -c exit
umount -a
reboot


#arch-chroot /mnt /bin/bash -c "mkdir /etc/systemd/journald.conf.d"
							
#arch-chroot /mnt /bin/bash -c "(echo [Journal]) >> /etc/systemd/journald.conf.d/usbstick.conf"
#arch-chroot /mnt /bin/bash -c "(echo Storage=volatile) >> /etc/systemd/journald.conf.d/usbstick.conf"
#arch-chroot /mnt /bin/bash -c "(echo RuntimeMaxUse=30M) >> /etc/systemd/journald.conf.d/usbstick.conf"

#Video
#arch-chroot /mnt /bin/bash -c "pacman -S xf86-video-vesa xf86-video-ati xf86-video-nvidia xf86-video-amdgpu xf86-video-nouveau --noconfirm"
#NVIDIA > xf86-video-nouveau
#AMD 	> xf86-video-ati
#INTEL 	> xf86-video-intel


#Xorg
#arch-chroot /mnt /bin/bash -c "pacman -S xorg xorg-apps xorg-xinit --noconfirm"


#ESCRITORIO
#arch-chroot /mnt /bin/bash -c "pacman -S xfce4 --noconfirm"

#DISPLAY MANAGER
#arch-chroot /mnt /bin/bash -c "pacman -S lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings light-locker accountsservice --noconfirm"
#arch-chroot /mnt /bin/bash -c "systemctl enable lightdm.service"

#NAVEGADOR WEB
#arch-chroot /mnt /bin/bash -c "pacman -S firefox --noconfirm"

#establecer formato de teclado
#clear


#DESMONTAR Y REINICIAR


