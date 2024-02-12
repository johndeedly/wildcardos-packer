#!/usr/bin/env bash

# error handling
set -E -o functrace
err_report() {
  echo "errexit command '${1}' returned ${2} on line $(caller)" 1>&2
  exit "${2}"
}
trap 'err_report "${BASH_COMMAND}" "${?}"' ERR

# parse parameters
DEVICE=""
MOUNTPOINT=""
SCRIPTDIR=$(realpath $(dirname $0))
VERBOSE=""
TAGS=()
POSITIONAL=()
while [ $# -gt 0 ]; do
    key="$1"
    case $key in
        -d|--device)
            DEVICE="$2"
            shift
            shift
            ;;
        -m|--mountpoint)
            MOUNTPOINT="$2"
            shift
            shift
            ;;
        -s|--SCRIPTDIR)
            SCRIPTDIR="$2"
            shift
            shift
            ;;
        -v|--verbose)
            VERBOSE="YES"
            shift
            ;;
        -t|--tags)
            TAGS=( $(echo "$2" | tr "," "\n") )
            shift
            shift
            ;;
        *)
            POSITIONAL+=("$1") # save it in an array for later
            shift
            ;;
    esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

# default parameters
if [ -z "${DEVICE}" ]; then
  echo "-d|--device parameter is missing" 1>&2
  exit 1
fi
if [ -z "${MOUNTPOINT}" ]; then
  echo "-m|--mountpoint parameter is missing" 1>&2
  exit 1
fi
echo "using DEVICE=${DEVICE}"
echo "using SCRIPTDIR=${SCRIPTDIR}"
echo "using VERBOSE=${VERBOSE}"
echo "using TAGS=(${TAGS[@]})"

UBUNTU_RELEASE="mantic"

source "${SCRIPTDIR}/common.sh"


log_text "Mark all bash scripts recursively as executable"
find "${SCRIPTDIR}" -type f -iname '*.sh' -exec chmod a+x {} \;

if [[ ${TAGS[@]} =~ "target_nspawn" ]]; then
    log_text "Building a container - /share must be a mountpoint to the build host"
    if ! mountpoint -q -- /share; then
        echo "!! error" 1>&2
        exit 1
    fi
fi

if [[ ${TAGS[@]} =~ "target_host" || ${TAGS[@]} =~ "target_guest" || ${TAGS[@]} =~ "target_nspawn" ]]; then
    source "${SCRIPTDIR}/installed_hardware/main.sh"
fi

if [ -n "$VERBOSE" ]; then
    log_text "Installed hardware"
    echo "Wireless LAN: $INSTALLED_HARDWARE_WIRELESS"
    echo "Bluetooth:    $INSTALLED_HARDWARE_BLUETOOTH"
    echo "CPU vendors:  (${INSTALLED_HARDWARE_CPU_VENDORS[@]})"
    echo "GPU vendors:  (${INSTALLED_HARDWARE_GPU_VENDORS[@]})"
    echo "AMD cpu:      $INSTALLED_HARDWARE_CPU_AMD"
    echo "Intel cpu:    $INSTALLED_HARDWARE_CPU_INTEL"
    echo "AMD gpu:      $INSTALLED_HARDWARE_GPU_AMD"
    echo "Intel gpu:    $INSTALLED_HARDWARE_GPU_INTEL"
    echo "Nvidia gpu:   $INSTALLED_HARDWARE_GPU_NVIDIA"
    echo "QEMU hits:    $QEMU_HITS"
    echo "VMware hits:  $VMWARE_HITS"
    echo "Oracle hits:  $ORACLE_HITS"
    echo "Virt system:  $INSTALLED_HARDWARE_VIRTUAL_MACHINE"
fi

if [[ ${TAGS[@]} =~ "target_host" || ${TAGS[@]} =~ "target_guest" || ${TAGS[@]} =~ "target_nspawn" ]]; then
    source "${SCRIPTDIR}/partitioning/main.sh"
fi

if [ -n "$VERBOSE" ]; then
    log_text "Final partition layout"
    echo "### FSTAB ###"
    cat ${MOUNTPOINT%%/}/etc/fstab || true
    echo "### CRYPTTAB ###"
    cat ${MOUNTPOINT%%/}/etc/crypttab || true
    echo "### INITRAMFS CRYPTTAB ###"
    cat ${MOUNTPOINT%%/}/etc/crypttab.initramfs || true
    echo "### PARTITIONS ###"
    lsblk -o NAME,TYPE,FSTYPE,SIZE,FSAVAIL ${DEVICE} || true
fi

if [[ ${TAGS[@]} =~ "target_host" || ${TAGS[@]} =~ "target_guest" || ${TAGS[@]} =~ "target_nspawn" ]]; then
    source "${SCRIPTDIR}/base_bootable/main.sh"
fi

log_text "Final check - after this point ${MOUNTPOINT%%/} should be a mountpoint"
mountpoint -q -- ${MOUNTPOINT%%/}

log_text "Switching to systemd-nspawn context"
[ -e "${SCRIPTDIR}/nspawn-env" ] && rm -f "${SCRIPTDIR}/nspawn-env"
(set -o posix; set | grep -E '^DEVICE|^MOUNTPOINT|^SCRIPTDIR|^VERBOSE|^TAGS|^INSTALLED_HARDWARE_|^PART_|^UBUNTU_RELEASE' | while read -r line; do
  tee -a ${SCRIPTDIR}/nspawn-env <<EOF
$line
EOF
done)
bash "${SCRIPTDIR}/nspawn-chroot.sh" ${MOUNTPOINT%%/} <"${SCRIPTDIR}/main_nspawn.sh"

log_text "Filesystem services"
source "${SCRIPTDIR}/filesystem_services/main.sh"

log_text "Install system drivers"
source "${SCRIPTDIR}/drivers/main.sh"

log_text "Finalize archiso environment"
if [[ ${TAGS[@]} =~ "target_host" || ${TAGS[@]} =~ "target_guest" ]]; then
    source "${SCRIPTDIR}/systemd_boot/main.sh"
fi

log_text "Requested building of squashfs image"
if [[ ${TAGS[@]} =~ "pxeimage" ]]; then
    source "${SCRIPTDIR}/pxeimage/main.sh"
fi
