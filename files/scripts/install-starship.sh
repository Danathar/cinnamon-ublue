#!/usr/bin/env bash
set -euo pipefail

# Install Starship from the latest upstream release during image build.
# A temp directory keeps partial downloads out of the final image layer.
tmpdir="$(mktemp -d)"
trap 'rm -rf "${tmpdir}"' EXIT

# Release assets are published per architecture.
arch="$(uname -m)"
archive="starship-${arch}-unknown-linux-gnu.tar.gz"
url_base="https://github.com/starship/starship/releases/latest/download"

# Download both tarball and checksum, then verify before extracting.
curl -fsSL --retry 3 "${url_base}/${archive}" -o "${tmpdir}/starship.tar.gz"
curl -fsSL --retry 3 "${url_base}/${archive}.sha256" -o "${tmpdir}/starship.tar.gz.sha256"

echo "$(cat "${tmpdir}/starship.tar.gz.sha256")  ${tmpdir}/starship.tar.gz" | sha256sum --check
tar -xzf "${tmpdir}/starship.tar.gz" -C "${tmpdir}"
# Install into /usr/bin so profile.d init can enable it for interactive shells.
install -c -m 0755 "${tmpdir}/starship" /usr/bin/starship
