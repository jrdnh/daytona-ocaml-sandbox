FROM golang:1.24-alpine AS file_watcher_builder

WORKDIR /src/file-watcher

COPY file-watcher/go.mod file-watcher/go.sum ./
RUN go mod download

COPY file-watcher/ ./
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /out/file-watcher .

FROM ocaml/opam:debian-ocaml-5.4

USER root
RUN apt-get update && apt-get install -y curl git pkg-config libssl-dev && rm -rf /var/lib/apt/lists/*
RUN OPENCODE_VERSION=$(curl -sL https://api.github.com/repos/anomalyco/opencode/releases/latest | sed -n 's/.*"tag_name": *"v\([^"]*\)".*/\1/p') && \
    curl -fSL "https://github.com/anomalyco/opencode/releases/download/v${OPENCODE_VERSION}/opencode-linux-x64.tar.gz" -o /tmp/opencode.tar.gz && \
    tar -xzf /tmp/opencode.tar.gz -C /usr/local/bin && \
    chmod 755 /usr/local/bin/opencode && \
    rm /tmp/opencode.tar.gz
RUN chown -R opam:opam /home/opam/.cache 2>/dev/null; \
    mkdir -p /home/opam/.cache/dune/db/temp && \
    chown -R opam:opam /home/opam/.cache

# Configure opencode
RUN mkdir -p /home/opam/.config/opencode
COPY --chown=opam:opam ./files/opencode.jsonc /home/opam/.config/opencode/opencode.json
COPY --chown=opam:opam ./files/orcaset-instructions.md /home/opam/.config/opencode/orcaset-instructions.md
RUN chmod 644 /home/opam/.config/opencode/opencode.json /home/opam/.config/opencode/orcaset-instructions.md
RUN mkdir -p /orcaset && chown opam:opam /orcaset && chmod 700 /orcaset
COPY --from=file_watcher_builder /out/file-watcher /usr/local/bin/file-watcher
RUN chmod 755 /usr/local/bin/file-watcher

USER opam

RUN opam install -y ocaml-lsp-server ocamlformat dune piaf && \
    opam pin add -y orcaset https://github.com/Orcaset/orcaset-oc.git

ENV PATH="/home/opam/.opam/default/bin:${PATH}"

WORKDIR /orcaset

RUN echo 'eval $(opam env)' >> ~/.bashrc && \
    echo 'eval $(opam env)' >> ~/.profile
