# Maintainer:  kernel.old <kernel.old@gmail.com>
# Contributor: James Lambert (jamlam) <jamesl@mbert.onmicrosoft.com>
# Contributor: Aun-Ali Zaidi <admin@kodeit.net>
# Contributor: Jan Alexander Steffens (heftig) <jan.steffens@gmail.com>

pkgbase=linux-mbp15
# get latest stable kernel version to build
mainversion=5.18
kernstable=$(curl -s https://www.kernel.org/ | grep -A1 'stable:' | grep  "$mainversion" | grep -oP '(?<=strong>).*(?=</strong.*)')
#pkgver=5.17.1
pkgver=$kernstable
_srcname=linux-${pkgver}
pkgrel=1
pkgdesc='Linux for MBP 15.2 Wifi'
_srctag=v${pkgver%.*}-${pkgver##*.}
url="https://git.archlinux.org/linux.git/log/?h=v$_srctag"
arch=(x86_64)
license=(GPL2)
makedepends=(
  bc kmod libelf pahole cpio perl tar xz 
  xmlto python-sphinx python-sphinx_rtd_theme graphviz imagemagick
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

  # Arch Linux patches
  0001-ZEN-Add-sysctl-and-CONFIG-to-disallow-unprivileged-C.patch
  0002-HID-quirks-Add-Apple-Magic-Trackpad-2-to-hid_have_sp.patch

  # Hack for AMD DC eDP link rate bug
  2001-drm-amd-display-Force-link_rate-as-LINK_RATE_RBR2-fo.patch

  # Apple SMC ACPI support
  3001-applesmc-convert-static-structures-to-drvdata.patch
  3002-applesmc-make-io-port-base-addr-dynamic.patch
  3003-applesmc-switch-to-acpi_device-from-platform.patch
  3004-applesmc-key-interface-wrappers.patch
  3005-applesmc-basic-mmio-interface-implementation.patch
  3006-applesmc-fan-support-on-T2-Macs.patch

  # T2 USB Keyboard/Touchpad support
  4003-HID-apple-Add-support-for-MacBookPro15-2-keyboard-tr.patch
  
  # Hack for i915 overscan issues
  7001-drm-i915-fbdev-Discard-BIOS-framebuffers-exceeding-h.patch

  # Broadcom WIFI/BT device support
  8002-brcmfmac-firmware-Support-having-multiple-alt-paths.patch
  8003-brcmfmac-firmware-Handle-per-board-clm_blob-files.patch
  8004-brcmfmac-pcie-sdio-usb-Get-CLM-blob-via-standard-fir.patch
  8005-brcmfmac-firmware-Support-passing-in-multiple-board_.patch
  8006-brcmfmac-pcie-Read-Apple-OTP-information.patch
  8007-brcmfmac-of-Fetch-Apple-properties.patch
  8008-brcmfmac-pcie-Perform-firmware-selection-for-Apple-p.patch
  8009-brcmfmac-firmware-Allow-platform-to-override-macaddr.patch
  8010-brcmfmac-msgbuf-Increase-RX-ring-sizes-to-1024.patch
  8012-brcmfmac-pcie-Support-PCIe-core-revisions-64.patch
  8013-brcmfmac-pcie-Add-IDs-properties-for-BCM4378.patch
  8014-ACPI-property-Support-strings-in-Apple-_DSM-props.patch
  8015-brcmfmac-acpi-Add-support-for-fetching-Apple-ACPI-pr.patch
  8016-brcmfmac-pcie-Provide-a-buffer-of-random-bytes-to-th.patch
  8017-brcmfmac-pcie-Add-IDs-properties-for-BCM4355.patch
  8018-brcmfmac-pcie-Add-IDs-properties-for-BCM4377.patch
  8019-brcmfmac-pcie-Perform-correct-BCM4364-firmware-selec.patch
  8020-brcmfmac-chip-Only-disable-D11-cores-handle-an-arbit.patch
  8021-brcmfmac-chip-Handle-1024-unit-sizes-for-TCM-blocks.patch
  8022-brcmfmac-cfg80211-Add-support-for-scan-params-v2.patch
  8023-brcmfmac-feature-Add-support-for-setting-feats-based.patch
  8024-brcmfmac-cfg80211-Add-support-for-PMKID_V3-operation.patch
  8025-brcmfmac-cfg80211-Pass-the-PMK-in-binary-instead-of-.patch
  8026-brcmfmac-pcie-Add-IDs-properties-for-BCM4387.patch
)

validpgpkeys=(
  'ABAF11C65A2970B130ABE3C479BE3E4300411886'  # Linus Torvalds
  '647F28654894E3BD457199BE38DBBDC86092693E'  # Greg Kroah-Hartman
)

export KBUILD_BUILD_HOST=archlinux
export KBUILD_BUILD_USER=$pkgbase
export KBUILD_BUILD_TIMESTAMP="$(date -Ru${SOURCE_DATE_EPOCH:+d @$SOURCE_DATE_EPOCH})"

prepare() {
  cd $_srcname

  echo "Setting version..."
  scripts/setlocalversion --save-scmversion
  echo "-$pkgrel" > localversion.10-pkgrel
  echo "${pkgbase#linux}" > localversion.20-pkgname

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

  make -s kernelrelease > version
  echo "Prepared $pkgbase version $(<version)"
}

build() {
  cd $_srcname
  make all
  make htmldocs
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

  echo "Removing documentation..."
  rm -r "$builddir/Documentation"

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

_package-docs() {
  pkgdesc="Documentation for the $pkgdesc kernel"

  cd $_srcname
  local builddir="$pkgdir/usr/lib/modules/$(<version)/build"

  echo "Installing documentation..."
  local src dst
  while read -rd '' src; do
    dst="${src#Documentation/}"
    dst="$builddir/Documentation/${dst#output/}"
    install -Dm644 "$src" "$dst"
  done < <(find Documentation -name '.*' -prune -o ! -type d -print0)

  echo "Adding symlink..."
  mkdir -p "$pkgdir/usr/share/doc"
  ln -sr "$builddir/Documentation" "$pkgdir/usr/share/doc/$pkgbase"
}

pkgname=("$pkgbase" "$pkgbase-headers" "$pkgbase-docs")
for _p in "${pkgname[@]}"; do
  eval "package_$_p() {
    $(declare -f "_package${_p#$pkgbase}")
    _package${_p#$pkgbase}
  }"
done

sha256sums=(
"$kernsha"                                                         #    Linix kernel
'SKIP'	                                                           #    Linux kernel sig
'b2567db7c2cbb106aad0f7ece58579b41a9b9aabbd9beda79a55e9367529f6b8' #	config         # the main kernel config file
'6b4da532421cac5600d09c0c52742aa52d848af098f7853abe60c02e9d0a3752' #	0001-ZEN-Add-sysctl-and-CONFIG-to-disallow-unprivileged-C.patch
'2184069ab00ef43d9674756e9b7a56d15188bc4494d34425f04ddc779c52acd8' #	0002-HID-quirks-Add-Apple-Magic-Trackpad-2-to-hid_have_sp.patch
'786dfc22e4c6ece883e7dedd0ba3f6c14018584df95450b2cb78f3da8b01f7cb' #	2001-drm-amd-display-Force-link_rate-as-LINK_RATE_RBR2-fo.patch
'cfd23a06797ac86575044428a393dd7f10f06eff7648d0b78aedad82cbe41279' #	3001-applesmc-convert-static-structures-to-drvdata.patch
'8d8401a99a9dfbc41aa2dc5b6a409a19860b1b918465e19de4a4ff18de075ea3' #	3002-applesmc-make-io-port-base-addr-dynamic.patch
'08d165106fe35b68a7b48f216566951a5db0baac19098c015bcc81c5fcba678d' #	3003-applesmc-switch-to-acpi_device-from-platform.patch
'62f6d63815d4843ca893ca76b84a9d32590a50358ca0962017ccd75a40884ba8' #	3004-applesmc-key-interface-wrappers.patch
'2827dab6eeb2d2a08034938024f902846b5813e967a0ea253dc1ea88315da383' #	3005-applesmc-basic-mmio-interface-implementation.patch
'398dec7d54c6122ae2263cd5a6d52353800a1a60fd85e52427c372ea9974a625' #	3006-applesmc-fan-support-on-T2-Macs.patch
'89538d96a3ce3630069b625a1ad43a1dc93c3457c783041cdfdc3417c12e96cb' #	4003-HID-apple-Add-support-for-MacBookPro15-2-keyboard-tr.patch
'90a6012cdd8a64ede8e0bbaf7331960bd68f628e0973b65459188eb1ccb5b829' #	7001-drm-i915-fbdev-Discard-BIOS-framebuffers-exceeding-h.patch
'4491640dcb50f4684e18c7c520b044ea062f4b50cf63ac5e5eae906dc7f4f4da' #	8002-brcmfmac-firmware-Support-having-multiple-alt-paths.patch
'86dfb440034127bf37b4f2de2749bd65c0a870f6578e08a962cc177421881ff6' #	8003-brcmfmac-firmware-Handle-per-board-clm_blob-files.patch
'5d6b671a9d41d73702e93bd7d69506a5fa364a39f8e376775b59e10a4a02f137' #	8004-brcmfmac-pcie-sdio-usb-Get-CLM-blob-via-standard-fir.patch
'07831d408eaed40931eff321b6cd02ce5fcbe508578db2921aa572e8b6a9d912' #	8005-brcmfmac-firmware-Support-passing-in-multiple-board_.patch
'4cb854894f6dbf8bd33a1d6c1efdf1585975187acec963b1789e8355adca6f1b' #	8006-brcmfmac-pcie-Read-Apple-OTP-information.patch
'd7f1330c7489856c0dbdbb17eaa6248104b6db3df7b6813700ef9e6339157674' #	8007-brcmfmac-of-Fetch-Apple-properties.patch
'c84a45ea91ad72d4264a96b7aefe42b16841d239b3b20156dd72310bc7483815' #	8008-brcmfmac-pcie-Perform-firmware-selection-for-Apple-p.patch
'a42962a4fb54e29eb10510acf72467432859b99038784fb7362eee2dbf142354' #    8009-brcmfmac-firmware-Allow-platform-to-override-macaddr.patch
'bdecb89ed084a6c1a5a4b0386accfb17a9daefa4cf32602e82b12f57d0bd8310' #	8010-brcmfmac-msgbuf-Increase-RX-ring-sizes-to-1024.patch
'e6b64db9f07d36ae482d880caef567d369719cb9205c09fb0c21ed780ec36d87' #	8012-brcmfmac-pcie-Support-PCIe-core-revisions-64.patch
'bea0a94969b488e03679034ed072f3d26f208a03096e7a4609f01b94c7a50b3b' #	8013-brcmfmac-pcie-Add-IDs-properties-for-BCM4378.patch
'fc899329773452ac7d17c8c6efa4ade8b522dfdfb0316e203bf2e21bfd49420a' #	8014-ACPI-property-Support-strings-in-Apple-_DSM-props.patch
'04001dfadc6a59fa25b5589da442978617b22d96d1778916c822b45948d3579b' #    8015-brcmfmac-acpi-Add-support-for-fetching-Apple-ACPI-pr.patch	
'6f5f8dcde1f114eec35cf05e89ce75cf6a5c07fb061de5c3f7db1f8b50381ce3' #    8016-brcmfmac-pcie-Provide-a-buffer-of-random-bytes-to-th.patch
'fbdf79a09a26f7f59cac01b24c721d9246ae58e4366b0e31054fbbf17eb3b618' #	8017-brcmfmac-pcie-Add-IDs-properties-for-BCM4355.patch
'cc99dd569506748969934855d7fa14ea82b0903c09550b80ceeede91e03b7224' #	8018-brcmfmac-pcie-Add-IDs-properties-for-BCM4377.patch
'cbdccfb7d67e42cb6865763ccc89c99da0932763f8c1660759f69c52b003fb44' #	8019-brcmfmac-pcie-Perform-correct-BCM4364-firmware-selec.patch
'6e6b1638cc9836021980a096638985d2c3f2f6ed12279b03980e1f9f18659ca4' #	8020-brcmfmac-chip-Only-disable-D11-cores-handle-an-arbit.patch
'ef64c0c357b59fb437d2dba76faedf67f22ec2ab565ebc5283473a7a6ed1ff95' #	8021-brcmfmac-chip-Handle-1024-unit-sizes-for-TCM-blocks.patch
'434f466a4e80e08698467feedb121b3ffe46affd09980eb4accc29fdaba66927' #	8022-brcmfmac-cfg80211-Add-support-for-scan-params-v2.patch
'00ee4cd515a7004e1da382b7c441ab3818ed858f3f55c9b23c07eee04278d7e6' #	8023-brcmfmac-feature-Add-support-for-setting-feats-based.patch
'0c2439ccef7aff7c44995cb692fe5e4f5f2192226b55d3f4a291c97fc51a27cc' #	8024-brcmfmac-cfg80211-Add-support-for-PMKID_V3-operation.patch
'7a8ada03d2504fe11108bfd691b93acd3f8ac5bfedc843f129037eac380ae3b5' #	8025-brcmfmac-cfg80211-Pass-the-PMK-in-binary-instead-of-.patch
'fc485aff4d0ff28ac8fa9700244ac41c3834c11f5c5d7485cf0ef4d404a65823' #	8026-brcmfmac-pcie-Add-IDs-properties-for-BCM4387.patch
)
