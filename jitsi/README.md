# Jitsi

## Configuration

Check out the (hidden) `.env` and `${LUX_VOLUMES:?}/jitsi/secrets.env` file.

## Upgrade Guide

  1. Check for new releases on [Jitsi Meet on Docker](https://github.com/jitsi/docker-jitsi-meet/releases)
  2. Read changelog if there are configuration changes needed
  3. Set new `JITSI_IMAGE_VERSION` to new image tag in `.env` file
  4. (optional) `docker compose pull`
  5. Run `docker compose down && docker compose up -d`

## Changes to upstream version

This deployment is based on
[jitsi/docker-jitsi-meet](https://github.com/jitsi/docker-jitsi-meet), with
the following modifications:

  - Removed `*_PASSWORD` environment variables from `environment` section and
    moved them from `.env` to `secrets.env` env-file.
  - No port-forwarding to host, i.e. all `ports` sections have been replaced
    with `expose`. This ensures no ports are opened on the host. All ports are
    still reachable via the container's IP address though.
  - Traefik labels added to `web` and `jvb` containers. Those replace the
    aforementioned port-forwards.
  - Added external `traefik` network to all containers with traefik labels.
  - Renamed default network (`meet.jitsi`) and added an network alias instead.
  - `JITSI_IMAGE_VERSION` environment variable is mandatory and does not have
    any fallback.
  - Disabled HTTPS (and removed web:443 port), TLS termination is handled by
    Traefik.
  - Added `branding` container to serve `DYNAMIC_BRANDING_URL` via Traefik.
