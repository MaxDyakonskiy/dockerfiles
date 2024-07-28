# CryptoPro 5.0 with Kontur and Gosuslugi plugins included.
# Inspired by: https://github.com/YuraBeznos/cryptopro-in-container/blob/master/Dockerfile

# New features in contrast with YuraBeznos'es dockerfile:
# 1) CryptoPro 5.0 instead of 4.3.
# 2) 'stable-slim' Debian instead of the full-weight 'stable'.
# 4) We use 'dumb-init'.
# 5) The container is run by an unprivileged user.
# 6) Automatically activate free trial license for 90 days and save it in a cache.
# 7) Cosmetic improvements.

# https://docs.docker.com/reference/dockerfile/#run
# https://docs.docker.com/reference/cli/docker/image/pull/
# https://hub.docker.com/layers/library/debian/stable/images/sha256-901c590afaefc0a6be156c6eb5dd8fb0a01f52613b9fb06da338e506241e0fa3?context=explore

# We don't use Alpine distribution because officially CryptoPro has no support 
# for this distribution.
# We don't include hash for the Debian distribution because officially CryptoPro
# won't bind itself to a particular release number.

FROM debian:stable-slim
WORKDIR /
ENV \
	DEBIAN_FRONTEND=noninteractive \
	PATH="${PATH}:/opt/cprocsp/bin/:/opt/cprocsp/sbin/"

# Plugins from the official sites of the CryptoPro, Kontur and Gosuslugi.
ADD cryptopro-linux-amd64-deb.tgz /cryptopro
COPY diag.plugin_amd64.001815.deb IFCPlugin-x86_64.deb /cryptopro

# 'libccid' >= 1.4.2: required by the Rutoken smart cards;
# 'libpcsclite1'required by the Rutoken smart cards;
# 'libsm6': session management.
# 'opensc': libs and utils for working with smart cards;
# 'pcscd': required by the Rutoken smart cards;
# 'pcsc-tools': scripts for smart cards;
# 'whiptail': required by the official CryptoPro installation scriot;

# We are using' type=cache' because CryptoPro won't be always opened on the system.
RUN --mount=type=cache,target=/var/cache/apt <<EOF
	apt update
	apt install -y libccid pcscd libpcsclite1 
	apt install -y whiptail 
	apt install -y pcsc-tools opensc libgtk2.0-0 libcanberra-gtk-module libcanberra-gtk3-0 libsm6 firefox-esr
EOF


RUN --mount=type=cache,target=/var/cache/apt \
	apt install dumb-init
# From here, we are using JSON syntax so 'dumb-init' can be fulle operatable:
# https://github.com/Yelp/dumb-init
ENTRYPOINT ["/usr/bin/dumb-init", "--"]

# https://docs.docker.com/build/building/best-practices/
RUN <<EOF
	groupadd --system my_cryptopro
	useradd --no-log-init --system --create-home --gid my_cryptopro my_cryptopro
EOF
USER my_cryptopro:my_cryptopro

RUN --mount=type=cache,target=/var/cache/apt <<EOF
	cd /cryptopro/cryptopro-linux-amd64-deb
	???

