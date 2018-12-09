#!/bin/sh
set -e -x

# Enable debug output
if ( test -n "${DEBUG}" ); then
	set -x
fi

# Enable process monitoring
if ( tty 1>/dev/null 2>&1 ); then
	set -m
else
	echo "There is no TTY. The launcher requires TTY to manage jobs." >&2
	echo "To enable TTY, plese use \"--tty\" option when \"docker run\"." >&2
	exit 1
fi

EULA=eula.txt
FIFO=mcfifo
VERSIONS_URL="https://launchermeta.mojang.com/mc/game/version_manifest.json"

: ${MAX_HEAP:="1024M"}
: ${MIN_HEAP:="512M"}
: ${GCTHREADS:="1"}
: ${EULA:="0"}
: ${JAVA_PARAMS:="-Xmx${MAX_HEAP} -Xms${MIN_HEAP} -XX:ParallelGCThreads=${GCTHREADS}"}

if ( test ! -f "eula.txt" ); then
	touch eula.txt
	echo -ne "#By changing the setting below to TRUE you are indicating your agreement to our EULA" >> ${EULA}
	echo -ne "(https://account.mojang.com/documents/minecraft_eula).\n" >> ${EULA}
	echo -ne "#$(LC_ALL=C date)\n" >> ${EULA}
	echo -ne "eula=$(test "${EULA}" -eq 1 && echo "true" || echo "false")\n" >> ${EULA}
fi

while ( grep -q -i 'false' ${EULA} ); do
	echo "You need to agree to the EULA of Minecraft!"
	echo "Read this: https://account.mojang.com/documents/minecraft_eula."
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

# get versions
versions="$(/usr/bin/wget -O - "${VERSIONS_URL}")"

# If specified version is latest versions
: ${VERSION:="latest-release"}
if [ "${VERSION}" = 'latest-snapshot' -o "${VERSION}" = 'latest-release' ]; then
	if [ "$VERSION" == "latest-snapshot" ];    then pattern=".latest.snapshot"
	elif [ "${VERSION}" == "latest-release" ]; then pattern=".latest.release"
	else
		exit 1 # must not come here.
	fi

	VERSION=$(echo "${versions}" | jq -r "${pattern}")

	if ( test -z "${VERSION}" ); then
		echo "Automatic VERSION generating is failed. Regex doesn't match version information. You can use this image by setting VERSION manually." >&2
		exit 1
	fi
fi

version_url="$(echo "${versions}" | jq -r ".versions[] | select(.id == \"${VERSION}\").url")"
uri_jar="$(curl "${version_url}" | jq -r ".downloads.server.url")"

: ${EXEC_JAR:="minecraft_server.${VERSION}.jar"}
: ${URI_JAR:="${uri_jar}"}

# if file not found, try to download jar
if ( ! test -f "${EXEC_JAR}" ); then
	echo "Downloading \"${EXEC_JAR}\" from \"${URI_JAR}\"..."
	/usr/bin/wget -O "${EXEC_JAR}" "${URI_JAR}"
	# if failed to download
	if ( test "$?" -ne 0); then
		echo "Couldn't download! Check the enviroment variables to container." >&2
		exit 1
	fi
fi

rm -f "$FIFO"
mkfifo "$FIFO"

trap 'echo "Received a signal, server will stop soon."; echo "stop" > "$FIFO";' HUP INT QUIT TERM

tail -n1 -f "$FIFO" | /usr/bin/java ${JAVA_PARAMS} -jar "${EXEC_JAR}" nogui &
mc_pid=$!

wait $mc_pid
echo "Server stopped."

exit 0

# vim: set ts=4 sw=4 :
