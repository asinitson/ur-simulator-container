# Universal Robots (UR) simulator Docker container image

Docker container image for [Universal Robots (UR)](https://www.universal-robots.com)
[simulator](https://www.universal-robots.com/download/?query=simulator). Based
on the approach shown in [web-x11-container repository](https://github.com/asinitson/web-x11-container).

## How to use

### 1. Open project directory in Bash

### 2. Build and start container

* Through Docker Compose

  ```bash
  ########### Docker Compose v1
  docker-compose up
  # Rebuild and reset all internal container state
  docker-compose up --build --force-recreate --renew-anon-volumes

  ########### Docker Compose v2
  docker compose up
  # Rebuild and reset all internal container state
  docker compose up --build --force-recreate --renew-anon-volumes
  ```

* ...or directly through Docker CLI

  ```bash
  docker build --tag simulator .
  docker run \
    --interactive \
    --tty \
    --publish 8080:8080 \
    --publish 502:502 \
    --publish 29999:29999 \
    --publish 30001-30004:30001-30004 \
    --env ROBOT_MODEL=UR10 \
    --env RESOLUTION=1280x800 \
    simulator
  ```

### 3. Connect to the graphical environment

> NOTE: Start up will take some time.

Open [http://localhost:8080](http://localhost:8080) in a web browser.

## Motivation

There are several images with Universal Robots simulators. This image borrows
simulator installation instructions from [ahobsonsayers/DockURSim](https://github.com/ahobsonsayers/DockURSim),
but also has a few improvements on top that:

* Web UI layer is swapped to [noVNC](https://novnc.com), which has stable web
  client and is simple to setup.

* Newer simulator versions (starting from 5.8.*) no longer require privileged
  flag and container can run in [Rootless Docker](https://docs.docker.com/engine/security/rootless/).

* [`docker-compose`](./docker-compose.yaml) setup is added for simpler container
  startup.

* Simulator is switched into [`Remote Control`](https://robodk.com/doc/en/Robots-Universal-Robots-How-enable-Remote-Control-URe.html)
  by default and is ready to be used out of the box without UI.

* Simulator logs before switching `Remote Control` on are trimmed from
  container logs.

* Proper process management is used thanks to [supervisord](http://supervisord.org/).
  It allows filtering logs by processes, starting, stopping, auto-restarting
  simulator without restarting the container.

## Inspiration: similar container images

* https://github.com/ahobsonsayers/DockURSim
* https://github.com/jorgenfb/docker-ursim
