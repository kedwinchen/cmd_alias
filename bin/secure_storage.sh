#!/bin/bash

CONTAINER_PATH="${HOME}/secure.container"
MAPTO="secure.${USER}"
MOUNT_POINT="/home/${USER}/secure"

function alert {
	echo "/!\\ ALERT /!\\"
	echo -e "\a"
}

function pause {
	echo "Are you sure you wish to proceed?"
	read -p "If so, please press the [Enter] key to continue..."
}
  
function specs {
  echo "The specifications of the container are as follows:"
  echo "Container Location: ~/secure.container"
  echo "Mount Point: ~/secure"
  echo "Size: 32 GiB (32768 MB)"
}

function mount_container {
  echo "You are about to mount the container"
  pause
  /usr/bin/sudo /usr/bin/cryptsetup luksOpen ${CONTAINER_PATH} ${MAPTO}
  if [[ ! -d ${MOUNT_POINT} ]] ; then 
  	mkdir ${MOUNT_POINT}
  fi
  /usr/bin/sudo /usr/bin/mount /dev/mapper/${MAPTO} ${MOUNT_POINT}
  echo "The container is now mounted at ${MOUNT_POINT}"
}

function unmount_container {
  echo "You are about to unmount the container"
  pause
  /usr/bin/sudo /usr/bin/umount ${MOUNT_POINT}
  /usr/bin/sudo /usr/bin/cryptsetup luksClose ${MAPTO}
  echo "The container has been unmounted"
}

function setup {
  if [[ -e .securecontainer || -e secure.container ]] ; then
    echo "You appear to already have a set up a secure container"
    echo "If this is in error, please remove ~/secure.container and ~/.securecontainer"
    exit 3
  fi
  echo "This script will attempt to set up a LUKS-encrypted container for you"
  pause
  specs
  dd if=/dev/zero of=${CONTAINER_PATH} bs=1M count=32768 status=progress
  /usr/bin/sudo /usr/bin/cryptsetup luksFormat ${CONTAINER_PATH}
  /usr/bin/sudo /usr/bin/cryptsetup luksOpen ${CONTAINER_PATH} ${MAPTO}
  /usr/bin/sudo /usr/bin/mkfs.ext4 /dev/mapper/${MAPTO}
  touch .securecontainer
}

function print_usage {
  echo "This script sets up a LUKS-encrypted container for the user running this script."
  echo -e " Usage:"
  echo -e "   $0 <option>"
  echo -e "\t -h = print this help message and exit"
  echo -e "\t -p = print the specifications for the container"
  echo -e "\t -s = setup the container (this is intended to be run only once)"
  echo -e "\t -m = mount the container"
  echo -e "\t -u = unmount the container"
  echo -e " Please note that if multiple options are used, only the first one will be handled"
  exit 2
}

if env | grep -i SUDO &> /dev/null ; then
	echo "You cannot run this script using sudo"
	exit 255
fi

if ! groups | grep -E "wheel|sudo" &> /dev/null ; then 
  echo "You do not have sufficient privileges to mount/unmount devices (i.e., you are not part of the 'wheel' or 'sudo' groups)"
  echo "Please ensure that you have sudo privileges before using this script."
  exit 254
fi

#while getopts "hsmup" OPTION ; do
getopts "hsmup" OPTION
  case ${OPTION} in
  h)
    print_usage
    ;;
  p)
    specs
    ;;
  s)
    setup
    ;;
  m)
    mount_container
    ;;
  u)
    unmount_container
    ;;
  \?)
    print_usage
    ;;

  esac
#done
