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

## AppImages

The AppImage-Manager installs the AppImages specified in the `~/.config/appimages.json` file using a systemd user service. The `~/.config/appimages.json` file is expected to be in the following format.

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

| :memo: **NOTE** |
|--|
| The AppImage-Manager includes quite a bit of AppImage-specific code to ensure desktop entries and icons work properly. This is a section that has some room for improvement. Just note that it may need to be revised for any AppImages that haven't already been used by myself. |

## Flatpaks

The Flatpak-Manager installs/removes the flatpaks specified in the `~/.config/flatpaks.json` file using a systemd user service. The `~/.config/flatpaks.json` file is expected to be in the following format.

```json
{
  "include": [
    "org.gimp.GIMP",
    "org.videolan.VLC"
  ],
  "exclude": []
}
```
