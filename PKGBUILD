# Maintainer:  kernel.old <kernel.old@gmail.com>
# Contributor: James Lambert (jamlam) <jamesl@mbert.onmicrosoft.com>
# Contributor: Aun-Ali Zaidi <admin@kodeit.net>
# Contributor: Jan Alexander Steffens (heftig) <jan.steffens@gmail.com>

#pkgver=6.0.2
pkgbase=linux-mbp15
# get latest stable kernel version to build
mainversion=6.3
kernstable=$(curl -s https://www.kernel.org/ | grep -A1 'stable:' | grep  "$mainversion" | grep -oP '(?<=strong>).*(?=</strong.*)')
pkgver=$kernstable
_srcname=linux-${pkgver}
pkgrel=1
pkgdesc='Linux for MBP 15.2 Wifi'
_srctag=v${pkgver%.*}-${pkgver##*.}
url="https://git.archlinux.org/linux.git/log/?h=v$_srctag"
arch=(x86_64)
license=(GPL2)
makedepends=(
  kmod libelf pahole cpio perl tar xz 
#  xmlto python-sphinx python-sphinx_rtd_theme graphviz imagemagick
  git
)
options=('!strip')

major_version=${pkgver%.*.*}
kernbase="v${major_version}.x"
kernsha=$(curl -s "https://cdn.kernel.org/pub/linux/kernel/${kernbase}/sha256sums.asc" | grep "linux-${pkgver}.tar.xz" | cut  -d' ' -f1)

source=(
  https://www.kernel.org/pub/linux/kernel/v${pkgver//.*}.x/linux-${pkgver}.tar.xz
  https://www.kernel.org/pub/linux/kernel/v${pkgver//.*}.x/linux-${pkgver}.tar.sign
  config         # the main kernel config file

  # Apple SMC ACPI support
  3001-applesmc-convert-static-structures-to-drvdata.patch
  3002-applesmc-make-io-port-base-addr-dynamic.patch
  3003-applesmc-switch-to-acpi_device-from-platform.patch
  3004-applesmc-key-interface-wrappers.patch
  3005-applesmc-basic-mmio-interface-implementation.patch
  3006-applesmc-fan-support-on-T2-Macs.patch
  3007-applesmc-Add-iMacPro-to-applesmc_whitelist.patch
  3008-applesmc-make-applesmc_remove-void.patch
  3009-applesmc-battery-charge-limiter.patch

  # T2 USB Keyboard/Touchpad support
  4003-HID-apple-Add-support-for-MacBookPro15-2-keyboard-tr.patch
  
  # Hack for i915 overscan issues
  7001-drm-i915-fbdev-Discard-BIOS-framebuffers-exceeding-h.patch

  # Broadcom WIFI/BT device support
  8014-ACPI-property-Support-strings-in-Apple-_DSM-props.patch
  8015-brcmfmac-acpi-Add-support-for-fetching-Apple-ACPI-pr.patch
  8016-brcmfmac-pcie-Provide-a-buffer-of-random-bytes-to-th.patch
)

validpgpkeys=(
  'ABAF11C65A2970B130ABE3C479BE3E4300411886'  # Linus Torvalds
  '647F28654894E3BD457199BE38DBBDC86092693E'  # Greg Kroah-Hartman
)

export KBUILD_BUILD_HOST=archlinux
export KBUILD_BUILD_USER=$pkgbase
export KBUILD_BUILD_TIMESTAMP="$(date -Ru${SOURCE_DATE_EPOCH:+d @$SOURCE_DATE_EPOCH})"

prepare() {
  export KERNELVERSION=$kernstable
  cd $_srcname

  local src
  for src in "${source[@]}"; do
    src="${src%%::*}"
    src="${src##*/}"
    [[ $src = *.patch ]] || continue
    echo "Applying patch $src..."
    patch -Np1 < "../$src"
  done

  echo "Setting config..."
  cp ../config .config
  make olddefconfig
  make prepare

  echo "Setting version..."
  scripts/setlocalversion 
  echo "-$pkgrel" > localversion.10-pkgrel
  echo "${pkgbase#linux}" > localversion.20-pkgname

  make -s kernelrelease > version
  echo "Prepared $pkgbase version $(<version)"
}

build() {
  cd $_srcname
  make all
}

_package() {
  pkgdesc="The $pkgdesc kernel and modules"
  depends=(coreutils kmod initramfs)
  optdepends=('crda: to set the correct wireless channels of your country'
              'linux-firmware: firmware images needed for some devices')
  provides=(VIRTUALBOX-GUEST-MODULES WIREGUARD-MODULE)
  replaces=(virtualbox-guest-modules-arch wireguard-arch)
  provides=("linux=$pkgver")

  cd $_srcname
  local kernver="$(<version)"
  local modulesdir="$pkgdir/usr/lib/modules/$kernver"

  echo "Installing boot image..."
  # systemd expects to find the kernel here to allow hibernation
  # https://github.com/systemd/systemd/commit/edda44605f06a41fb86b7ab8128dcf99161d2344
  install -Dm644 "$(make -s image_name)" "$modulesdir/vmlinuz"

  # Used by mkinitcpio to name the kernel
  echo "$pkgbase" | install -Dm644 /dev/stdin "$modulesdir/pkgbase"

  echo "Installing modules..."
  make INSTALL_MOD_PATH="$pkgdir/usr" INSTALL_MOD_STRIP=1 modules_install

  # remove build and source links
  rm "$modulesdir"/{source,build}
}

_package-headers() {
  pkgdesc="Headers and scripts for building modules for the $pkgdesc kernel"
  provides=("linux-headers=$pkgver")

  cd $_srcname
  local builddir="$pkgdir/usr/lib/modules/$(<version)/build"

  echo "Installing build files..."
  install -Dt "$builddir" -m644 .config Makefile Module.symvers System.map \
    localversion.* version vmlinux
  install -Dt "$builddir/kernel" -m644 kernel/Makefile
  install -Dt "$builddir/arch/x86" -m644 arch/x86/Makefile
  cp -t "$builddir" -a scripts

  # add objtool for external module building and enabled VALIDATION_STACK option
  install -Dt "$builddir/tools/objtool" tools/objtool/objtool
  # install resolve_btfids 
  install -Dt "$builddir/tools/bpf/resolve_btfids" "tools/bpf/resolve_btfids/resolve_btfids"

  # add xfs and shmem for aufs building
  mkdir -p "$builddir"/{fs/xfs,mm}

  echo "Installing headers..."
  cp -t "$builddir" -a include
  cp -t "$builddir/arch/x86" -a arch/x86/include
  install -Dt "$builddir/arch/x86/kernel" -m644 arch/x86/kernel/asm-offsets.s

  install -Dt "$builddir/drivers/md" -m644 drivers/md/*.h
  install -Dt "$builddir/net/mac80211" -m644 net/mac80211/*.h

  # http://bugs.archlinux.org/task/13146
  install -Dt "$builddir/drivers/media/i2c" -m644 drivers/media/i2c/msp3400-driver.h

  # http://bugs.archlinux.org/task/20402
  install -Dt "$builddir/drivers/media/usb/dvb-usb" -m644 drivers/media/usb/dvb-usb/*.h
  install -Dt "$builddir/drivers/media/dvb-frontends" -m644 drivers/media/dvb-frontends/*.h
  install -Dt "$builddir/drivers/media/tuners" -m644 drivers/media/tuners/*.h

  echo "Installing KConfig files..."
  find . -name 'Kconfig*' -exec install -Dm644 {} "$builddir/{}" \;

  echo "Removing unneeded architectures..."
  local arch
  for arch in "$builddir"/arch/*/; do
    [[ $arch = */x86/ ]] && continue
    echo "Removing $(basename "$arch")"
    rm -r "$arch"
  done

  echo "Removing broken symlinks..."
  find -L "$builddir" -type l -printf 'Removing %P\n' -delete

  echo "Removing loose objects..."
  find "$builddir" -type f -name '*.o' -printf 'Removing %P\n' -delete

  echo "Stripping build tools..."
  local file
  while read -rd '' file; do
    case "$(file -bi "$file")" in
      application/x-sharedlib\;*)      # Libraries (.so)
        strip -v $STRIP_SHARED "$file" ;;
      application/x-archive\;*)        # Libraries (.a)
        strip -v $STRIP_STATIC "$file" ;;
      application/x-executable\;*)     # Binaries
        strip -v $STRIP_BINARIES "$file" ;;
      application/x-pie-executable\;*) # Relocatable binaries
        strip -v $STRIP_SHARED "$file" ;;
    esac
  done < <(find "$builddir" -type f -perm -u+x ! -name vmlinux -print0)

  echo "Stripping vmlinux..."
  strip -v $STRIP_STATIC "$builddir/vmlinux"

  echo "Adding symlink..."
  mkdir -p "$pkgdir/usr/src"
  ln -sr "$builddir" "$pkgdir/usr/src/$pkgbase"
}

