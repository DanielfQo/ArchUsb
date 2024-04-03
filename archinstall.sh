#!/bin/bash

#para USB uefi

#Disco
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
	sleep 3
else
	echo "No support for BIOS"
fi






echo ""
echo "Instalando Sistema base con vim"
echo ""
pacstrap /mnt base linux linux-firmware vim
clear


echo ""
echo "Archivo FSTAB"
echo ""
echo "genfstab -U /mnt >> /mnt/etc/fstab"
echo ""

genfstab -U /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab
sleep 4
clear
sleep 4
#Horario idioma

arch-chroot /mnt



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


