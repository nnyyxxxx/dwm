<p align="center">
  <img src="https://i.imgur.com/ulTXhIp.png" alt="Image">
</p>

<hr>

<div align="center">
  <h2>Usage</h2>
</div>

Install via curl
  ```shell
  curl -fsSL https://github.com/nnyyxxxx/dwm/raw/main/install.sh | sh
  ```

Install via git
  ```shell
  git clone https://github.com/nnyyxxxx/dwm
  cd dwm
  chmod +x install.sh
  ./install.sh
  ```

Starting dwm
- After installing via curl or git; you'll have to reboot your system, after doing so you'll be greeted with either your display manager or DWM, it is highly recommended that you do NOT use a display manager e.g. (sddm, lightdm*) with these dotfiles, and instead resort to using ``startx`` in the tty. If you do not want to manually start DWM from the tty then don't worry as the install script automatically sets up auto-start/auto-login for DWM & tty.

Updating dotfiles
- To sync your clone of DWM with the latest version, you can use the following command:
  ```shell
  curl -fsSL https://github.com/nnyyxxxx/dwm/raw/main/install.sh | sh
  ```
> [!WARNING]  
> This will overwrite your existing configuration, if you have made any changes to the dotfiles, make sure to back them up before running the install script.

<div align="center">
  <h2>Information</h2>
</div>

Important notes
- These dotfiles use bash as the default shell, and as such be prepared to manually set up your shell if you do not plan on using bash.
- The install script will uninstall any existing display managers so compatibility can be reached.

<div align="center">
  <h2>Keybinds overview</h2>
</div>

| Keybind | Description |  
| --- | --- |  
| `ALT SHIFT + Enter` | Spawns st (Terminal) |  
| `ALT SHIFT + P` | Spawns dmenu (Application launcher) |  
| `ALT SHIFT + C` | Kills current window |  
| `ALT SHIFT + Q` | Kills dwm |  
| `ALT SHIFT + W` | Restarts dwm and keeps application positions |
| `ALT SHIFT + F` | Toggles fullscreen (Actualfullscreen Patch) |
| `ALT + ESC` | Spawns maim (Screenshot utility) | 
| `ALT + LMB` | Drags selected window |
| `ALT + RMB` | Resizes window in floating & resizes mfact in tiled; when two or more windows are on screen |
| `ALT + SPACE` | Makes the selected window float |
| `ALT + R` | Resets mfact |

<div align="center">
  <h2>Preview</h2>
</div>

![PV](https://i.imgur.com/YFPjFoq.png)

<p align="center">
  <img src="https://i.imgur.com/IWEAfzW.png" alt="Image">
</p>