# syntax=docker/dockerfile:1

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
USER root
WORKDIR /
ENV \
	DEBIAN_FRONTEND=noninteractive \
	PATH="${PATH}:/opt/cprocsp/bin/:/opt/cprocsp/sbin/"

# Plugins from the official sites of the CryptoPro, Kontur and Gosuslugi.
# ADD cryptopro-linux-amd64-deb.tgz /cryptopro/
COPY diag.plugin_amd64.001815.deb IFCPlugin-x86_64.deb /cryptopro/

# 'libccid' >= 1.4.2: required by the Rutoken smart cards;
# 'libpcsclite1'required by the Rutoken smart cards;
# 'libsm6': session management.
# 'opensc': libs and utils for working with smart cards;
# 'pcscd': required by the Rutoken smart cards;
# 'pcsc-tools': scripts for smart cards;
# 'whiptail': required by the official CryptoPro installation scriot;

# We are using' type=cache' because CryptoPro won't be always opened on the system.
RUN <<EOF
	apt update
	apt install -y libccid pcscd libpcsclite1 
	apt install -y whiptail 
	apt install -y pcsc-tools opensc libgtk2.0-0 libcanberra-gtk-module \
    libcanberra-gtk3-0 libsm6 firefox-esr
EOF


RUN apt install dumb-init
# From here, we are using JSON syntax for 'CMD', so 'dumb-init' is fully operable:
# https://github.com/Yelp/dumb-init
ENTRYPOINT ["/usr/bin/dumb-init", "--"]

# https://docs.docker.com/build/building/best-practices/
RUN <<EOF
	groupadd --system my_cryptopro
	useradd --no-log-init --system --create-home --gid my_cryptopro my_cryptopro
EOF
# USER my_cryptopro:my_cryptopro

WORKDIR /cryptopro
RUN <<EOF
	sudo apt install -y cryptopro-linux-amd64-deb/lsb-cprocsp-base_5.0.13000-7_all.deb cryptopro-linux-amd64-deb/lsb-cprocsp-rdr-64_5.0.13000-7_amd64.deb cryptopro-linux-amd64-deb/lsb-cprocsp-kc1-64_5.0.13000-7_amd64.deb cryptopro-linux-amd64-deb/lsb-cprocsp-capilite-64_5.0.13000-7_amd64.deb cryptopro-linux-amd64-deb/cprocsp-curl-64_5.0.13000-7_amd64.deb cryptopro-linux-amd64-deb/lsb-cprocsp-ca-certs_5.0.13000-7_all.deb cryptopro-linux-amd64-deb/cprocsp-cptools-gtk-64_5.0.13000-7_amd64.deb cryptopro-linux-amd64-deb/cprocsp-pki-cades-64_2.0.15000-1_amd64.deb cryptopro-linux-amd64-deb/cprocsp-rdr-cloud-64_5.0.13000-7_amd64.deb cryptopro-linux-amd64-deb/cprocsp-rdr-cpfkc-64_5.0.13000-7_amd64.deb cryptopro-linux-amd64-deb/cprocsp-rdr-cryptoki-64_5.0.13000-7_amd64.deb cryptopro-linux-amd64-deb/cprocsp-rdr-edoc-64_5.0.13000-7_amd64.deb cryptopro-linux-amd64-deb/cprocsp-rdr-emv-64_5.0.13000-7_amd64.deb cryptopro-linux-amd64-deb/cprocsp-rdr-gui-gtk-64_5.0.13000-7_amd64.deb cryptopro-linux-amd64-deb/cprocsp-rdr-infocrypt-64_5.0.13000-7_amd64.deb cryptopro-linux-amd64-deb/cprocsp-rdr-inpaspot-64_5.0.13000-7_amd64.deb cryptopro-linux-amd64-deb/cprocsp-rdr-jacarta-64_5.0.13000-7_amd64.deb cryptopro-linux-amd64-deb/cprocsp-rdr-kst-64_5.0.13000-7_amd64.deb cryptopro-linux-amd64-deb/cprocsp-rdr-mskey-64_5.0.13000-7_amd64.deb cryptopro-linux-amd64-deb/cprocsp-rdr-novacard-64_5.0.13000-7_amd64.deb cryptopro-linux-amd64-deb/cprocsp-rdr-pcsc-64_5.0.13000-7_amd64.deb cryptopro-linux-amd64-deb/cprocsp-rdr-rosan-64_5.0.13000-7_amd64.deb cryptopro-linux-amd64-deb/cprocsp-rdr-rustoken-64_5.0.13000-7_amd64.deb cryptopro-linux-amd64-deb/cprocsp-rdr-rutoken-64_5.0.13000-7_amd64.deb cryptopro-linux-amd64-deb/lsb-cprocsp-import-ca-certs_5.0.13000-7_all.deb cryptopro-linux-amd64-deb/lsb-cprocsp-kc2-64_5.0.13000-7_amd64.deb cryptopro-linux-amd64-deb/lsb-cprocsp-pkcs11-64_5.0.13000-7_amd64.deb cryptopro-linux-amd64-deb/cprocsp-pki-plugin-64_2.0.15000-1_amd64.deb
    apt install -y ./diag.plugin_amd64.001815.deb ./IFCPlugin-x86_64.deb
EOF

CMD ["firefox"]

# https://ananyamudgal21.medium.com/how-to-run-gui-application-in-the-docker-container-4aca7c635930
# docker run --interactive --tty --env="DISPLAY" --net=host ...
