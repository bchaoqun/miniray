#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
image="${IMAGE:-cpp-project-dev:2026-10-28-vscode-clangd}"
platform="${PLATFORM:-linux/amd64}"
python_image="${PYTHON_IMAGE:-python:3.12-trixie}"
vcpkg_ref="${VCPKG_REF:-817892b0ecbc6af994dd6df999c73faf795adbf2}"

proxy_url="${PROXY_URL:-http://127.0.0.1:7897}"
no_proxy_value="${NO_PROXY:-localhost,127.0.0.1,::1,mirrors.aliyun.com}"
proxy_args=(
    --build-arg "HTTP_PROXY=${HTTP_PROXY:-${proxy_url}}"
    --build-arg "HTTPS_PROXY=${HTTPS_PROXY:-${proxy_url}}"
    --build-arg "ALL_PROXY=${ALL_PROXY:-${proxy_url}}"
    --build-arg "NO_PROXY=${no_proxy_value}"
    --build-arg "http_proxy=${http_proxy:-${proxy_url}}"
    --build-arg "https_proxy=${https_proxy:-${proxy_url}}"
    --build-arg "all_proxy=${all_proxy:-${proxy_url}}"
    --build-arg "no_proxy=${no_proxy:-${no_proxy_value}}"
)

docker build \
    --platform "${platform}" \
    --network host \
    --progress plain \
    "${proxy_args[@]}" \
    --build-arg "PYTHON_IMAGE=${python_image}" \
    --build-arg "VCPKG_REF=${vcpkg_ref}" \
    --build-arg "VCPKG_CACHE_BUST=$(date -u +%Y%m%dT%H%M%SZ)" \
    -f "${repo_root}/.devcontainer/Dockerfile" \
    -t "${image}" \
    "${repo_root}/.devcontainer"

docker run --rm --platform "${platform}" --entrypoint bash "${image}" -lc '
set -euo pipefail
test -x /opt/vcpkg/vcpkg
test -x /usr/local/bin/cmake
printf "image check: "
cmake --version | head -n 1
printf "vcpkg commit: "
cat /opt/vcpkg/IMAGE_COMMIT
printf "compiler: "
g++ --version | head -n 1
printf "python: "
python --version
'

if [[ "${SAVE_IMAGE:-0}" == "1" ]]; then
    mkdir -p "${repo_root}/dist"
    archive="${repo_root}/dist/${image//[:\/]/_}.tar.gz"
    docker save "${image}" | gzip -1 > "${archive}"
    printf 'saved image: %s\n' "${archive}"
fi
