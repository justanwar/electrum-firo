#!/bin/bash

set -e

PROJECT_ROOT="$(dirname "$(readlink -e "$0")")/../../.."
CONTRIB="$PROJECT_ROOT/contrib"
CONTRIB_SDIST="$CONTRIB/build-linux/sdist"
DISTDIR="$PROJECT_ROOT/dist"
LOCALE="$PROJECT_ROOT/electrum_firo/locale/"

. "$CONTRIB"/build_tools_util.sh

# note that at least py3.7 is needed, to have https://bugs.python.org/issue30693
python3 --version || fail "python interpreter not found"

break_legacy_easy_install

# upgrade to modern pip so that it knows the flags we need.
# we will then install a pinned version of pip as part of requirements-build-sdist
python3 -m pip install --upgrade pip

info "Installing pinned requirements."
python3 -m pip install --no-dependencies --no-warn-script-location -r "$CONTRIB"/deterministic-build/requirements-build-sdist.txt


"$CONTRIB"/make_packages || fail "make_packages failed"

info "preparing electrum-locale."
(
    ./contrib/make_locale
)

(
    cd "$PROJECT_ROOT"

    find -exec touch -h -d '2000-11-11T11:11:11+00:00' {} +

    # note: .zip sdists would not be reproducible due to https://bugs.python.org/issue40963
    TZ=UTC faketime -f '2000-11-11 11:11:11' python3 setup.py --quiet sdist --format=gztar
)


info "done."
ls -la "$DISTDIR"
sha256sum "$DISTDIR"/*