# Android Mobile Preview via Tailscale

Use this when you want to check the MacBook-hosted site from an Android phone outside the same Wi-Fi network.

## One-time setup

1. Install Tailscale on the MacBook and the Android phone.
2. Sign in to the same Tailscale account on both devices.
3. Confirm the MacBook has a Tailscale IPv4 address:

```bash
tailscale ip -4
```

## Run the site from the MacBook

This project is a static `index.html` site, so a simple local server is enough:

```bash
cd /Users/dorm/coding/tennis-homepage
python3 -m http.server 8000 --bind 0.0.0.0
```

## Open from Android

On the Android phone, open Chrome and use the MacBook Tailscale IP:

```text
http://<macbook-tailscale-ip>:8000
```

Example:

```text
http://100.x.y.z:8000
```

## Data flow

For the current static version, the phone loads the page and JSON data files from the MacBook server.

Later, if the project adds a local API or database process, keep the database private on the MacBook and expose only the web/API server through Tailscale:

```text
Android Chrome -> MacBook Tailscale web/API server -> MacBook local DB
```

Avoid opening a database port directly to the phone.
