FROM alpine:latest

# https://docs.docker.com/engine/examples/running_ssh_service/
# https://unix.stackexchange.com/a/170871/235763

RUN \
apk update && \
apk add --no-cache openssh-server openvpn && \
sed -E 's|^#?AllowTcpForwarding.*|AllowTCPForwarding yes|g' -i /etc/ssh/sshd_config && \
sed -E 's|^#?ChallengeResponseAuthentication.*|ChallengeResponseAuthentication no|g' -i /etc/ssh/sshd_config && \
sed -E 's|^#?PasswordAuthentication.*|PasswordAuthentication no|g' -i /etc/ssh/sshd_config && \
adduser --disabled-password --home /home/vpn vpn && \
mkdir -p /home/vpn/.ssh

COPY config/default.ovpn /etc/openvpn/custom/default.ovpn
COPY config/init.sh /root/init.sh
COPY config/authorized_keys /home/vpn/.ssh

RUN \
chmod +x /root/init.sh && \
chmod 600 /home/vpn/.ssh/authorized_keys && \
chown vpn:vpn -R /home/vpn/.ssh && \
sed 's|^vpn:!:|vpn:*:|' -i /etc/shadow && \
/usr/bin/ssh-keygen -A

EXPOSE 22
CMD ["/root/init.sh"]
