#!/usr/bin/env bash

ip link set wg0 down
ip link delete dev wg0
