#!/bin/sh
eval `\`dirname -- "$0"\`/monitor_resolutions.sh`
expected_monitors=1
if [ "${monitor_count:-0}" -ne "$expected_monitors" ]
then
    echo "$0: Expected ${expected_monitors} monitors; found ${monitor_count:-0}." >&2
    exit 1
fi

# xrandr \
#     --output "$monitor1_name" \
#         --mode ${monitor1_width}x${monitor1_height} \
#         --pos 0x0 \
#         --rotate left \
#     --output "$monitor2_name" \
#         --mode ${monitor2_width}x${monitor2_height} \
#         --rotate normal \
#         --pos 0x0 \
#         --primary \
#         # --pos 0x0 \
#         # --pos ${monitor1_height}x0 \
# xrandr \
#     --output "$monitor1_name" \
#         --mode ${monitor1_width}x${monitor1_height} \
#         --pos 0x0 \
#         --rotate left \
#     --output "$monitor2_name" \
#         --mode ${monitor2_width}x${monitor2_height} \
#         --rotate normal \
#         --pos ${monitor1_height}x0 \
#         --primary \
#         # --pos 0x0 \
#         # --pos ${monitor1_height}x0 \

# one monitor script
# xrandr \
#     --output "$monitor1_name" \
#         --mode ${monitor1_width}x${monitor1_height} \
#         --rotate normal \
#         --pos 0x0 \
#         --primary \
#         # --pos 0x0 \
#         # --pos ${monitor1_height}x0 \
