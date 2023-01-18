# Run Warsaw in a container

# Base docker image
FROM debian:bullseye-slim

LABEL maintainer "Fabio Rodrigues Ribeiro <farribeiro@gmail.com>"

ENV USER=ff

ENV USER_ID=1000

ENV GROUP=ff

ENV GROUP_ID=1000

ARG LANG_FILE="pt_BR.UTF-8 UTF-8"

RUN apt-get update && \
	apt-get upgrade -y && \
	apt-get install init -y && \
	apt-get install -y --no-install-recommends \
		locales \
		tzdata \
		ca-certificates \
		firefox-esr \
		firefox-esr-l10n-pt-br \
		libnss3-tools \
		procps \
		python3-gpg \
		python3 \
		xauth \
		zenity \
		nautilus
	# Setup locale
RUN echo ${LANG_FILE} > /etc/locale.gen \
	&& locale-gen
	# Downloading warsaw
RUN mkdir -p /src
ADD https://cloud.gastecnologia.com.br/cef/warsaw/install/GBPCEFwr64.deb /src/warsaw.deb
	# Configuring the environment
RUN mkdir -p /run/user/$USER_ID \
	&& groupadd -g $GROUP_ID -r $GROUP \
	&& useradd -u $USER_ID -r -g $GROUP_ID -G audio,video $USER -m -d /home/$USER \
	&& chown $USER_ID:$GROUP_ID /run/user/$USER_ID \
	&& chmod 700 /run/user/$USER_ID \
	# Cleanup
	&& apt autoremove -y \
	&& apt clean

COPY root.sh /usr/local/bin/
COPY startup.sh /usr/local/bin/
RUN chmod 700 /usr/local/bin/root.sh \
    && chmod 755 /usr/local/bin/startup.sh

# Autorun Firefox
ENTRYPOINT /usr/local/bin/root.sh
