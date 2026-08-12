#!/usr/bin/env bash
set -e

# Sobe o Open vSwitch via ovs-ctl (não depende de systemd, que não roda
# como PID 1 dentro do container).
mkdir -p /var/run/openvswitch
/usr/share/openvswitch/scripts/ovs-ctl start --system-id=random --no-mlockall

# Gera as host keys do sshd (não vêm na imagem, precisam existir no boot).
ssh-keygen -A
mkdir -p /var/run/sshd

exec /usr/sbin/sshd -D -e
