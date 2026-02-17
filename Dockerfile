FROM ocaml/opam:debian-ocaml-5.4

ARG VERSION=0.1.0
LABEL org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.title="daytona-snapshot" \
      org.opencontainers.image.description="Daytona.io snapshot image with OCaml and orcaset"

USER root
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*
RUN OPENCODE_VERSION=$(curl -sL https://api.github.com/repos/anomalyco/opencode/releases/latest | sed -n 's/.*"tag_name": *"v\([^"]*\)".*/\1/p') && \
    curl -fSL "https://github.com/anomalyco/opencode/releases/download/v${OPENCODE_VERSION}/opencode-linux-x64.tar.gz" -o /tmp/opencode.tar.gz && \
    tar -xzf /tmp/opencode.tar.gz -C /usr/local/bin && \
    chmod 755 /usr/local/bin/opencode && \
    rm /tmp/opencode.tar.gz
RUN chown -R opam:opam /home/opam/.cache 2>/dev/null; \
    mkdir -p /home/opam/.cache/dune/db/temp && \
    chown -R opam:opam /home/opam/.cache
USER opam

RUN opam install -y ocaml-lsp-server ocamlformat dune && \
    opam pin add -y orcaset https://github.com/Orcaset/orcaset-oc.git

WORKDIR /home/opam/project

RUN echo '(lang dune 3.0)' > dune-project && \
    mkdir -p bin && \
    echo '(executable (name main))' > bin/dune && \
    echo 'let () = print_endline "Hello, OCaml!"' > bin/main.ml

RUN echo 'eval $(opam env)' >> ~/.bashrc && \
    echo 'eval $(opam env)' >> ~/.profile && \
    eval $(opam env) && dune build
