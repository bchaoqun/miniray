# syntax=docker/dockerfile:1.7

ARG PYTHON_IMAGE=python:3.12-trixie
FROM ${PYTHON_IMAGE}

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG DEBIAN_FRONTEND=noninteractive
ARG APT_MIRROR=https://mirrors.aliyun.com
ARG VCPKG_REF=817892b0ecbc6af994dd6df999c73faf795adbf2
# Change this value to intentionally refresh the vcpkg layer.
ARG VCPKG_CACHE_BUST=initial

# Build-time only. These values are not persisted in the image.
ARG HTTP_PROXY
ARG HTTPS_PROXY
ARG ALL_PROXY
ARG NO_PROXY
ARG http_proxy
ARG https_proxy
ARG all_proxy
ARG no_proxy

LABEL org.opencontainers.image.title="cpp-project dev environment" \
      org.opencontainers.image.description="C++20, Python 3.12, vcpkg and CLion Dev Container toolchain" \
      org.opencontainers.image.version="2026-10-26" \
      dev.cpp-project.vcpkg.ref="${VCPKG_REF}"

# BuildKit supplies standard proxy build args for this RUN command.
RUN if [[ -f /etc/apt/sources.list.d/debian.sources ]]; then \
        sed -i "s|http://deb.debian.org|${APT_MIRROR}|g" /etc/apt/sources.list.d/debian.sources; \
    fi \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        autoconf \
        automake \
        build-essential \
        ca-certificates \
        curl \
        g++ \
        gcc \
        gdb \
        git \
        libfreetype6 \
        libtool \
        libxext6 \
        libxi6 \
        libxrender1 \
        libxtst6 \
        ninja-build \
        pkg-config \
        procps \
        tar \
        unzip \
        zip \
    && rm -rf /var/lib/apt/lists/*

RUN echo "vcpkg layer: ${VCPKG_CACHE_BUST}" \
    && git init -q /opt/vcpkg \
    && git -C /opt/vcpkg remote add origin https://github.com/microsoft/vcpkg.git \
    && git -C /opt/vcpkg fetch --depth 1 origin "${VCPKG_REF}" \
    && git -C /opt/vcpkg checkout -q --detach FETCH_HEAD \
    && /opt/vcpkg/bootstrap-vcpkg.sh -disableMetrics \
    && ln -sf /opt/vcpkg/vcpkg /usr/local/bin/vcpkg \
    && cmake_bin="" \
    && for attempt in 1 2 3; do \
        cmake_bin="$(/opt/vcpkg/vcpkg fetch cmake)" \
        && [[ -x "${cmake_bin}" ]] \
        && break; \
        sleep 5; \
    done \
    && test -x "${cmake_bin}" \
    && cmake_dir="$(dirname "${cmake_bin}")" \
    && ln -sf "${cmake_bin}" /usr/local/bin/cmake \
    && ln -sf "${cmake_dir}/ctest" /usr/local/bin/ctest \
    && ln -sf "${cmake_dir}/cpack" /usr/local/bin/cpack \
    && git -C /opt/vcpkg rev-parse HEAD > /opt/vcpkg/IMAGE_COMMIT \
    && vcpkg version \
    && cmake --version \
    && gcc --version | head -n 1 \
    && g++ --version | head -n 1 \
    && ninja --version \
    && python --version

ENV VCPKG_ROOT=/opt/vcpkg \
    VCPKG_DEFAULT_TRIPLET=x64-linux \
    CMAKE_TOOLCHAIN_FILE=/opt/vcpkg/scripts/buildsystems/vcpkg.cmake

WORKDIR /workspaces/cpp-project

CMD ["bash"]
