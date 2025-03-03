# Points

Various tidbits that have yet to make it into a more formal doc.

## WSL behind a firewall

Find the magic proxy incantations and add to `/etc/apt/apt.conf.d/proxy.conf`. At one of my jobs:

```
Acquire::http::Proxy "the http:// to the proxy";
Acquire::https::Proxy "the https:// to the proxy";
```

## WSL starts as root

Add these lines to `/etc/wsl.conf`:

```
[user]
default=matthew
```
