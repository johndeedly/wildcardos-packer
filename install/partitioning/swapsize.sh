#!/usr/bin/env bash

# calculate swap size
ramsize=$(($(grep MemTotal /proc/meminfo | awk '{print $2}') / 1024))
if [ ${ramsize} -gt 8192 ]; then
  swapsize=10240
else
  swapsize=$((${ramsize} * 5 / 4))
fi

SWAPSIZE="${swapsize}"
