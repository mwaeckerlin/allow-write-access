# Write Access to Docker Volume in Compose

Docker Image that Allows Write Access to the Docker Container User on a Persistent Volume, i.e. to be used in Docker Compose, Docker Swarm, Kubernets.

## Why This Is Needed

When you attach volumes to a Docker service, the files and directories are typically owned by `root` (user ID 0). This creates permission issues when your containerized application tries to write to these mounted volumes, as most containers run as a non-root user for security reasons.

This image solves this problem by:
1. Running a command that changes ownership of `/app` to the container's non-root user (`somebody` by default)
2. Keeping the container running indefinitely with `sleep infinity`
3. Providing a minimal, secure solution with only essential utilities

## Usage

Use this as a sidecar container in your docker-compose setup to grant write access to shared volumes:

```yaml
services:
  allow-write-access:
    image: mwaeckerlin/allow-write-access:latest
    volumes:
      - app-data:/app

  your-app:
    image: your-app-image
    volumes:
      - app-data:/app
    depends_on:
      - allow-write-access

volumes:
  app-data:
```

The `allow-write-access` service will change the ownership of the `/app` directory in the shared volume, allowing `your-app` to write to it.

### Multiple Volumes

You can attach multiple volumes at or below `/app`:

```yaml
services:
  allow-write-access:
    image: mwaeckerlin/allow-write-access:latest
    volumes:
      - vol1:/app/vol1
      - vol2:/app/vol2

  your-app:
    image: your-app-image
    volumes:
      - vol1:/app/vol1
      - vol2:/app/vol2
    depends_on:
      - allow-write-access

volumes:
  vol1:
  vol2:
```

This image is designed to be used in docker-compose, Docker Swarm, or Kubernetes where the container should not terminate (hence `sleep infinity`).

## Benefits

- **Minimal Size**: Only contains essential binaries (busybox and dynamic linker)
- **Security**: Reduced attack surface with minimal executables
- **Flexibility**: Can be used as an init container or standalone utility container
- **Simplicity**: Single command to fix volume permissions

## Building

Build and push the image:

```bash
docker-compose build
docker-compose push
```

## Based On

This image is based on:
- [mwaeckerlin/very-base](https://github.com/mwaeckerlin/very-base) - Minimal Alpine image with user definitions
- [mwaeckerlin/scratch](https://github.com/mwaeckerlin/scratch) - Base image with environment variables like `ALLOW_USER`

## How It Works

The image uses a multi-stage build to extract only the necessary binaries:

1. **Build Stage**: Extracts `/bin/chown`, `/bin/sh`, `/bin/sleep`, `/bin/busybox` and the dynamic linker from `mwaeckerlin/very-base`
2. **Final Stage**: Creates an ultra-minimal image based on `mwaeckerlin/scratch` containing only these executables

The binaries `/bin/chown`, `/bin/sh`, and `/bin/sleep` are symbolic links to `/bin/busybox`, which is a multi-call binary that provides implementations of many Unix utilities in a single executable.

