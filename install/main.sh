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
        -s|--scriptdir)
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

log_text "Prepare archiso environment"
source "${SCRIPTDIR}/prepare_archiso/main.sh"

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

if [ -f /etc/hostname ]; then
    log_text "Use /etc/hostname from host"
    mkdir -p ${MOUNTPOINT%%/}/etc
    sed -i '/./,$!d' /etc/hostname
    cat /etc/hostname | tee ${MOUNTPOINT%%/}/etc/hostname
fi

if [ -f /etc/hosts ] && grep '127.0.0.1' /etc/hosts >/dev/null ; then
    log_text "Use /etc/hosts from host"
    mkdir -p ${MOUNTPOINT%%/}/etc
    sed -i '/./,$!d' /etc/hosts
    cat /etc/hosts | tee ${MOUNTPOINT%%/}/etc/hosts
elif [ -f /etc/hostname ]; then
    log_text "Create new /etc/hosts from host information"
    mkdir -p ${MOUNTPOINT%%/}/etc
    sed -i '/./,$!d' /etc/hostname
    FQDN=$(head -n 1 /etc/hostname)
    HOSTNAME=$(cat /etc/hostname | grep -Eo '^[^.]*')
    tee ${MOUNTPOINT%%/}/etc/hosts <<EOF
# Static table lookup for hostnames.
# See hosts(5) for details.

# https://www.icann.org/en/public-comment/proceeding/proposed-top-level-domain-string-for-private-use-24-01-2024
# IPv4/v6   FQDN  HOSTNAME  localhost.internal localhost
127.0.0.1   $FQDN $HOSTNAME localhost.internal localhost
::1         $FQDN $HOSTNAME localhost.internal localhost
EOF
fi

log_text "Switching to systemd-nspawn context"
[ -e "${SCRIPTDIR}/nspawn-env" ] && rm -f "${SCRIPTDIR}/nspawn-env"
(set -o posix; set | grep -E '^DEVICE|^MOUNTPOINT|^SCRIPTDIR|^VERBOSE|^TAGS|^INSTALLED_HARDWARE_|^PART_|^UBUNTU_RELEASE|^RUNTIME_ENVIRONMENT_' | while read -r line; do
  tee -a ${SCRIPTDIR}/nspawn-env <<EOF
$line
EOF
done)
bash "${SCRIPTDIR}/nspawn-chroot.sh" ${MOUNTPOINT%%/} <"${SCRIPTDIR}/main_nspawn.sh"

if [[ ${TAGS[@]} =~ "target_host" || ${TAGS[@]} =~ "target_guest" ]]; then
    log_text "Install boot manager"
    source "${SCRIPTDIR}/systemd_boot/main.sh"
fi

if [[ ${TAGS[@]} =~ "pxeimage" ]]; then
    log_text "Requested building of squashfs image"
    source "${SCRIPTDIR}/pxeimage/main.sh"
fi

if [[ ${TAGS[@]} =~ "target_host" || ${TAGS[@]} =~ "target_guest" ]]; then
    log_text "Filesystem services"
    source "${SCRIPTDIR}/filesystem_services/main.sh"
fi
