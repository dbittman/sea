VERSION=0.1
NAME=pack
DESC=
DEPENDS=
CONFLICTS=

SOURCES=()
SOURCES_HASHES=()
PATCHES=()

function prepare() {
	true
}

function build() {
	mkdir -p $INSTALL_ROOT/usr/share/pack/bin $INSTALL_ROOT/usr/bin $INSTALL_ROOT/usr/src/packs/pack
	cp ../../../{pack.sh,install.sh,build-all.sh} $INSTALL_ROOT/usr/share/pack/bin
	cp ../../../{pack.sh,install.sh,build-all.sh} $INSTALL_ROOT/usr/src/packs/pack
	cp ../pack $INSTALL_ROOT/usr/bin/
	cp ../pack $INSTALL_ROOT/usr/src/packs/pack
	cp ../_pkg.sh $INSTALL_ROOT/usr/src/packs/pack/pkg.sh
}

