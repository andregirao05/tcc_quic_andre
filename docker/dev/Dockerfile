# Máquina de dev: compila o projeto e orquestra os experimentos via SSH,
# igual ao fluxo descrito em COMO_RODAR.md — só que falando com o container
# mininet-host em vez de uma VM/host físico.
FROM golang:1.19

RUN apt-get update && apt-get install -y --no-install-recommends \
        openssh-client \
        git \
        python3 \
        python3-pip \
    && rm -rf /var/lib/apt/lists/*

# scripts/mininet/resources/plot_paper_v2.py e regen_doc_figs.py (análise/figuras).
# --break-system-packages: a imagem base marca o Python do SO como "gerenciado
# externamente" (PEP 668); aqui o container é de uso único, então é seguro.
RUN pip3 install --no-cache-dir --break-system-packages numpy matplotlib pypdf

# /workspace é um bind mount do repo do host: o dono dos arquivos é o usuário
# do host, não o root do container. Sem isso, "git" (usado pelo "go build"
# para VCS stamping) recusa rodar por "dubious ownership".
RUN git config --system --add safe.directory '*'

WORKDIR /workspace

CMD ["bash"]
