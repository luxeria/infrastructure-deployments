# LuXeria Infrastructure Docker Compose Files

All deployments are found in `/var/data/Deployments`. We store the corresponding
volumes (i.e. everything which should not be part of this git tree) in a
separate path under `/var/data/Volumes`, to allow for easy backup and inspection
than `docker volume` mounts.

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