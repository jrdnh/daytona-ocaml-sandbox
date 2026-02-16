# daytona-snapshot

A Docker image intended for use as a [Daytona.io](https://daytona.io) snapshot. It provides an OCaml 5.4 development environment with [orcaset](https://github.com/Orcaset/orcaset-oc) and common tooling pre-installed.

## What's included

- **OCaml 5.4** (via the `ocaml/opam` base image)
- **Dune** build system
- **ocaml-lsp-server** and **ocamlformat**
- **orcaset** (pinned from source)
- A minimal scaffold project under `/home/opam/project`

## Version

The current version is tracked in the `VERSION` file at the root of this repository. The same value is embedded in the image as an [OCI label](https://github.com/opencontainers/image-spec/blob/main/annotations.md) (`org.opencontainers.image.version`).

## Building the image

Read the version from the `VERSION` file and pass it as a build argument:

```sh
docker build \
  --build-arg VERSION=$(cat VERSION) \
  -t orcaset-oc-snapshot:$(cat VERSION) \
  .
```

You can also tag it as `latest` at the same time:

```sh
docker build \
  --build-arg VERSION=$(cat VERSION) \
  -t orcaset-oc-snapshot:$(cat VERSION) \
  -t orcaset-oc-snapshot:latest \
  .
```

## Running the image

Start an interactive shell inside the container:

```sh
docker run --rm -it orcaset-oc-snapshot:$(cat VERSION)
```

Run the pre-built scaffold project directly:

```sh
docker run --rm orcaset-oc-snapshot:$(cat VERSION) bash -lc 'eval $(opam env) && dune exec myproject'
```

## Inspecting the version label

After building, you can verify the embedded version label:

```sh
docker inspect --format '{{ index .Config.Labels "org.opencontainers.image.version" }}' orcaset-oc-snapshot:$(cat VERSION)
```
