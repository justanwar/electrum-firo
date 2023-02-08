#!/bin/bash

LIBx11HASH_VERSION="ecdf417847601ae74a3ed1a2b787c80a22264a3d"

set -e

. $(dirname "$0")/build_tools_util.sh || (echo "Could not source build_tools_util.sh" && exit 1)

here=$(dirname $(realpath "$0" 2> /dev/null || grealpath "$0"))
CONTRIB="$here"
PROJECT_ROOT="$CONTRIB/.."

pkgname="x11_hash"
info "Building $pkgname..."

{
	cd $CONTRIB
	if [ ! -d x11_hash ]; then
        git clone https://github.com/zebra-lucky/x11_hash.git
    fi
	cd x11_hash
	if ! $(git cat-file -e ${LIBx11HASH_VERSION}) ; then
        info "Could not find requested version $LIBx11HASH_VERSION in local clone; fetching..."
        git fetch --all
    fi
	git reset --hard
    git clean -dfxq
    git checkout "${LIBx11HASH_VERSION}^{commit}"

	echo "const char *electrum_tag = \"tagged by Electrum@$ELECTRUM_COMMIT_HASH\";" >> ./x11hash.c

	autoreconf -fi || fail "Could not run autoreconf."
	if ! [ -r config.status ] ; then
        ./configure \
            --host=${GCC_TRIPLET_HOST} \
            --prefix="$here/$pkgname/dist" \
            || fail "Could not configure $pkgname. Please make sure you have a C compiler installed and try again."
    fi
	make -j4 || fail "Could not build $pkgname"
	make install || fail "Could not install $pkgname"
	. "$here/$pkgname/dist/lib/libx11hash.la"
	host_strip "$here/$pkgname/dist/lib/$dlname"
	cp -fpv "$here/$pkgname/dist/lib/$dlname" "$PROJECT_ROOT/electrum_firo" || fail "Could not copy the $pkgname binary to its destination"
    info "$dlname has been placed in the inner 'electrum_firo' folder."
    if [ -n "$DLL_TARGET_DIR" ] ; then
        cp -fpv "$here/$pkgname/dist/lib/$dlname" "$DLL_TARGET_DIR" || fail "Could not copy the $pkgname binary to DLL_TARGET_DIR"
    fi
}
