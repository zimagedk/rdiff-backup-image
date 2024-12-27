#!/usr/bin/env bash

version="1.0.0"

set -euo pipefail

base=$(realpath "$(dirname "${BASH_SOURCE[0]}")")
build="${base}/build"

name="rdiff-backup"
repository="zimagedk/${name}"

tags=("${repository}:${version}" "${repository}:latest")

args=()

for tag in "${tags[@]}"; do
    args+=("-t" "${tag}")
done

c_exe=docker

if ! which "${c_exe}" > /dev/null 2>&1; then
    c_exe=podman
    if ! which "${c_exe}" > /dev/null 2>&1; then
        echo "Docker or Podman must be installed"
        exit 1
    fi
fi

"${c_exe}" build ${args[@]} src/

mkdir -p "${build}"
"${c_exe}" save "${tags[0]}" | gzip - > "${build}/${name}-image.tgz"

echo "Image archive built: ${build}/${name}-image.tgz"
