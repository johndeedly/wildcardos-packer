#!/usr/bin/env bash

log_text "Installed hardware"

log_text "Prepare environment"
archiso_pacman_whenneeded lshw libxml2

log_text "Detect installed hardware"
LSHW=$(lshw -xml -quiet)

log_text "Count wireless devices"
WIRELESS_HITS=$(echo ${LSHW} | xmllint --xpath 'count(//capability[@id="wireless"])' -)

log_text "Count bluetooth devices"
BLUETOOTH_HITS=$(echo ${LSHW} | xmllint --xpath 'count(//capability[@id="bluetooth"])' -)

log_text "Get cpu vendors"
CPU_HITS=$(echo ${LSHW} | xmllint --xpath '//node[@class="processor"]/vendor/text()' -)

log_text "Get gpu vendors"
GPU_HITS=$(echo ${LSHW} | xmllint --xpath '//node[@class="display"]/vendor/text()' -)

log_text "Detect virtual environment"
VIRT_ENV=$(systemd-detect-virt)

log_text "Store results in variables"
INSTALLED_HARDWARE_WIRELESS=""
if [ $WIRELESS_HITS -gt 0 ] || [[ ${TAGS[@]} =~ "pxeimage" ]]; then
    INSTALLED_HARDWARE_WIRELESS="YES"
fi
INSTALLED_HARDWARE_BLUETOOTH=""
if [ $BLUETOOTH_HITS -gt 0 ] || [[ ${TAGS[@]} =~ "pxeimage" ]]; then
    INSTALLED_HARDWARE_BLUETOOTH="YES"
fi
INSTALLED_HARDWARE_CPU_VENDORS=()
if [ "x${CPU_HITS[@]}" != "x" ]; then
    for val in ${CPU_HITS[@]}; do
        INSTALLED_HARDWARE_CPU_VENDORS+=("$val")
    done
fi
INSTALLED_HARDWARE_GPU_VENDORS=()
if [ "x${GPU_HITS[@]}" != "x" ]; then
    for val in ${GPU_HITS[@]}; do
        INSTALLED_HARDWARE_GPU_VENDORS+=("$val")
    done
fi
INSTALLED_HARDWARE_QEMU=""
if [ "$VIRT_ENV" == "qemu" ] || [ "$VIRT_ENV" == "kvm" ]; then
    INSTALLED_HARDWARE_QEMU="YES"
fi
INSTALLED_HARDWARE_VMWARE=""
if [ "$VIRT_ENV" == "vmware" ] || [ "$VIRT_ENV" == "broadcom" ]; then
    INSTALLED_HARDWARE_VMWARE="YES"
fi
INSTALLED_HARDWARE_VIRTUALBOX=""
if [ "$VIRT_ENV" == "oracle" ]; then
    INSTALLED_HARDWARE_VIRTUALBOX="YES"
fi
INSTALLED_HARDWARE_VIRTUAL_MACHINE=""
if [ "$VIRT_ENV" != "none" ]; then
    INSTALLED_HARDWARE_VIRTUAL_MACHINE="YES"
fi
INSTALLED_HARDWARE_CPU_AMD=""
if [[ "${INSTALLED_HARDWARE_CPU_VENDORS[@]}" =~ [Aa][Mm][Dd] || -n "$INSTALLED_HARDWARE_VIRTUAL_MACHINE" ]]; then
    INSTALLED_HARDWARE_CPU_AMD="YES"
fi
INSTALLED_HARDWARE_CPU_INTEL=""
if [[ "${INSTALLED_HARDWARE_CPU_VENDORS[@]}" =~ [Ii][Nn][Tt][Ee][Ll] || -n "$INSTALLED_HARDWARE_VIRTUAL_MACHINE" ]]; then
    INSTALLED_HARDWARE_CPU_INTEL="YES"
fi
INSTALLED_HARDWARE_GPU_AMD=""
if [[ "${INSTALLED_HARDWARE_GPU_VENDORS[@]}" =~ [Aa][Mm][Dd] || -n "$INSTALLED_HARDWARE_VIRTUAL_MACHINE" ]]; then
    INSTALLED_HARDWARE_GPU_AMD="YES"
fi
INSTALLED_HARDWARE_GPU_INTEL=""
if [[ "${INSTALLED_HARDWARE_GPU_VENDORS[@]}" =~ [Ii][Nn][Tt][Ee][Ll] || -n "$INSTALLED_HARDWARE_VIRTUAL_MACHINE" ]]; then
    INSTALLED_HARDWARE_GPU_INTEL="YES"
fi
INSTALLED_HARDWARE_GPU_NVIDIA=""
if [[ "${INSTALLED_HARDWARE_GPU_VENDORS[@]}" =~ [Nn][Vv][Ii][Dd][Ii][Aa] || -n "$INSTALLED_HARDWARE_VIRTUAL_MACHINE" ]]; then
    INSTALLED_HARDWARE_GPU_NVIDIA="YES"
fi
