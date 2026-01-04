# allow-write-access

Docker Image that Allows Write Access to the Docker Container User on a Persistent Volume

## Why This Is Needed

When you attach volumes to a Docker service, the files and directories are typically owned by `root` (user ID 0). This creates permission issues when your containerized application tries to write to these mounted volumes, as most containers run as a non-root user for security reasons.

This image solves this problem by:
1. Using `mwaeckerlin/very-base` as the base image, which includes the `ALLOW_USER` environment variable
2. Running a command that changes ownership of `/app` to the container's non-root user (`somebody` by default)
3. Keeping the container running indefinitely with `sleep infinity`

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
