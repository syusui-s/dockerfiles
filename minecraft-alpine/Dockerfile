FROM alpine
MAINTAINER Shusui Moyatani

ARG server_dir=/srv/minecraft
ARG exec_user=minecraft
ENV VERSION=1.9.4
ENV MAX_HEAP=1024M
ENV MIN_HEAP=512M
ENV THREADS=1
ENV EULA=0
ENV JAVA_PARAMS="-Xmx${MAX_HEAP} -Xms${MIN_HEAP} -XX:ParallelGCThreads=${THREADS}"

# Install required packages and create group and user
USER root
RUN    apk --update add openjdk8-jre curl \
	&& addgroup -g 1000 ${exec_user} \
	&& adduser -H -D -G minecraft -u 1000 minecraft \
	&& mkdir -p ${server_dir} \
	&& chown -R ${exec_user}:${exec_user} ${server_dir}

USER minecraft
WORKDIR ${server_dir}
CMD ( test -f "eula.txt" \
	||  (  test 1 -eq "${EULA}" && echo "eula=true" > "eula.txt" ) \
	||  (  echo "You need to agree to the EULA of Minecraft!" \
		&& echo "If you agree it, edit eula.txt and set \"eula\" to true." \
		&& exit 1 \
		) \
	) \
	&&  (  test -f "minecraft_server.${VERSION}.jar" \
		|| curl -O "https://s3.amazonaws.com/Minecraft.Download/versions/${VERSION}/minecraft_server.${VERSION}.jar" \
		) \
    && /usr/bin/java -jar minecraft_server.${VERSION}.jar ${JAVA_PARAMS}

# Minecraft Port
EXPOSE 25565

# Mountpoints: Settings files and Minecraft directory
VOLUME ["/srv/minecraft/"]
