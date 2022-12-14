FROM debian:stable-slim

ARG UID=1000
ENV HOMEDIR /thor
ENV STEAMCMDDIR "${HOMEDIR}/steamcmd"

RUN mkdir -p ${HOMEDIR} && chmod 777 ${HOMEDIR}

RUN set -x \
	# Install, update & upgrade packages
	&& dpkg --add-architecture i386 \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends --no-install-suggests \
		lib32stdc++6 \
		lib32gcc-s1 \
		wget \
		ca-certificates \
		nano \
		curl \
		locales \
		software-properties-common \
	&& sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
	&& dpkg-reconfigure --frontend=noninteractive locales \
	# Download SteamCMD, execute as user
	&& mkdir -p ${STEAMCMDDIR} \
		&& wget -qO- 'https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz' | tar xvzf - -C ${STEAMCMDDIR} \
		&& ./${STEAMCMDDIR}/steamcmd.sh +quit \
		&& mkdir -p "${HOME}/.steam/sdk32" \
		&& ln -s "${STEAMCMDDIR}/linux32/steamclient.so" "${HOME}/.steam/sdk32/steamclient.so" \
		&& ln -s "${STEAMCMDDIR}/linux32/steamcmd" "${STEAMCMDDIR}/linux32/steam" \
		&& ln -s "${STEAMCMDDIR}/steamcmd.sh" "${STEAMCMDDIR}/steam.sh" \
	# Symlink steamclient.so; So misconfigured dedicated servers can find it
	&& ln -s "${STEAMCMDDIR}/linux64/steamclient.so" "/usr/lib/x86_64-linux-gnu/steamclient.so" \
	# Clean up
	&& apt-get remove --purge --auto-remove -y \
		wget \
	&& rm -rf /var/lib/apt/lists/* \
	&& echo $1 | ls /thor/*

WORKDIR ${HOMEDIR}