FROM archlinux:latest

RUN pacman-key --init &&\
pacman -Syu --noconfirm --needed base-devel gnupg bc kmod libelf pahole cpio perl tar xz xmlto python-sphinx python-sphinx_rtd_theme graphviz imagemagick git archlinux-keyring keyutils && \
useradd builder -m -u 1001 && \
su builder -c 'gpg --recv-keys 38DBBDC86092693E' &&\
mkdir /build && \
chown -R builder: /build

COPY entrypoint.sh /entrypoint.sh

WORKDIR /build

ENTRYPOINT ["/entrypoint.sh"]
