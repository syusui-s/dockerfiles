# mincreaft-alpine : Minecraft Server on Alpine Linux

## Build
``` sh
$ docker build -t minecraft-server:latest --rm=true .
```

## Exec
* To agree to Minecraft license: `-e EULA=1`
* Port settings: `-p HOST_PORT:CONTAINER_PORT`
* Volume setting: `-v HOST_DIR:CONTAINER_DIR`
* To detach : `Ctrl-p Ctrl-q`

Example:

``` sh
$ docker run -t -i -e EULA=1 -p 25565:25565 -v /home/user/docker/minecraft-xxxx:/srv/minecraft minecraft-server:latest
```
