FROM debian:jessie

# global environment settings
ENV HOME="/config" \
    DEBIAN_FRONTEND="noninteractive" \
    TERM="xterm"

RUN apt-get update && \
# OpenVPN user
    useradd --system --uid 864 -M openvpn && \
# Install transmission
    apt-get install -y \
	openvpn \
	sudo

# Ports and volumes
EXPOSE 9091
VOLUME ["/config", "/keys"]

# Entrypoint
COPY openvpn /openvpn

CMD ["/bin/sh", "/openvpn/start.sh"]

