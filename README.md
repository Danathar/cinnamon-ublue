# cinnamon-ublue

Fedora bootc/Universal Blue style image using Cinnamon, built with BlueBuild.

> This is **not** an official Universal Blue image.  
> It is a personal experimental project.

## What You Get

- Base image: `ghcr.io/ublue-os/base-main`
- Cinnamon desktop (`cinnamon-desktop` + `lightdm` + `slick-greeter`)
- Homebrew via BlueBuild `brew` module
- Flatpaks via BlueBuild `default-flatpaks` module (system scope, Flathub)
- Automatic updates via `uupd.timer` (system, brew, flatpak, distrobox)
- Signed image publishing workflows in `.github/workflows/`

## Quick Start (Installer ISO)

Use this path for most users.

1. Install `bluebuild` CLI (if needed):

```bash
podman run --pull always --rm ghcr.io/blue-build/cli:latest-installer | bash
bluebuild --version
```

2. Build installer ISO from published image:

```bash
bluebuild generate-iso \
  --variant kinoite \
  --iso-name cinnamon-ublue.iso \
  -o output \
  image ghcr.io/danathar/cinnamon:latest
```

3. Boot the ISO and install.

Detailed instructions and caveats: [`docs/install-iso.md`](docs/install-iso.md).

## First Boot Summary

- First graphical login is gated on one-time system Flatpak setup, so reaching LightDM can take longer when network is available.
- If first boot had no network, that setup delay may occur on a later boot after network is configured (occasional).
- For non-Anaconda install paths (raw/qcow2 disk image), time defaults to UTC; set timezone after first boot.

More details and known quirks: [`docs/troubleshooting.md`](docs/troubleshooting.md).

## Documentation

- Local builds: [`docs/build-locally.md`](docs/build-locally.md)
- Installer ISO install: [`docs/install-iso.md`](docs/install-iso.md)
- Disk image install (qcow2/raw): [`docs/install-disk-image.md`](docs/install-disk-image.md)
- Troubleshooting and known behaviors: [`docs/troubleshooting.md`](docs/troubleshooting.md)
- CI, signing, and update-path config: [`docs/ci-and-signing.md`](docs/ci-and-signing.md)
- Using this repo as template or fork: [`docs/repo-template-or-fork.md`](docs/repo-template-or-fork.md)
