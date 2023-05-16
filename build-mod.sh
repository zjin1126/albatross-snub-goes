#!/bin/bash
set -oeux pipefail

RELEASE="$(rpm -E '%fedora.%_arch')"
KERNEL_VERSION=${KERNEL_VERSION:-}
if [[ -z $KERNEL_VERSION ]]; then
	echo KERNEL_VERSION no set
	exit 1
fi

sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/fedora-{cisco-openh264,modular,updates-modular}.repo

dnf -y install \
	https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
	https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
dnf -y --setopt=install_weak_deps=False install \
	kernel-${KERNEL_VERSION} \
	kernel-devel-${KERNEL_VERSION} \
	broadcom-wl

akmods --force --kernels "${KERNEL_VERSION}" --kmod wl

WL_AKMOD_VERSION="$(basename "$(rpm -q "akmod-wl" --queryformat '%{VERSION}-%{RELEASE}')" ".fc${RELEASE%%.*}")"
modinfo /usr/lib/modules/${KERNEL_VERSION}/extra/wl/wl.ko.xz > /dev/null || \
(cat /var/cache/akmods/wl/${WL_AKMOD_VERSION}-for-${KERNEL_VERSION}.failed.log && exit 1)
