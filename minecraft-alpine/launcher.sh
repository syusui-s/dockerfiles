#!/bin/sh
set -e -x

require() {
	hash "$1" 1>/dev/null 2>&1 || (
		echo "There is no command: $1. Please contact 'syusui-s'." >&2
		exit 1
	)
}

require jq
require java

# Enable debug output
if ( test -n "${DEBUG}" ); then
	set -x
fi

# Enable process monitoring
if ( tty 1>/dev/null 2>&1 ); then
	set -m
else
	(
		echo "There is no TTY. The launcher requires TTY to manage jobs."
		echo "To enable TTY, plese use \"--tty\" option when \"docker run\"."
	) >> &2
	exit 1
fi

EULA_FILE=eula.txt
FIFO=mcfifo
VERSIONS_URL="https://launchermeta.mojang.com/mc/game/version_manifest.json"

: ${MAX_HEAP:="1024M"}
: ${MIN_HEAP:="512M"}
: ${GCTHREADS:="1"}
: ${EULA:="0"}
: ${JAVA_PARAMS:=-Xmx${MAX_HEAP} -Xms${MIN_HEAP} -XX:ParallelGCThreads=${GCTHREADS}}

if ( test ! -f "${EULA_FILE}" ); then
	(
		echo "#By changing the setting below to TRUE you are indicating your agreement to our EULA"
		echo "(https://account.mojang.com/documents/minecraft_eula)."
		echo "#$(LC_ALL=C date)"
		echo "eula=$(test "${EULA}" -eq 1 && echo "true" || echo "false")"
	) >> "${EULA_FILE}"
fi

while ( grep -q -i 'false' "${EULA_FILE}" ); do
	(
		echo "        You need to agree to the EULA of Minecraft!"
		echo
		echo "Read this: https://account.mojang.com/documents/minecraft_eula."
		echo "If you agree it, set enviroment variable "EULA" to "1"."
		echo "e.g. docker run -it -e EULA=1 syusui/minecraft-alpine"
	) >> &2

	exit 1
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
