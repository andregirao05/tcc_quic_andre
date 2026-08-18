#!/usr/bin/env bash
set -e

# --- Automação da troca de chaves com o container "mininet-host" -----------
# O mininet-host gera o par de chaves e publica em /shared-ssh (volume
# nomeado compartilhado). Aqui só copiamos pra ~/.ssh (que é o volume
# persistente dev_ssh) e confiamos a host key automaticamente — dispensa
# rodar upload_ssh_key.sh manualmente.
SHARED=/shared-ssh
mkdir -p ~/.ssh
chmod 700 ~/.ssh

if [ ! -f ~/.ssh/id_ecdsa ]; then
    echo "Aguardando chave SSH do mininet-host..."
    for _ in $(seq 1 30); do
        [ -f "$SHARED/id_ecdsa" ] && break
        sleep 1
    done
    if [ -f "$SHARED/id_ecdsa" ]; then
        cp "$SHARED/id_ecdsa" ~/.ssh/id_ecdsa
        cp "$SHARED/id_ecdsa.pub" ~/.ssh/id_ecdsa.pub
        chmod 600 ~/.ssh/id_ecdsa
        echo "Chave SSH instalada."
    else
        echo "Aviso: chave SSH do mininet-host não apareceu a tempo — rode" \
             "upload_ssh_key.sh manualmente se precisar."
    fi
fi

# Confia a host key do mininet-host automaticamente (rede isolada local,
# sem essa etapa o BatchMode do withSSH() falharia no primeiro acesso).
if ! ssh-keygen -F mininet-host >/dev/null 2>&1; then
    ssh-keyscan -H mininet-host >> ~/.ssh/known_hosts 2>/dev/null || true
fi

exec "$@"
