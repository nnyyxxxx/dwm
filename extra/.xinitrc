#!/bin/sh -e

picom -b
/usr/lib/polkit-kde-authentication-agent-1 &

while true; do
    time=$(date "+%I:%M %p")

    volume=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2*100)"%"}')

    updates=$(checkupdates | wc -l)

    status="🕒 $time  ⬇ $updates  🎧 $volume"

    xsetroot -name "$status"

    sleep 1m
done &

hsetroot -solid "#1E1E2E"

exec dwm
