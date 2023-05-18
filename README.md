# LuXeria Infrastructure Docker Compose Files

These are found in `/var/data/Deployments` and started via the following
systemd service unit (`/etc/systemd/system/docker-compose@.service`):

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

