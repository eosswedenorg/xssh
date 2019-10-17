#!/usr/bin/env bash

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

PACKAGE_DESCRIPTION="eXtreme Secure Shell. SSH powered by flexible configuration."
PACKAGE_TMPDIR="pack"

# Default to 1 if no release is set.
if [[ -z $RELEASE ]]; then
  RELEASE="1"
fi

PACKAGE_FULLNAME="${PACKAGE_NAME}_${PACKAGE_VERSION}-${RELEASE}"

rm -fr ${BASE_DIR}/${PACKAGE_TMPDIR}

# Create debian files.
mkdir -p ${BASE_DIR}/${PACKAGE_TMPDIR}/DEBIAN
echo "Package: ${PACKAGE_NAME}
Version: ${PACKAGE_VERSION}-${RELEASE}
Section: net
Priority: optional
Architecture: all
Homepage: https://github.com/eosswedenorg/xssh
Maintainer: Henrik Hautakoski <henrik@eossweden.org>
Description: ${PACKAGE_DESCRIPTION}
Depends: bash (>= 4.3-14ubuntu1), coreutils, jq, sed, openssh-client" &> ${BASE_DIR}/${PACKAGE_TMPDIR}/DEBIAN/control

cat ${BASE_DIR}/${PACKAGE_TMPDIR}/DEBIAN/control

mkdir -p ${BASE_DIR}/${PACKAGE_TMPDIR}/${PACKAGE_PREFIX}/bin
mkdir -p ${BASE_DIR}/${PACKAGE_TMPDIR}/${PACKAGE_SHAREDIR}

cp ${BASE_DIR}/../$SCRIPT_NAME ${BASE_DIR}/${PACKAGE_TMPDIR}/${PACKAGE_PREFIX}/bin/${PACKAGE_NAME}
cp ${BASE_DIR}/../LICENSE ${BASE_DIR}/../README.md ${BASE_DIR}/../config.json \
	${BASE_DIR}/${PACKAGE_TMPDIR}/${PACKAGE_SHAREDIR}

dpkg-deb --root-owner-group --build ${BASE_DIR}/${PACKAGE_TMPDIR} ${BASE_DIR}/${PACKAGE_FULLNAME}.deb
