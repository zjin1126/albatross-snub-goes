#!/bin/bash
set -oeux pipefail

RELEASE="$(rpm -E '%fedora.%_arch')"

sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/fedora-{cisco-openh264,modular,updates-modular,updates-archive}.repo


rpm-ostree install \
    broadcom-wl mock

ln -s /usr/bin/ld.bfd /etc/alternatives/ld && ln -s /etc/alternatives/ld /usr/bin/ld

KERNEL_VERSION="$(rpm -q kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')"
WL_AKMOD_VERSION="$(basename "$(rpm -q "akmod-wl" --queryformat '%{VERSION}-%{RELEASE}')" ".fc${RELEASE%%.*}")"

akmods --force --kernels "${KERNEL_VERSION}" --kmod wl

modinfo /usr/lib/modules/${KERNEL_VERSION}/extra/wl/wl.ko.xz > /dev/null || \
(cat /var/cache/akmods/wl/${WL_AKMOD_VERSION}-for-${KERNEL_VERSION}.failed.log && exit 1)
