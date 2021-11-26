FROM archlinux:latest

RUN pacman -Syu --noconfirm --needed base-devel gnupg bc kmod libelf pahole cpio perl tar xz xmlto python-sphinx python-sphinx_rtd_theme graphviz imagemagick git ; \
useradd builder -m -u 1001; \
su builder -c 'gpg --recv-key 38DBBDC86092693E' ; \
mkdir /build ; \
chown -R builder: /build

COPY entrypoint.sh /entrypoint.sh

WORKDIR /build

ENTRYPOINT ["/entrypoint.sh"]
