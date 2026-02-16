FROM ocaml/opam:debian-ocaml-5.4

ARG VERSION=0.1.0
LABEL org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.title="daytona-snapshot" \
      org.opencontainers.image.description="Daytona.io snapshot image with OCaml and orcaset"

RUN opam install -y ocaml-lsp-server ocamlformat dune && \
    opam pin add -y orcaset https://github.com/Orcaset/orcaset-oc.git

WORKDIR /home/opam/project

RUN echo '(lang dune 3.0)' > dune-project && \
    mkdir -p bin && \
    echo '(executable (name main))' > bin/dune && \
    echo 'let () = print_endline "Hello, OCaml!"' > bin/main.ml

RUN eval $(opam env) && dune build
