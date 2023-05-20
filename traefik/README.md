# Traefik

Traefik is a cloud-native reverse-proxy. It it responsible for exposing other
deployments/containers to the Internet.

## Configuration

To expose a Docker container to to Internet via Traefik, you will not have to
change any configuration here. Instead, this can be achieved by adding labels
to your Docker container. See [https://doc.traefik.io/traefik/providers/docker/] for details.

Our Traefik configuration allows services and routes to be defines from two
sources: Firstly via Docker (see above) and secondly via
[Dynamic File Configuration](https://doc.traefik.io/traefik/providers/file/).
To define non-Docker services, middlewares and routes via file, put them into
the `conf.d` folder. At the moment, we mainly use this to protect and expose the
Traefik dashboard on an internal entry point.

## Docker API Access

To avoid having to mount the Docker Unix domain socket
(which effectively grants root access to the host) directly into the `router`
container (which is exposed to the Internet), we have a `dockerapi` container,
which exposes the Docker API in a safer manner.

It does this by mounting the Unix domain socket itself, filtering out all write
and most read API calls (i.e. the ones listed in `dockerapi.environment`), and
exposing this on an internal TCP port. This thereby limits the damage that a
hijacked Traefik container could do.

See [Tecnativa/docker-socket-proxy](https://github.com/Tecnativa/docker-socket-proxy)
for details.