# daytona-snapshot

A Docker image intended for use as a [Daytona.io](https://daytona.io) snapshot. It has `opencode` and an OCaml 5.4 development environment with [orcaset](https://github.com/Orcaset/orcaset-oc) and common tooling pre-installed.

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
  -t opencode-orcaset-oc-snapshot:$(cat VERSION) \
  .
```
Build for Daytona which requires AMD64 architecture.

```sh
docker build \
  --platform=linux/amd64 \
  --build-arg VERSION=$(cat VERSION) \
  -t opencode-orcaset-oc-snapshot:$(cat VERSION) \
  --load \
  .
```

## Running the image

Start an interactive shell inside the container:

```sh
docker run --rm -it opencode-orcaset-oc-snapshot:$(cat VERSION)
```

Run the pre-built scaffold project directly:

```sh
docker run --rm opencode-orcaset-oc-snapshot:$(cat VERSION) bash -lc 'eval $(opam env) && dune exec myproject'
```

## Push to Daytona

```sh
daytona snapshot push opencode-orcaset-oc-snapshot:$(cat VERSION) \
  --name opencode-orcaset-oc-snapshot:$(cat VERSION) \
  --disk 1 \
  --cpu 1 \
  --memory 1
```

Create a sandbox from the snapshot:

```sh
daytona sandbox create \
  --snapshot opencode-orcaset-oc-snapshot:$(cat VERSION) \
  --auto-delete 0 \
  --env $(cat .env)
```

## Inspecting the version label

After building, you can verify the embedded version label:

```sh
docker inspect --format '{{ index .Config.Labels "org.opencontainers.image.version" }}' opencode-orcaset-oc-snapshot:$(cat VERSION)
```
