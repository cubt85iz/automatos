# automatOS

Create your own OCI image containing desired packages and utilities for installing user-specified AppImages and Flatpaks.

## Configuration Specification

* **base_image** (string): URL for the base OCI image
* **base_image_tag** (string): Tag for the base OCI image
* **description** (string): Short description for the generated image.
* **github_releases** (object[]): List of Github releases to install.
  * **project** (string): Github owner & repository.
  * **arch** (string): System architecture.
* **packages** (object[]): List of packages to install or remove using rpm-ostree.
  * **install** (string[]): List of packages to install.
  * **remove** (string[]): List of packages to remove.

### AppImages

The AppImage-Manager accepts a JSON file that specifies the AppImages for Github releases that should be installed. This JSON file can be stored anywhere and passed to the AppImage-Manager using a systemd user service.

_~/.config/appimages.json_

```json
{
  "directory": "~/.appimages",
  "appimages": [
    {
      "name": "Bitwarden",
      "source": "bitwarden/clients",
      "pattern": "Desktop"
    }
  ]
}
```

_~/.config/systemd/user/appimage-manager.service_

```
[Unit]
Description=Service for managing AppImages
Requires=network-online.target
After=network-online.target

[Service]
Type=oneshot
ExecStart=/bin/bash -c "/usr/bin/appimage-manager $HOME/.config/appimages.json"

[Install]
WantedBy=default.target
```

| :memo: **NOTE** |
|--|
| The AppImage-Manager includes quite a bit of AppImage-specific code to ensure desktop entries and icons work properly. This is a section that has some room for improvement. Just note that it may need to be revised for any AppImages that haven't already been used by myself. |

### Flatpaks

The Flatpak-Manager accepts a JSON file that specifies the Flatpaks to installed or removed. This JSON file can be stored anywhere and passed to the Flatpak-Manager using a systemd user service.

_~/.config/flatpaks.json_

```json
{
  "include": [
    "org.gimp.GIMP",
    "org.videolan.VLC"
  ],
  "exclude": []
}
```

_~/.config/systemd/user/flatpak-manager.service_

```
[Unit]
Description=Install Flatpaks indicated by user
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStartPre=/usr/bin/flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
ExecStart=/usr/bin/flatpak-manager %h/.config/flatpaks.json

[Install]
WantedBy=default.target
```