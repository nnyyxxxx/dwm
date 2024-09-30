#!/bin/sh

pamixer &
picom -b
feh --randomize --bg-fill ~/dwm/extra/catppuccin-wallpapers/mocha-wall/* &
/usr/lib/polkit-kde-authentication-agent-1 &
dwmblocks &

hsetroot -solid "#1E1E2E"

exec dwm
