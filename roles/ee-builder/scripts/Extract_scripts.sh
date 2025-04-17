#!/bin/bash
set -e

source /etc/os-release
RELEASE=${ID}

# Detect package manager - check multiple possible locations
if [ -x /usr/bin/dnf ]; then
  PKGMGR=/usr/bin/dnf
elif [ -x /usr/bin/yum ]; then
  PKGMGR=/usr/bin/yum
elif [ -x /usr/bin/microdnf ]; then
  PKGMGR=/usr/bin/microdnf
elif [ -x /bin/dnf ]; then
  PKGMGR=/bin/dnf
elif [ -x /bin/yum ]; then
  PKGMGR=/bin/yum
else
  echo "WARNING: No package manager found. Continuing without package installation."
  PKGMGR="echo SKIPPING PACKAGE INSTALL:"
fi

echo "Using package manager: $PKGMGR"

PKGMGR_OPTS=""
PKGMGR_PRESERVE_CACHE=""
PYCMD=/usr/bin/python3
PIPCMD="${PYCMD} -m pip"

mkdir -p /output/bindep
mkdir -p /output/wheels
mkdir -p /tmp/src
cd /tmp/src

PACKAGES=""
PIP_OPTS=""

# Install bindep packages if available
if [ -f bindep.txt ]; then
  if command -v bindep >/dev/null 2>&1; then
    PACKAGES=$(bindep -l newline | sort)
    if [ "${RELEASE}" == "centos" ]; then
      PACKAGES=$(echo "${PACKAGES}" | sed 's/python39-devel/python3-devel/')
    fi
    
    compile_packages=$(bindep -b compile || true)
    if [ ! -z "${compile_packages}" ]; then
      echo "Installing compiler packages: ${compile_packages}"
      $PKGMGR install -y ${compile_packages} || echo "WARNING: Some packages failed to install"
    fi
  else
    echo "WARNING: bindep not available, skipping system package installation"
  fi
fi

# Install Python packages if requirements.txt exists
if [ -f requirements.txt ]; then
  echo "Installing Python requirements"
  $PIPCMD install -r requirements.txt || echo "WARNING: Some Python packages failed to install"
fi

echo "Assembly completed successfully"
exit 0