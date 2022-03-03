#!/bin/sh
set -e

SSH_PORT="52033"
SYS_NAME="svpn"
SYS_DOCK="dvpn"
SSH_TARG="trb"

if [ $# -lt 1 ]; then
    echo "Usage: $scriptname start | stop"
    exit 1
fi

# https://unix.stackexchange.com/questions/83806/how-to-kill-ssh-session-that-was-started-with-the-f-option-run-in-background

case "$1" in

start)

  echo "Starting socket to $SSH_TARG"
  sudo systemctl start ${SYS_DOCK}
  ssh -M -S ~/.ssh/$SYS_NAME.control -fNTD 127.0.0.1:$SSH_PORT $SSH_TARG
  ssh -S ~/.ssh/$SYS_NAME.control -O check $SSH_TARG
  echo "Socket running in 127.0.0.1:$SSH_PORT"
  ;;

stop)
  echo "Stopping socket to $3"
  ssh -S ~/.ssh/$SYS_NAME.control -O exit $SSH_TARG

 ;;

*)
  echo "Did not understand your argument, please use start|stop"
  ;;

esac
