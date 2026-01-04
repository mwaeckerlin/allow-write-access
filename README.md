# Docker Image that Allows Write Access to the Docker Container User on a Persistent Volume

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
  wp-access-fix:
    image: mwaeckerlin/allow-write-access:latest
    volumes:
      - app-data:/app

  your-app:
    image: your-app-image
    volumes:
      - app-data:/app
    depends_on:
      - wp-access-fix

volumes:
  app-data:
```

The `wp-access-fix` service will change the ownership of the `/app` directory in the shared volume, allowing `your-app` to write to it.

### Docker Run

You can also run it directly with Docker:

```bash
docker run -v /host/data:/app -e ALLOW_USER="chown -R somebody:somebody" mwaeckerlin/allow-write-access
```

## Environment Variables

- `ALLOW_USER`: **(Required)** Command to execute for permission management (e.g., `chown -R somebody:somebody`). This variable must be set when running the container.

  **Security Note**: The content of `ALLOW_USER` is executed directly in the shell. Only use this image in trusted environments where you control the input to this environment variable.

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
- <a href="https://github.com/mwaeckerlin/very-base">mwaeckerlin/very-base</a> - Minimal Alpine image with user definitions
- <a href="https://github.com/mwaeckerlin/scratch">mwaeckerlin/scratch</a> - Base image with environment variables like `ALLOW_USER`

## How It Works

The image uses a multi-stage build to extract only the necessary binaries:

1. **Build Stage**: Extracts `/bin/chown`, `/bin/sh`, `/bin/sleep`, `/bin/busybox` and the dynamic linker from `mwaeckerlin/very-base`
2. **Final Stage**: Creates an ultra-minimal image based on `mwaeckerlin/scratch` containing only these executables

The binaries `/bin/chown`, `/bin/sh`, and `/bin/sleep` are symbolic links to `/bin/busybox`, which is a multi-call binary that provides implementations of many Unix utilities in a single executable.

