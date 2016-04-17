# Build Dynomite

The `build-dynomite` container provides a clean, reusable and immutable build environment in which to compile Dynomite.

Compiling Dynomite has two discrete steps:

1. Build the `build-dynomite` Docker image (automated via DockerHub)
2. Compile Dynomite

# Compile Dynomite

Run the `build-dynomite` container to compile the Dynomite.

Clone and then `cd` into the `dynomite` git repo.

```bash
mkdir -p ~/repos/ && cd $_

git clone https://github.com/Netflix/dynomite.git

cd ~/repos/dynomite

# Optionally, you can select a specific tag to build
git checkout tags/v0.5.8
```

Build Dynomite using a tagged version. For example, to build the tagged release `v0.5.7` execute the command below.

```bash
docker run -it --rm -v $PWD:/src dynomitedb/build-dynomite -v v0.5.7
```

Build Dynomite using the `dev` branch.

```bash
docker run -it --rm -v $PWD:/src dynomitedb/build-dynomite
```

Create a debug build.

```bash
docker run -it --rm -v $PWD:/src dynomitedb/build-dynomite -d
```

Clean the build. 

```bash
docker run -it --rm -v $PWD:/src dynomitedb/build-dynomite -t clean
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
