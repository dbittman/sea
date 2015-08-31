VERSION=0.2
NAME=seaosutil
DESC=
DEPENDS=
CONFLICTS=

SOURCES=()
SOURCES_HASHES=()
PATCHES=()

function prepare() {
	if ! [ -d $NAME ]; then
		cp -rf ../../../../../seaos-util $NAME
	fi
}

function build() {
	if ! ../src/$NAME/configure --prefix=/ --host=$HOST_TRIPLET; then
		return 1
	fi

	if ! make DESTDIR=$INSTALL_ROOT -j$INDIV_PARALLEL all install; then
		return 1
	fi
}

