VERSION=2.00
NAME=grub
DESC="GRand Unified Bootloader: Bootloader for the kernel."
DEPENDS=
CONFLICTS=

SOURCES=(ftp://ftp.gnu.org/gnu/grub/grub-2.00.tar.xz)
SOURCES_HASHES=(a1043102fbc7bcedbf53e7ee3d17ab91)
PATCHES=("patches/grub-2.00-seaos-all.patch")

function prepare() {
	if ! [ -d grub-2.00 ]; then
		tar xf grub-2.00.tar.xz
	fi
}

function build() {
	if ! ../src/grub-2.00/configure --disable-werror --disable-grub-mkfont --prefix=/usr --host=$HOST_TRIPLET; then
		return 1
	fi

	if ! make DESTDIR=$INSTALL_ROOT all install; then
		return 1
	fi
}

