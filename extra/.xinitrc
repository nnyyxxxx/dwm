#!/bin/sh

pamixer &
/usr/lib/polkit-kde-authentication-agent-1 &

while true; do
    time=$(date "+%I:%M %p")

    volume=$(pamixer --get-volume-human)

    updates=$(checkupdates | wc -l)

    status="  $time    $updates    $volume"

    xsetroot -name "$status"

    sleep 1m
done &

hsetroot -solid "#282828"

exec dwm
