# Matterbridge

[Matterbridge](https://github.com/42wim/matterbridge) forwards messages between
the Luxeria Telegram IRC channel, the Luxeria Discord server, and the Libra Chat
IRC channel.

## Containers

### `matterbridge`

Matterbridge is configured via `matterbridge.toml`. This file contains
credentials, _do not commit it into git_. We make use of the
[MediaServer](https://github.com/42wim/matterbridge/wiki/Mediaserver-setup-(advanced))
feature, which will upload images received on Telegram or Discord and show them
as links in IRC. All uploaded files are stored in the `media` folder
(which is also not commited into git).

### `media`

The `media` container contains an nginx server which serves the files uploaded
to `/media` via Traefik on `telegram.luxeria.ch`. It is configured via the
`nginx.conf` which ensures that only media files (i.e. images and videos) are
shown in the browser, while all other files (e.g. HTML, JS etc) can only be
downloaded, but not rendered or executed in a browser.
