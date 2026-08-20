#!/usr/bin/env bash
set -e

# Sobe o Open vSwitch via ovs-ctl (não depende de systemd, que não roda
# como PID 1 dentro do container).
mkdir -p /var/run/openvswitch
/usr/share/openvswitch/scripts/ovs-ctl start --system-id=random --no-mlockall

# Gera as host keys do sshd (não vêm na imagem, precisam existir no boot).
ssh-keygen -A
mkdir -p /var/run/sshd

# --- Automação da troca de chaves com o container "dev" ---------------------
# /shared-ssh é um volume nomeado compartilhado com o container "dev" (ver
# docker-compose.yml). Em vez de exigir "ssh-keygen" + "upload_ssh_key.sh"
# manualmente (o fluxo da VM real), o par de chaves é gerado uma única vez
# aqui e publicado nesse volume; o entrypoint do "dev" o consome do outro lado.
SHARED=/shared-ssh
mkdir -p "$SHARED"
if [ ! -f "$SHARED/id_ecdsa" ]; then
    ssh-keygen -q -f "$SHARED/id_ecdsa" -t ecdsa -N ""
fi

mkdir -p /home/mininet/.ssh
touch /home/mininet/.ssh/authorized_keys
if ! grep -qxF "$(cat "$SHARED/id_ecdsa.pub")" /home/mininet/.ssh/authorized_keys 2>/dev/null; then
    cat "$SHARED/id_ecdsa.pub" >> /home/mininet/.ssh/authorized_keys
fi
chown -R mininet:mininet /home/mininet/.ssh
chmod 700 /home/mininet/.ssh
chmod 600 /home/mininet/.ssh/authorized_keys

exec /usr/sbin/sshd -D -e
