[![Docker Pulls](https://img.shields.io/docker/pulls/cypz/guacamole-light?label=pulls) ![Docker Stars](https://img.shields.io/docker/stars/cypz/guacamole-light?label=stars)](https://hub.docker.com/r/cypz/guacamole-light)

# Docker Guacamole

**THIS REPO IS A FORK  OF [jwetzell/docker-guacamole](https://github.com/jwetzell/docker-guacamole/) WHICH WAS A CONTINUATION OF [oznu/docker-guacamole](https://github.com/oznu/docker-guacamole).**

A Docker Container for [Apache Guacamole](https://guacamole.apache.org/), a client-less remote desktop gateway. It supports standard protocols like VNC, RDP, and SSH over HTML5.

This image will run on most platforms that support Docker including Docker for Mac, Docker for Windows, Synology DSM and Raspberry Pi 3 boards.

[![IMAGE ALT TEXT](http://img.youtube.com/vi/esgaHNRxdhY/0.jpg)](http://www.youtube.com/watch?v=esgaHNRxdhY "Video Title")

This container runs the guacamole web client and the guacd server.

## Usage (arm64 only)

```shell
docker run \
  -p 8080:8080 \
  -v </path/to/config>:/config \
  cypz/guacamole-light:arm64v8
```

## Parameters

The parameters are split into two halves, separated by a colon, the left hand side representing the host and the right the container side.

* `-p 8080:8080` - Binds the service to port 8080 on the Docker host, **required**
* `-v /config` - The config location, **required**

Currently no extensions are available in this build, only guacamole-auth-noauth. The app is meant to be installed behind a reverse proxy and the auth to be delegated (for example to authelia)


```yml
version: '3.6'
services:
  guacamole:
    container_name: guacamole
    image: cypz/guacamole-light:arm64
    restart: unless-stopped
    ports:
      - 8080:8080
    environment:
      - GUACD_HOSTNAME=guacd
      - GUACAMOLE_HOME=/config/guacamole/
    volumes:
      - guacamole-data:/config/ # Copy in this volume your file (/config/guacamole/noauth-config.xml) containing your custom connections (RDP/SSH/VNC) based on the template
volumes:
    guacamole-data:
```

  ## Patch guacamole with no auth extension

  See https://stackoverflow.com/questions/63051901/bypassing-the-login-page-in-guacamole-1-2-0

  for how to use an old extension such as the no auth extension:

  > Sure enough changing the version of the extension worked! guacamole-auth-noauth-0.9.14.jar is not compatible by default but if you change the .jar extension to .zip extract, edit guac_manifest.json to replace "0.9.14" with "1.2.0", re-zip (or replace), and optionally rename the whole thing guacamole-auth-noauth-1.2.0.jar (to avoid confusion) you end up with a working extension provided all other standard configuration steps are followed as well."
