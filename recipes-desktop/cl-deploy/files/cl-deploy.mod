#!/bin/bash

function post_deploy() {

mpoint=$(mktemp --dry-run)
src=$(basename ${SRC})
dst=$(basename ${DST})
declare -A devarr=( [1]="/EFI/BOOT/grub.cfg" [2]="/etc/fstab" [3]="/etc/fstab" )
declare -A artarr=( [1]="grub-editenv ${mpoint}/EFI/BOOT/grubenv create" )
[[ ${dst} =~ "mmc" ]] && p="p" || p=""
[[ ${src} =~ "mmc" ]] && _p="p" || _p=""

for d in ${!devarr[@]};do

	_dev=/dev/${dst}${p}${d}

	if [ -b ${_dev} ];then

		mkdir -p ${mpoint}

		mount ${_dev} ${mpoint}

		for _file in ${devarr[${d}]};do

			if [ -f ${mpoint}/${_file} ];then
				sed -i "s/${src}${_p}/${dst}${p}/" ${mpoint}/${_file}
			fi

		done

		command=${artarr[${d}]}
		[[ -n "${command}" ]] && ${command}


		umount -l ${_dev}

		rm -rf ${mpoint}

	fi

done

}

post_deploy
