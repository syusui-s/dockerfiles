FROM alpine
MAINTAINER Shusui Moyatani

ARG server_dir=/srv/minecraft
ARG exec_user=minecraft
ENV VERSION=1.10
ENV EXEC_JAR="minecraft_server.${VERSION}.jar"
ENV URI_JAR="https://s3.amazonaws.com/Minecraft.Download/versions/${VERSION}/${EXEC_JAR}"
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
CMD (  ( test -f "eula.txt" ) \ 
	|| ( test 1 -eq "${EULA}" && echo "eula=true" > "eula.txt" ) \
	|| (   echo "You need to agree to the EULA of Minecraft!" \
		&& echo "Read this: <https://account.mojang.com/documents/minecraft_eula>." \
		&& echo "If you agree it, edit eula.txt and set \"eula\" to true." \
		&& exit 1 \
	   ) \
	) \
	&&  (  test -f "${EXEC_JAR}" \
		|| curl -o ${EXEC_JAR} ${URI_JAR} \
		) \
    && /usr/bin/java -jar ${EXEC_JAR} ${JAVA_PARAMS}

# Minecraft Port
EXPOSE 25565

# Mountpoints: Settings files and Minecraft directory
VOLUME ["${server_dir}"]
