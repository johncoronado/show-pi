# Show-Pi Documentation
[Show-Pi GitHub Repo](https://github.com/johncoronado/show-pi)
## Installation

- Use the official Raspberry Pi Imager (<https://www.raspberrypi.com/software/>) to download and install Raspberry Pi OS Lite (64-bit) on your connected boot drive of choice (SD card or USB).
- Customize your OS setting on Raspberry Pi Imager to preconfigure your hostname, username, wifi, etc.
- Boot your fresh install of Raspberry Pi OS Lite. It may reboot several times on first boot.
- Log into your Pi via SSH or by connecting a keyboard/mouse into your Pi.
- Run the update commands. Each line is a seperate command.

```bash
sudo apt update
sudo apt upgrade -y
```

- Reboot your system

```bash
sudo reboot
```

- Install git

```bash
sudo apt install git -y
```

- Clone the repository and run the setup script:

```bash
git clone https://github.com/johncoronado/show-pi.git
cd show-pi
./setup.sh
```

- Reboot your Pi after all scripts have finished.

```bash
sudo reboot
```

---

This site is generated using [MkDocs](https://www.mkdocs.org/) and the [Material for MkDocs theme](https://squidfunk.github.io/mkdocs-material/).
