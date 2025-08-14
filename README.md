## Microsoft Edge Portable with Chrome++ Auto Installer

This PowerShell script automatically downloads and installs **Microsoft Edge Stable Portable** with **Chrome++**, creating a portable build at `C:\Edge_Portable`.
Key features:

* Automatically checks and requests **Administrator** privileges.
* **Downloads the latest Edge Stable build from [edge\_installer](https://github.com/bibicadotnet/edge_installer)**.
* Fetches and integrates **Chrome++** for enhanced features.
* Fully automated extraction, installation, and configuration.
* Cleans up temporary files and installers after completion.

**Run a single command** to get a ready-to-use portable Edge without modifying your system.

```
irm https://go.bibica.net/edge_portable | iex
```

Too lazy? Just grab the pre-built [release](https://github.com/bibicadotnet/microsoft-edge-portable/releases/), extract it, and you’re ready to go.
