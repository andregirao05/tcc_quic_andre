# Container que substitui a VM do Mininet (VirtualBox) usada em COMO_RODAR.md.
# Login mininet/mininet + sudo sem senha, igual à imagem oficial da VM, para
# que scripts/mininet/*.sh funcionem sem nenhuma alteração — só apontando o
# <IP> para o hostname deste serviço no docker-compose (ex.: "mininet-host").
FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

# O pacote "mininet" do apt (Ubuntu 20.04) só traz bindings Python 2 —
# server_scheduler_test.py é Python 3. Por isso o Mininet e o controller de
# referência são instalados a partir do código-fonte oficial (com
# PYTHON=python3), igual ao que "util/install.sh -nf" faz na VM oficial.
RUN apt-get update && apt-get install -y --no-install-recommends \
        openvswitch-switch \
        openssh-server \
        sudo \
        iperf \
        iproute2 \
        iputils-ping \
        net-tools \
        telnet \
        python3 \
        python3-pip \
        python3-setuptools \
        xauth \
        ca-certificates \
        git \
        build-essential \
        autoconf \
        automake \
        libtool \
        pkg-config \
        help2man \
    && rm -rf /var/lib/apt/lists/*

RUN git clone --depth 1 https://github.com/mininet/mininet /tmp/mininet-src \
    && cd /tmp/mininet-src \
    && PYTHON=python3 make install \
    && cd / && rm -rf /tmp/mininet-src

# Controller OpenFlow de referência ("controller" binary): sem ele, o
# Mininet não encontra nenhum DefaultController e Mininet() levanta exceção
# ao montar a topologia, mesmo para uma rede simples de switch único.
RUN git clone --depth 1 https://github.com/mininet/openflow /tmp/openflow-src \
    && cd /tmp/openflow-src \
    && ./boot.sh && ./configure && make controller/controller \
    && install -D controller/controller /usr/bin/controller \
    && cd / && rm -rf /tmp/openflow-src

# Usuário mininet (senha "mininet", só usada uma vez pelo upload_ssh_key.sh
# para instalar a chave pública) com sudo sem senha, como na VM oficial —
# os scripts remotos rodam "sudo ..." sem esperar prompt.
RUN useradd -m -s /bin/bash mininet \
    && echo 'mininet:mininet' | chpasswd \
    && echo 'mininet ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/mininet \
    && chmod 0440 /etc/sudoers.d/mininet \
    && mkdir -p /home/mininet/.ssh \
    && chown mininet:mininet /home/mininet/.ssh \
    && chmod 700 /home/mininet/.ssh

RUN sed -i 's/#\?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config \
    && sed -i 's/#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config

EXPOSE 22

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
