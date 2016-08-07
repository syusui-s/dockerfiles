#!/bin/sh

# Enable debug output
set -x

# Enable process monitoring
set -m

: ${VERSION:=1.10}
: ${EXEC_JAR:="minecraft_server.${VERSION}.jar"}
: ${URI_JAR:="https://s3.amazonaws.com/Minecraft.Download/versions/${VERSION}/${EXEC_JAR}"}
: ${MAX_HEAP:="1024M"}
: ${MIN_HEAP:="512M"}
: ${GCTHREADS:="1"}
: ${EULA:="0"}
: ${JAVA_PARAMS:="-Xmx${MAX_HEAP} -Xms${MIN_HEAP} -XX:ParallelGCThreads=${GCTHREADS}"}

EULA=eula.txt
FIFO=mcfifo

# when file doesn't exist and EULA is set to 1
if ( ! test -f "eula.txt" ); then
	touch eula.txt
	echo -ne "#By changing the setting below to TRUE you are indicating your agreement to our EULA" >> ${EULA}
	echo -ne "(https://account.mojang.com/documents/minecraft_eula).\n" >> ${EULA}
	echo -ne "#$(LC_ALL=C date)\n" >> ${EULA}
	echo -ne "eula=$(test "${EULA}" -eq 1 && echo "true" || echo "false")\n" >> ${EULA}
fi

while ( grep -q -i 'false' ${EULA} ); do
	echo "You need to agree to the EULA of Minecraft!"
	echo "Read this: <https://account.mojang.com/documents/minecraft_eula>."
	echo "If you agree it, edit eula.txt and set \"eula\" to true."
	echo ""
	echo -n "Do you want to edit eula.txt? (y/n): "
	read answer
	if ( test "$answer" != "n" ); then
		/bin/sh
	else
		echo "quit setup." >&2
		exit 1
	fi
done

# if file not found, try to download jar
if ( ! test -f "${EXEC_JAR}" );then
	echo "Downloading \"${EXEC_JAR}\" from \"${URI_JAR}\"..."
	curl -o "${EXEC_JAR}" "${URI_JAR}"
	# if failed to download
	if ( test "$?" -ne 0); then
		echo "Couldn't download! Check the enviroment variables to container."
		exit 1
	fi
fi

rm -f $FIFO
mkfifo $FIFO

trap 'echo "container will be stopped manually"; echo "stop" > "$FIFO"; wait; rm -f "$FIFO"; exit 0' SIGTERM SIGINT

echo >> $FIFO &
/usr/bin/java ${JAVA_PARAMS} -jar "${EXEC_JAR}" nogui < $FIFO &

wait
