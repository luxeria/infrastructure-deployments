# Dokuwiki

This deployments hosts a PHP webserver to serve
[wiki.luxeria.ch](https://wiki.luxeria.ch). using the official `php` Docker
container.

## Volumes

The `wiki` folder contains a standard Dokuwiki installation. Care needs to be
taken that the filesystem owner ("`chown` permissions") of that folder has the
same `UID:GID` inside the container too. The `UID:GID` of the container process
can be changed via the `DOKUWIKI_{UID,GID}` environment variables in the
`docker-compose.yaml`.

To backup the current state of the wiki, simply copy the whole `wiki/` folder
to a secure location. The `wiki/` folder _most not be committed to git_ as it
contains (hashed) password credentials and (unencrypted) internal wiki pages.

## Upgrading Dokuwiki

The Dokuwiki can be updated either via it's own web interface, or by extracting
a newer version into the `wiki/` folder. 
See [dokuwiki.org/install:upgrade](https://www.dokuwiki.org/install:upgrade)
for more details.

## Upgrading PHP

The deployment uses a floating tag for the PHP container, which always points
to the latest stable PHP 8.x version. This mean that whenever the container
images are re-pulled, that it will upgrade the PHP version.

To pull in new image versions, run:

```console
$ docker compose pull
$ docker compose down && docker compose up -d
```

## Changes to the default PHP setup

This deployment is based on the official `php` Docker image which contains an
Apache2 server with `mod_php` enabled. To make it work for our purposes, there
are a few things we need to change in that container. All those changes are
done via `dokuwiki_setup.sh`:

 - We need to enable Apache2's `mod_rewrite`. This is needed such that Dokuwiki
   displays nice URLs via the `wiki/.htaccess`
   ([docs](https://www.dokuwiki.org/rewrite))
 - We set the Apache2 server name. This is not strictly necessary, but Apache2
   will emit a warning if it's not set.
 - We enable the production-mode `php.ini` as strongly recommended by the `php`
   Docker image [README](https://github.com/docker-library/docs/blob/master/php/README.md#configuration)
 - If the `DOKUWIKI_{UID,GID}` environment variables are set, we check if a user
   and group with this UID/GID exists. If not, we create it via
   `useradd`/`groupadd`.
  - Finally, we set and export the `APACHE_RUN_{USER,GROUP}` *name* to the
    user and group with the numeric id found in `DOKUWIKI_{UID,GID}`.
    This ensures that Apache2 and the PHP process (and therefore Dokuwiki itself)
    will run with that user. This ensures that we have the proper user permissions
    when accessing the shared `wiki/` volume.