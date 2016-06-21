FROM alpine
MAINTAINER Shusui Moyatani

ARG server_dir=/srv/minecraft
ARG exec_user=minecraft

# Install required packages and create group and user
USER root
RUN    apk --update add openjdk8-jre curl \
	&& addgroup -g 1000 ${exec_user} \
	&& adduser -H -D -G ${exec_user} -u 1000 ${exec_user} \
	&& mkdir -p ${server_dir} \
	&& chown -R ${exec_user}:${exec_user} ${server_dir}

USER ${exec_user}
WORKDIR ${server_dir}

# add launcher script
STOPSIGNAL SIGTERM
ADD launcher.sh launcher.sh

CMD exec /bin/sh launcher.sh

# Minecraft Port
EXPOSE 25565

# Mountpoints: Settings files and Minecraft directory
VOLUME ["${server_dir}"]
