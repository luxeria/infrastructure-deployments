# LuXeria Infrastructure Docker Compose Files

This repository contains the [Docker Compose](https://docs.docker.com/compose/)
deployments used in our infrastructure.
All deployments are found in `/var/data/Deployments`.

## Host-mounted Volumes

When specifying the host part of a `volumes` section, please use one of the
following two patterns:

 - `./config:/var/app/config:ro`: For read-only configuration files which can be
   committed to git. They will be stored in the same directory as the
   `docker-compose.yaml` file.
 - `${LUX_VOLUMES:?}/data:/var/app/data`: For application data that the
   container may write to, and for sensitive configuration (e.g. credentials).
   Those will be stored in a separate directory outside the git tree.

On our server, the `LUX_VOLUMES` environment is set to `/var/data/Volumes` in
`/etc/environment` (for user sessions) and in the systemd service file below
(for systemd). For local testing, you may set it to a different directory.

The `:?` part of `${LUX_VOLUMES:?}` will make `docker compose` commands error
out if the variable is not set.

Please do not use [Docker external named volumes](https://docs.docker.com/storage/volumes/),
as they are harder to inspect, backup and transfer between hosts.

## Managing services via systemd

All deployments are managed via the `docker-compose@` systemd service unit.
Please make sure that the `docker compose up` command of a deployment does not
depend on resources owned by other services, since this systemd unit starts
all services in parallel.

To make sure a newly deployment is supervised by systemd after boot, run the
following command (e.g. for a deployment stored in the `foobar/` folder):

```console
$ systemctl enable docker-compose@foobar.service
```

The service unit behind all of this is found in
`/etc/systemd/system/docker-compose@.service`:


```ini
[Unit]
Description=%i service with docker compose
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=true
Environment=LUX_VOLUMES=/var/data/Volumes
WorkingDirectory=/var/data/Deployments/%i
ExecStart=/usr/bin/docker compose up -d --remove-orphans
ExecStop=/usr/bin/docker compose down
TimeoutStartSec=5m

[Install]
WantedBy=multi-user.target
```

## Docker Configuration

The `/etc/docker/daemon.json` on the host looks as follows:

```json
{
  "default-address-pools" : [
    {
      "base" : "172.18.0.0/16",
      "size" : 24
    }
  ],
  "log-driver": "journald"
}
```

#### Rationale

##### `default-address-pools`:

We use different default address pool to

 1. avoid overlap with other routable subnets in the `172.16.0.0/12` range
 2. use smaller default subnets (/24 instead of /16) to preserve IP space

You can still manually create docker networks outside of this default subnet
using `docker network create --ip-range`.

##### `log-driver`:

Using `journald` for logging ensures logs are persistently stored independently
of the Docker lifecycle. To inspect the logs for a particular container, run:

```
journalctl CONTAINER_NAME=foobar
```