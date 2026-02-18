# cinnamon-ublue

Fedora bootc/Universal Blue style image using Cinnamon, built with BlueBuild.

## Included

- Base image: `ghcr.io/ublue-os/base-main`
- Desktop: `cinnamon-desktop` group + `lightdm` + `slick-greeter`
- `distrobox`
- Homebrew via BlueBuild `brew` module
- One-shot Bluefin curated Homebrew sync (`regular` + `developer`) via `bluefin-brew-sync.service`
- GitHub Actions build workflows in `.github/workflows/`

## Build Locally

Requirements:

- `bluebuild`
- `podman`

Build OCI archive:

```bash
bluebuild --log-out .state/logs build --archive oci recipes/recipe.yml
```

Load and tag for local bootc-image-builder:

```bash
sudo podman load -i oci/cinnamon.tar.gz
sudo podman images
sudo podman tag <NEW_IMAGE_ID> localhost/cinnamon:latest
```

## Generate Disk Image From GitHub-Built Image

After GitHub Actions publishes your image to GHCR, generate a disk image directly from it with `bootc-image-builder`.

1. Prepare directories:

```bash
mkdir -p output
```

2. Download `config.toml` from this repository:

```bash
curl -fsSLO https://raw.githubusercontent.com/Danathar/cinnamon-ublue/main/config.toml
```

3. Pull your published image:

```bash
sudo podman pull ghcr.io/danathar/cinnamon:latest
```

4. Build a `qcow2` image:

```bash
sudo podman run --rm -it --privileged \
  --security-opt label=type:unconfined_t \
  -v "$(pwd)/config.toml:/config.toml:ro" \
  -v "$(pwd)/output:/output" \
  -v /var/lib/containers/storage:/var/lib/containers/storage \
  quay.io/centos-bootc/bootc-image-builder:latest \
  --type qcow2 \
  --rootfs btrfs \
  --config /config.toml \
  ghcr.io/danathar/cinnamon:latest
```

Output is in `output/qcow2/disk.qcow2`.

### Change Disk Type

Change `--type`:

- `--type qcow2` for KVM/libvirt/virt-manager
- `--type raw` for raw disk image workflows
- `--type ami` for AWS-style image outputs (when supported by your build setup)

### Change Disk Size

Set size in `config.toml`:

```toml
[customizations]
disk = { minsize = "30 GiB" }
```

If omitted, builder defaults are used.

### Add or Change Users in `config.toml`

Current user block:

```toml
[[customizations.user]]
name = "cin"
password = "changeme"
groups = ["wheel"]
```

Add more users by adding additional `[[customizations.user]]` blocks:

```toml
[[customizations.user]]
name = "alice"
password = "changeme"
groups = ["wheel"]

[[customizations.user]]
name = "bob"
password = "changeme"
groups = []
```

## Issues We Fixed

1. Fedora release identity conflict
Removed `fedora-release-cinnamon` and `fedora-release-identity-cinnamon` from recipe installs because they conflict with `fedora-release-identity-basic` in `base-main`.

2. LightDM failed on boot (`/var/cache/lightdm` + `/var/lib/lightdm-data` errors)
Added tmpfiles overlay at `files/system/usr/lib/tmpfiles.d/zz-lightdm-local.conf` to create required LightDM directories with correct ownership.

3. New fixes not appearing in qcow2
Root cause was stale tag usage (`localhost/cinnamon:latest` still pointing to an older image). The fix was to retag the newest loaded image ID before generating qcow2.

4. bootc-image-builder manifest error for `/boot`
Required adding `--rootfs btrfs` when generating qcow2.

## GitHub Actions Notes

- `build.yml`: builds/pushes image on push/schedule/manual.
- `build-pr.yml`: PR validation build.
- Add secret `SIGNING_SECRET` with contents of `cosign.key`.
- Add secret `COSIGN_PASSWORD` with the password used to generate `cosign.key` (use empty string only if your key was created with empty password).
- `build.yml` ignores README-only pushes.