pkgname=("$pkgbase" "$pkgbase-headers")
for _p in "${pkgname[@]}"; do
  eval "package_$_p() {
    $(declare -f "_package${_p#$pkgbase}")
    _package${_p#$pkgbase}
  }"
done

sha256sums=(
"$kernsha"                                                         #    Linix kernel
'SKIP'	                                                           #    Linux kernel sig
'644c8f2fdaa25d1536fec9f1b40d4d69f850c9dd45466df2539e53fc118df4e7' #    config
'5cbab182eb9b02b5b4a922c86dcc4fcd5b3a9d10ffa3de742a4a1143bf2697fc' #    3001-applesmc-convert-static-structures-to-drvdata.patch
'8d8401a99a9dfbc41aa2dc5b6a409a19860b1b918465e19de4a4ff18de075ea3' #	3002-applesmc-make-io-port-base-addr-dynamic.patch
'08d165106fe35b68a7b48f216566951a5db0baac19098c015bcc81c5fcba678d' #	3003-applesmc-switch-to-acpi_device-from-platform.patch
'62f6d63815d4843ca893ca76b84a9d32590a50358ca0962017ccd75a40884ba8' #	3004-applesmc-key-interface-wrappers.patch
'2827dab6eeb2d2a08034938024f902846b5813e967a0ea253dc1ea88315da383' #	3005-applesmc-basic-mmio-interface-implementation.patch
'398dec7d54c6122ae2263cd5a6d52353800a1a60fd85e52427c372ea9974a625' #	3006-applesmc-fan-support-on-T2-Macs.patch
'e1b0db1924e953efa7d20b8efcdc6e6bccee3199ddd83d47dc9f35720aad5974' #    3007-applesmc-Add-iMacPro-to-applesmc_whitelist.patch
'7c35ba15e034028611d1b8a4f121e42476739529114cfc28a271834e9bc68764' #    3008-applesmc-make-applesmc_remove-void.patch
'a6ef2074a1fef11b82851eba2ab2e1cd7e67a6f140fa5b462e5c8dda38798bf1' #    3009-applesmc-battery-charge-limiter.patch
'89538d96a3ce3630069b625a1ad43a1dc93c3457c783041cdfdc3417c12e96cb' #	4003-HID-apple-Add-support-for-MacBookPro15-2-keyboard-tr.patch
'90a6012cdd8a64ede8e0bbaf7331960bd68f628e0973b65459188eb1ccb5b829' #	7001-drm-i915-fbdev-Discard-BIOS-framebuffers-exceeding-h.patch
'fc899329773452ac7d17c8c6efa4ade8b522dfdfb0316e203bf2e21bfd49420a' #	8014-ACPI-property-Support-strings-in-Apple-_DSM-props.patch
'f7e24890ff03d4a720df2f34ce3c646930f411eb51909e3bb75c968623c34c60' #    8015-brcmfmac-acpi-Add-support-for-fetching-Apple-ACPI-pr.patch
'6f5f8dcde1f114eec35cf05e89ce75cf6a5c07fb061de5c3f7db1f8b50381ce3' #    8016-brcmfmac-pcie-Provide-a-buffer-of-random-bytes-to-th.patch
)
