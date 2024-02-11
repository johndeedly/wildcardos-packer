#!/usr/bin/env bash

if ! [[ ${TAGS[@]} =~ "dualboot" ]]; then
  # |---------------total----------------|
  # |-first parts-|------data space------|
  part1=4
  part2=$( expr ${part1} + 512 )
  part3=$( expr ${part2} + \( 48 \* 1024 \) )
else
  # |---------------total----------------|
  # |-first parts-|------data space------|
  # |--win-|--li--|--windows--|--linux---|
  totalmib=$( expr `blockdev --getsize64 "${DEVICE}"` / 1024 / 1024 )
  part1=4
  part2=$( expr ${part1} + 512 )
  part3=$( expr ${part2} + 128 )
  part4=$( expr ${part3} + \( 96 \* 1024 \) )
  part5=$( expr ${part4} + 1024 )
  part6=$( expr ${part5} + \( 48 \* 1024 \) )
  # 4 MiB at the end to be on the safe side
  dataspace=$( expr ${totalmib} - ${part6} - 4 )
  # "/ 4 * 2" is very important here!! 4 MiB boundaries for partitions
  halfdata=$( expr ${dataspace} / 4 \* 2 )
  part7=$( expr ${part6} + ${halfdata} )
fi

if ! [[ ${TAGS[@]} =~ "dualboot" ]]; then
  parted -s -a optimal -- ${DEVICE} \
    mklabel gpt \
    mkpart efi fat32 ${part1}MiB ${part2}MiB \
    set 1 esp on \
    mkpart root btrfs ${part2}MiB ${part3}MiB \
    mkpart data ${part3}MiB -4MiB
  # efi part
  PART_EFI=$(ls ${DEVICE}* | grep -E "^${DEVICE}p?1$")
  # msr part
  PART_MSR=""
  # win part
  PART_WIN=""
  # diag part
  PART_DIAG=""
  # root part
  PART_ROOT=$(ls ${DEVICE}* | grep -E "^${DEVICE}p?2$")
  # windata part
  PART_WINDATA=""
  # data part
  PART_DATA=$(ls ${DEVICE}* | grep -E "^${DEVICE}p?3$")
else
  parted -s -a optimal -- ${DEVICE} \
    mklabel gpt \
    mkpart efi fat32 ${part1}MiB ${part2}MiB \
    set 1 esp on \
    mkpart msr ${part2}MiB ${part3}MiB \
    set 2 msftres on \
    mkpart win ntfs ${part3}MiB ${part4}MiB \
    set 3 msftdata on \
    mkpart diag ${part4}MiB ${part5}MiB \
    set 4 diag on \
    mkpart root btrfs ${part5}MiB ${part6}MiB \
    mkpart windata ${part6}MiB ${part7}MiB \
    set 6 msftdata on \
    mkpart data ${part7}MiB -4MiB
  # efi part
  PART_EFI=$(ls ${DEVICE}* | grep -E "^${DEVICE}p?1$")
  # msr part
  PART_MSR=$(ls ${DEVICE}* | grep -E "^${DEVICE}p?2$")
  # win part
  PART_WIN=$(ls ${DEVICE}* | grep -E "^${DEVICE}p?3$")
  # diag part
  PART_DIAG=$(ls ${DEVICE}* | grep -E "^${DEVICE}p?4$")
  # root part
  PART_ROOT=$(ls ${DEVICE}* | grep -E "^${DEVICE}p?5$")
  # windata part
  PART_WINDATA=$(ls ${DEVICE}* | grep -E "^${DEVICE}p?6$")
  # data part
  PART_DATA=$(ls ${DEVICE}* | grep -E "^${DEVICE}p?7$")
fi
