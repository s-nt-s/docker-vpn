#!/bin/sh
/usr/sbin/sshd -D &
openvpn /etc/openvpn/custom/default.ovpn
