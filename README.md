# Build Dynomite

The `build-dynomite` container provides a clean, reusable and immutable build environment in which to compile Dynomite.

Compiling Dynomite has two discrete steps:

1. Build the `build-dynomite` Docker image (automated via DockerHub)
2. Compile Dynomite

# Compile Dynomite

Run the `build-dynomite` container to compile Dynomite.

## Options

`build-dynomite` supports optional flags:

- `-v tag-version`: Specify a tagged release to build based on GitHub tags. If `-v` is not used then the `dev` branch is used for the build. Specifying `-v` without a `tag-version` will result in a build error.
- `-d [mode]`: Default mode is `production` which disables logging. `debug` mode which causes `dynomite` to output debug level logs. Possible values: `debug`, `log`. `production`.
- `-t target`: Specify a `make` build target.

## Build tagged version

Build Dynomite using a tagged version. For example, to build the tagged release `v0.5.8` execute the command below.

```bash
docker run -it --rm -v $PWD:/src dynomitedb/build-dynomite -v v0.5.8
```

## Build fake version

You can build Dynomite using a fake version. A fake version builds the `HEAD` of the `dev` branch, yet uses the fake version for the `.deb` package.

For example, to build a fake version of `0.5.8` execute the command below.

> Notice how the fake version does not use a `v` prefix. This is deliberately different from a tagged release.

```bash
docker run -it --rm -v $PWD:/src dynomitedb/build-dynomite -F 0.5.8
```

## Build `dev` branch

Build Dynomite using the `dev` branch.

```bash
docker run -it --rm -v $PWD:/src dynomitedb/build-dynomite
```

## Build debug binary

Create a debug build.

```bash
docker run -it --rm -v $PWD:/src dynomitedb/build-dynomite -d debug
```

# Manually build the `build-dynomite` image

The `build-dynomite` Docker image is automatically built via DockerHub at https://hub.docker.com/r/dynomitedb/build-dynomite.

The instructions below allow you to manually build the `build-dynomite` image, if required.

Clone the `docker-build-dynomite` repo from Github.

```bash
mkdir -p ~/repos/ && cd $_

git clone https://github.com/DynomiteDB/docker-build-dynomite.git
```

`cd` into the `build-dynomite` directory.

```bash
cd ~/docker-build-dynomite
```

Create the `build-dynomite` image.

```bash
docker build -t dynomitedb/build-dynomite .
```
