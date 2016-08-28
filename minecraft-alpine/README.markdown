# mincreaft-alpine : Minecraft Server on Alpine Linux

## Features
* Light-weight: about 110MB.
* Complying with Copyright: does NOT include a server program.
* Useful options: selecting a version, the number of threads for GC, etc.

## Build
``` sh
$ docker build -t minecraft-server:latest --rm=true .
```

## Run
A "--tty" option is **required** because a launcher script requires it.

Example:

``` sh
# enable --tty, --interactive
$ docker run -t -i \
	-e EULA=1 \
	-e GCTHREADS=4 \
	-p 25565:25565 \
	-v /opt/docker_volumes/minecraft-xxxx:/srv/minecraft \
	-v /etc/localtime:/etc/localtime:ro \
	minecraft-server:latest
```

## Options
* To agree to Minecraft license: `-e EULA=1` (default: `0` = do NOT agree)
* Port assignment: `-p HOST_PORT:CONTAINER_PORT`
* Volume mounting: `-v HOST_DIR:CONTAINER_DIR`
* # of Threads for GC: `-e GCTHREADS=4` (default: `1`)
* Selecting version: `-e VERSION=1.7.3` (default: latest release)
* Specifying a jar file: `-e EXEC_JAR=forge-1.7.10-10.13.4.1614-1.7.10-universal.jar` (default: latest release)
	* If you specify this, you should download a jar manually and [add it to a container](https://docs.docker.com/engine/reference/commandline/cp/) or place it on a mountpoint to /srv/minecraft.
* Heap size: `-e MAX_HEAP=2048M` (default: `1024M`), `-e MIN_HEAP=512M` (default: `512M`)
* To detach : `Ctrl-p Ctrl-q` (if you created a container with -i option)
