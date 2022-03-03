#!/bin/bash

SSH_PORT="52032"
SYS_NAME="dvpn"

ENLACE="/etc/systemd/system/$SYS_NAME.service"

if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo "Necesita ejecutar como root"
    exit 1
fi

if [ "$1" == "--rm" ]; then
  if [ -f "$ENLACE" ]; then
    systemctl stop "$SYS_NAME"
    systemctl disable "$SYS_NAME"
    rm "$ENLACE"
  fi
  docker container stop "${SYS_NAME}"
  docker container rm "${SYS_NAME}"
  docker image rm "${SYS_NAME}"
  docker system prune --force
  exit 0
fi

set -e

cd "$(dirname "$0")"

if [ ! -f "config/authorized_keys" ]; then
  echo "Falta el fichero config/authorized_keys"
  exit 1
fi
if [ ! -f "config/default.ovpn" ]; then
  echo "Falta el fichero config/default.ovpn"
  exit 1
fi

if ! docker image inspect "${SYS_NAME}:latest" >/dev/null 2>&1; then
  docker build -t "${SYS_NAME}" .
fi

if [ -e "$ENLACE" ]; then
  echo "Ya existe un servicio con ese nombre:"
  echo -n -e "\t"
  ls -l "$ENLACE"
  exit 1
fi

# https://blog.marcnuri.com/docker-container-as-linux-system-service/

cat > "$ENLACE" <<EOL
[Unit]
Description=${SYS_NAME} container
After=docker.service
Wants=network-online.target docker.socket
Requires=docker.socket

[Service]
Restart=always
ExecStartPre=/bin/bash -c "/usr/bin/docker container inspect ${SYS_NAME} 2> /dev/null || /usr/bin/docker run --privileged -p ${SSH_PORT}:22 -d -P --name ${SYS_NAME} ${SYS_NAME}"
ExecStart=/usr/bin/docker start -a ${SYS_NAME}
ExecStop=/usr/bin/docker stop -t 10 ${SYS_NAME}

[Install]
WantedBy=multi-user.target
EOL

echo "Servicio creado:"
echo -n -e "  "
ls -l "$ENLACE"
echo "Falta habilitarlo e iniciarlo:"
echo "  sudo systemctl daemon-reload"
echo "  sudo systemctl enable ${SYS_NAME}.service"
echo "  sudo systemctl start ${SYS_NAME}.service"
