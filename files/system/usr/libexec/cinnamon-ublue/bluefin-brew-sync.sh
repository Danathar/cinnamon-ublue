#!/usr/bin/env bash

set -euo pipefail

STATE_FILE="/var/lib/bluefin-brew-sync/done"
WORK_DIR="/var/tmp/bluefin-brew-sync"
TARGET_USER="${TARGET_USER:-1000}"

if [[ "${TARGET_USER}" =~ ^[0-9]+$ ]]; then
  TARGET_NAME="$(getent passwd "${TARGET_USER}" | cut -d: -f1 || true)"
else
  TARGET_NAME="${TARGET_USER}"
fi

if [[ -z "${TARGET_NAME}" ]] || ! id "${TARGET_NAME}" >/dev/null 2>&1; then
  echo "Target user '${TARGET_USER}' does not exist yet; skipping for now."
  exit 0
fi

TARGET_HOME="$(getent passwd "${TARGET_NAME}" | cut -d: -f6)"
if [[ -z "${TARGET_HOME}" ]] || [[ ! -d "${TARGET_HOME}" ]]; then
  echo "Target home '${TARGET_HOME}' does not exist yet; skipping for now."
  exit 0
fi

mkdir -p "${WORK_DIR}"
rm -rf "${WORK_DIR:?}/bluefin"
mkdir -p "${WORK_DIR}/bluefin"

archive="${WORK_DIR}/bluefin.tar.gz"
curl -fsSL "https://github.com/ublue-os/bluefin/archive/main.tar.gz" -o "${archive}"
tar -xzf "${archive}" -C "${WORK_DIR}/bluefin" --strip-components=1

brew_dir="$(find "${WORK_DIR}/bluefin" -type d -path '*/usr/share/ublue-os/brew' | head -n1 || true)"
if [[ -z "${brew_dir}" ]]; then
  echo "Could not find Bluefin curated brew directory in Bluefin main."
  exit 1
fi

regular_brewfile=""
for candidate in \
  "${brew_dir}/Brewfile" \
  "${brew_dir}/regular.Brewfile" \
  "${brew_dir}/base.Brewfile"
do
  if [[ -f "${candidate}" ]]; then
    regular_brewfile="${candidate}"
    break
  fi
done

developer_brewfile=""
for candidate in \
  "${brew_dir}/developer.Brewfile" \
  "${brew_dir}/Brewfile-developer" \
  "${brew_dir}/dx.Brewfile"
do
  if [[ -f "${candidate}" ]]; then
    developer_brewfile="${candidate}"
    break
  fi
done

if [[ -z "${regular_brewfile}" ]]; then
  regular_brewfile="$(find "${brew_dir}" -maxdepth 2 -type f -name '*Brewfile*' | grep -Ev '(dev|devel|developer|dx)' | head -n1 || true)"
fi
if [[ -z "${developer_brewfile}" ]]; then
  developer_brewfile="$(find "${brew_dir}" -maxdepth 2 -type f -name '*Brewfile*' | grep -Ei '(dev|devel|developer|dx)' | head -n1 || true)"
fi

if [[ -z "${regular_brewfile}" ]]; then
  echo "Could not resolve Bluefin regular Brewfile from Bluefin main."
  exit 1
fi
if [[ -z "${developer_brewfile}" ]]; then
  echo "Could not resolve Bluefin developer Brewfile from Bluefin main."
  exit 1
fi

brew_bin=""
for candidate in \
  "/home/linuxbrew/.linuxbrew/bin/brew" \
  "/var/home/linuxbrew/.linuxbrew/bin/brew" \
  "/usr/bin/brew"
do
  if [[ -x "${candidate}" ]]; then
    brew_bin="${candidate}"
    break
  fi
done

if [[ -z "${brew_bin}" ]]; then
  echo "Homebrew binary not found; ensure BlueBuild brew module is enabled."
  exit 1
fi

common_env=(
  "HOME=${TARGET_HOME}"
  "USER=${TARGET_NAME}"
  "LOGNAME=${TARGET_NAME}"
  "PATH=/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:/usr/bin:/usr/sbin"
  "HOMEBREW_NO_ANALYTICS=1"
)

runuser -u "${TARGET_NAME}" -- env "${common_env[@]}" "${brew_bin}" bundle --file "${regular_brewfile}"
runuser -u "${TARGET_NAME}" -- env "${common_env[@]}" "${brew_bin}" bundle --file "${developer_brewfile}"

touch "${STATE_FILE}"
echo "Bluefin curated brew packages installed for ${TARGET_NAME}."
