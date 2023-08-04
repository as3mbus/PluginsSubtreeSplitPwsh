# Unreal Plugin Subtree Splitter

![version](https://img.shields.io/badge/Version-2.0.0-brightgreen)

<!-- TABLE OF CONTENTS -->
Table of Contents

1. [Overview](#overview)
1. [Dependency](#dependency)
1. [Contributing](#contributing)
1. [License](#license)

<!-- ABOUT THE PROJECT -->

## Overview

This script automatically do these following process :

1. subtree split plugins directory folder specified in `dirName` param
2. push split subtree to remote url specified in `repoUrl` param
3. tag latest split commit with uplugin version name
4. remove specified `dirName` plugin directory
5. add submodule from `repoUrl` as `Plugins/$dirName`
6. commit changes for steps 5, and 6.

## Dependency

1. Windows 10 or later
2. git

<!-- USAGE EXAMPLES -->

## Usage

1. move this script to project root folder
2. execute `.\MigratePluginToSubmodule.ps1 -dirName <Plugin Directory Name> -repoUrl <submodule repo directory>`
    - Plugin Directory Name example : `MyUnrealPlugin` will refer to `<Project Root Dir>/Plugins/MyUnrealPlugin`
    - submodule repo url example : <https://github.com/username/MyUnrealPlugin.git>

<!-- CONTRIBUTING -->

## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".
Don't forget to give the project a star! Thanks again!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

<!-- LICENSE -->

## License

Distributed under the MIT License.
