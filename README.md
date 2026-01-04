# allow-write-access

Docker Image that Allows Write Access to the Docker Container User on a Persistent Volume

## Overview

This minimal Docker image provides a lightweight solution for managing file permissions on mounted volumes. It allows a container user (typically "somebody") to access and write to volumes mounted under `/app`, which is particularly useful for persistent data in containerized applications.

## Why This Image?

When running Docker containers with mounted volumes, permission issues often arise because:
- Files created in the container may have different ownership than the host user expects
- The container user may lack permissions to write to host-mounted directories
- Changing ownership requires special capabilities that aren't available in all container environments

This image solves these problems by:
1. Providing a minimal set of utilities (`chown`, `sh`, `sleep`) via busybox
2. Including only the essential dynamic linker (`ld-musl-x86_64.so.1`) for minimal attack surface
3. Offering a simple mechanism to adjust permissions on mounted volumes via the `ALLOW_USER` environment variable

## How It Works

The image uses a multi-stage build to extract only the necessary binaries:

1. **Build Stage**: Extracts `/bin/chown`, `/bin/sh`, `/bin/sleep`, `/bin/busybox` and the dynamic linker from `mwaeckerlin/very-base`
2. **Final Stage**: Creates an ultra-minimal image based on `mwaeckerlin/scratch` containing only these executables

The binaries `/bin/chown`, `/bin/sh`, and `/bin/sleep` are symbolic links to `/bin/busybox`, which is a multi-call binary that provides implementations of many Unix utilities in a single executable.

## Usage

Mount any volumes that need write access by the "somebody" user to `/app`:

```bash
docker run -v /host/data:/app -e ALLOW_USER="chown -R somebody:somebody" mwaeckerlin/allow-write-access
```

This will:
1. Execute the command specified in `ALLOW_USER` with `/app` as the target
2. Change ownership of all files in `/app` to the "somebody" user/group
3. Allow subsequent container processes to read/write to the mounted volume

## Environment Variables

- `ALLOW_USER`: Command to execute for permission management (default: should be set to change ownership, e.g., `chown -R somebody:somebody`)

## Benefits

- **Minimal Size**: Only contains essential binaries (busybox and dynamic linker)
- **Security**: Reduced attack surface with minimal executables
- **Flexibility**: Can be used as an init container or standalone utility container
- **Simplicity**: Single command to fix volume permissions
