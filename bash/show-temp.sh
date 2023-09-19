#!/bin/sh

CPU=$(< /sys/class/thermal/thermal_zone0/temp)
printf "CPU temp=%0.1f'C\n" $((CPU/1000))
