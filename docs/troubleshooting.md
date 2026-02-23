# Troubleshooting

## Common Behaviors

### First Boot Delay Before LightDM

- The image gates first graphical login on initial system Flatpak setup.
- If network is available, first boot can take longer before LightDM appears.

### Delay on Second Boot After Wi-Fi Setup

- If first boot happened without network and Wi-Fi is configured afterward, Flatpak setup can run on a later boot.
- This may be noticed on second boot and is occasional, not guaranteed.

### Installer Wi-Fi List UI Issue

- Some systems can hit a known Anaconda UI issue where the wireless list is too long/cut off and selecting an SSID does not open a password dialog.
- Workaround: complete install without network, then configure Wi-Fi after first boot.

## Issues Fixed in This Repository

1. Fedora release identity conflict
Removed `fedora-release-cinnamon` and `fedora-release-identity-cinnamon` from recipe installs because they conflict with `fedora-release-identity-basic` in `base-main`.

2. LightDM failed on boot (`/var/cache/lightdm` + `/var/lib/lightdm-data` errors)
Added tmpfiles overlay at `files/system/usr/lib/tmpfiles.d/zz-lightdm-local.conf` to create required LightDM directories with correct ownership.

3. New fixes not appearing in qcow2
Root cause was stale tag usage (`localhost/cinnamon:latest` still pointing to an older image). The fix was to retag the newest loaded image ID before generating qcow2.

4. `bootc-image-builder` manifest error for `/boot`
Required setting a supported root filesystem (`--rootfs ext4`) when generating qcow2.

5. Flatpaks not immediately visible in Cinnamon app menu on first login
Fixed by gating first graphical login on one-time `system-flatpak-setup.service` completion and marking setup done with `/var/lib/cinnamon-flatpak-setup/done`.

6. Staged-update terminal notice did not behave like Aurora/Bluefin
`starship` is not available as a normal DNF package in this build context, so the prompt notice failed when installed that way. We now install `starship` from the upstream release tarball at build time and use a Starship custom module to show `New deployment staged` when an update is pending.

