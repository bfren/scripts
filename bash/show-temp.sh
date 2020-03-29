#!/bin/bash
gpu=$(/opt/vc/bin/vcgencmd measure_temp)
cpu=$(</sys/class/thermal/thermal_zone0/temp)
printf "GPU %s\n" $gpu
printf "CPU temp=%0.1f'C\n" $((cpu/1000))