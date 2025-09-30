# automatOS

Use this repository to define your own customized Fedora Atomic Desktop image. Refer to the [automatos-daedalus](https://github.com/cubt85iz/automatos-daedalus) repository as a guide for creating your own image.

## JSON Schema Documentation

This document provides an overview of the JSON schema used for defining the structure of a container image configuration.

### Schema Information

- **Schema Version**: [Draft-07](http://json-schema.org/draft-07/schema#)
- **Type**: `object`

### Properties

#### `base_image`

- **Type**: `string`
- **Description**: The base image used for the container image.
- **Example**: `ghcr.io/ublue-os/silverblue-nvidia`

#### `base_image_tag`

- **Type**: `string`
- **Description**: The tag associated with the base image, indicating the version.
- **Example**: `42`

#### `description`

- **Type**: `string`
- **Description**: A brief description of the image and its purpose.
- **Example**: A desktop image derived from Fedora Silverblue with the latest Nvidia drivers.

#### `github_releases`

- **Type**: `array`
- **Description**: A list of GitHub releases to install in the container image.
- **Items**:
  - **Type**: `object`
  - **Properties**:
    - **project**
      - **Type**: `string`
      - **Description**: The name of the GitHub project.
      - **Example**: `twpayne/chezmoi`
    - **arch**
      - **Type**: `string`
      - **Description**: The architecture for which the release is intended.
      - **Example**: `x86_64`
  - **Required**: `["project", "arch"]`

#### `packages`

- **Type**: `object`
- **Description**: Package management details for the image.
- **Properties**:
  - **install**
    - **Type**: `array`
    - **Description**: A list of packages to be installed.
    - **Items**:
      - **Type**: `string`
      - **Example**: `code`
    - **Example**:

      ```json
      [
        "code",
        "fira-code-fonts",
        "fuse-sshfs",
        "gvfs-nfs",
        "input-remapper",
        "just",
        "setroubleshoot",
        "steam-devices",
        "tmux",
        "unrar",
        "wimlib-utils"
      ]
      ```

  - **remove**
    - **Type**: `array`
    - **Description**: A list of packages to be removed.
    - **Items**:
      - **Type**: `object`
      - **Properties**:
        - **remove**
          - **Type**: `array`
          - **Description**: Packages to be removed from the system.
          - **Items**:
            - **Type**: `string`
            - **Example**: `firefox`
          - **Example**:

            ```json
            [
              "firefox",
              "firefox-langpacks",
              "gnome-tour"
            ]
            ```

    - **Required**: `["remove"]`

### Required Properties

The following properties are required in the JSON object:

- `base_image`
- `base_image_tag`
- `description`
- `github_releases`
- `packages`
