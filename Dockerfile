# Run Warsaw in a container

# Base docker image
FROM debian:bullseye-slim

LABEL maintainer "Fabio Rodrigues Ribeiro <farribeiro@gmail.com>"

ARG USER=ff

ARG GUID=1000

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
		openssl \
		procps \
		python3-gpg \
		python3-openssl \
		python3 \
		xauth \
		zenity
	# Setup locale
RUN echo ${LANG_FILE} > /etc/locale.gen \
	&& locale-gen
	# Downloading warsaw
RUN mkdir -p /src
ADD https://cloud.gastecnologia.com.br/cef/warsaw/install/GBPCEFwr64.deb /src/GBPCEFwr64.deb
	# Configuring the environment
RUN mkdir -p /home/${USER} \
	&& groupadd -g ${GUID} -r ${USER} \
	&& useradd -u ${GUID} -r -g ${USER} -G audio,video ${USER} -d /home/${USER} \
	&& chown -R ${GUID}:${GUID} /home/${USER} \
	&& mkdir -p /run/user/${GUID} \
	&& chown ${GUID}:${GUID} /run/user/${GUID} \
	&& chmod 700 /run/user/${GUID} \
	# Cleanup
	&& apt autoremove -y \
	&& apt clean

# Very cursed workaround for "not PID 1"
RUN mv /bin/systemctl /bin/systemctl.bak \
	&& apt -y install /src/GBPCEFwr64.deb

COPY root.sh /usr/local/bin/
COPY startup.sh /usr/local/bin/
RUN chmod 700 /usr/local/bin/root.sh \
    && chmod 755 /usr/local/bin/startup.sh

# Add volume for receipts PDFs
VOLUME "/home/ff/Downloads"

# Autorun Firefox
ENTRYPOINT /usr/local/bin/root.sh
