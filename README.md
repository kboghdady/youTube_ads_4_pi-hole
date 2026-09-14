<div align="center">

# 🚫 YouTube Ads Blocklist for Pi-hole

**A community-maintained list of YouTube ad-serving domains — add one link to Pi-hole and you're done.**

<!-- Status badges: change the text/colour when something changes. update.ps1 rewrites the date automatically. -->
![Blocking status](https://img.shields.io/badge/blocking-working-brightgreen?style=for-the-badge)
![List updated](https://img.shields.io/badge/list%20updated-Sept%2014th%202026-blue?style=for-the-badge)
![Pi-hole v5 and v6](https://img.shields.io/badge/Pi--hole-v5%20%7C%20v6-96060c?style=for-the-badge&logo=pihole&logoColor=white)

<!-- Plain-text copy of the badge facts so search engines and AI assistants can read them. update.ps1 keeps it current. -->
Last updated: **Sept 14th 2026** - **15,853 domains** in the list - works with **Pi-hole v5 and v6**, **AdGuard Home**, **pfBlockerNG**, **Technitium** and any other DNS blocker that accepts a hosts-style domain list.

[![PayPal](https://img.shields.io/badge/PayPal-donate-00457C?style=for-the-badge&logo=paypal&logoColor=white)](https://paypal.me/KBoghdady?locale.x=en_US)
[![Buy Me A Coffee](https://img.shields.io/badge/Buy%20Me%20A%20Coffee-FFDD00?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black)](https://buymeacoffee.com/xmh7j53o1)

</div>

---

## 📋 Table of contents

- [Option 1 · Add the list to Pi-hole (recommended)](#-option-1--add-the-list-to-pi-hole-recommended)
- [Option 2 · Run the script](#-option-2--run-the-script)
- [Other DNS blockers (AdGuard Home, pfBlockerNG, Technitium, Blocky)](#-other-dns-blockers-adguard-home-pfblockerng-technitium-blocky)
- [What it does and doesn't do](#-what-it-does-and-doesnt-do)
- [How it works](#-how-it-works)
- [The crowd list (optional)](#-the-crowd-list-optional)
- [Troubleshooting](#-troubleshooting)
- [Privacy](#-privacy)
- [Contributing](#-contributing)
- [Support the project](#-support-the-project)

---

## ⚡ Option 1 · Add the list to Pi-hole (recommended)

The easiest way — nothing to install. Pi-hole downloads the list itself and refreshes it every time gravity updates.

1. Open the Pi-hole web interface → **Lists** (Pi-hole v6) or **Group Management → Adlists** (Pi-hole v5).
2. Paste this address into the **Address** field and click **Add**:
   ```
   https://raw.githubusercontent.com/kboghdady/youTube_ads_4_pi-hole/refs/heads/master/youtubelist.txt
   ```
3. Update gravity so the list takes effect: **Tools → Update Gravity**, or from the terminal:
   ```bash
   pihole -g
   ```

That's it. Pi-hole re-downloads the list on every gravity update (weekly by default — run `pihole -g` any time to get the latest version sooner). The published list already excludes everything in `ignore.list`, so videos keep playing.

> 💡 Using Pi-hole's default blocklist (StevenBlack hosts)? It blocks `s.youtube.com`, which breaks video playback. Allow it once:
> ```bash
> pihole allow s.youtube.com      # Pi-hole v6
> pihole -w s.youtube.com         # Pi-hole v5
> ```

---

## 🧰 Option 2 · Run the script

Prefer to have every domain as an exact entry in your denylist (visible under **Domains** in the web interface), add your own never-block entries, or pick up new domains every hour instead of at the next gravity update? Use `youtube.sh`.

Every time it runs it:

1. downloads the latest `black.list` from this repo,
2. drops everything that matches `ignore.list` (so videos keep playing),
3. adds **only the domains your Pi-hole doesn't have yet** — the first run takes a few minutes, later runs finish in seconds,
4. reloads Pi-hole's lists so the new domains are blocked right away.

It works with **Pi-hole v5 and v6**, needs nothing beyond what Pi-hole already installs, and re-runs itself with `sudo` if you forget.

### Install

```bash
git clone https://github.com/kboghdady/youTube_ads_4_pi-hole.git
cd youTube_ads_4_pi-hole
sudo ./youtube.sh
```

You should see something like:

```
  YouTube ads blocker for Pi-hole v6

  [i] Downloading the latest YouTube ad list...
  [+] 15855 domains in the list (0 skipped because of ignore.list)
  [i] Adding 15855 new domain(s) to the denylist...
  [i] This takes a few minutes the first time - later runs only add what is new
  ................................................................................
  [+] Added 15855 domain(s)
  [i] Reloading Pi-hole's lists...
  [+] Shared 12 googlevideo.com hostname(s) from your query log - thank you!

  [+] All done. Pi-hole is blocking 15855 YouTube ad domains.
```

### Keep it updated automatically

Add the script to root's crontab so it picks up new domains on its own:

```bash
sudo crontab -e
```

Add this line to run it every hour (change the path if you cloned somewhere else):

```
0 * * * * /home/pi/youTube_ads_4_pi-hole/youtube.sh > /dev/null 2>&1
```

> Tip: [crontab.guru](https://crontab.guru) explains the schedule syntax if you'd like a different interval.

### Options

| Option | What it does |
|--------|--------------|
| `--dry-run` | Show what would change without touching Pi-hole — great for a first look |
| `--no-share` | Don't send `googlevideo.com` hostnames from your query log (see [Privacy](#-privacy)) |
| `--crowd` | Also block the unfiltered crowd list (see [The crowd list](#-the-crowd-list-optional)) |
| `-h`, `--help` | Show the help text |

The same settings live at the top of `youtube.sh` if you'd rather change them permanently.

To add your own never-block entries, put them in the `ignore.list` next to the script (one per line — a full hostname or just a part of it, such as `n4v7sne7`). Your entries are merged with the latest `ignore.list` from this repo on every run.

---

## 🌐 Other DNS blockers (AdGuard Home, pfBlockerNG, Technitium, Blocky)

`youtubelist.txt` is a plain list of hostnames, one per line, so it works with any DNS-level ad blocker that can subscribe to a domain list — not only Pi-hole. Use the same address everywhere:

```
https://raw.githubusercontent.com/kboghdady/youTube_ads_4_pi-hole/refs/heads/master/youtubelist.txt
```

| Blocker | Where to add it |
|---------|-----------------|
| **AdGuard Home** | **Filters → DNS blocklists → Add blocklist → Add a custom list**, paste the URL |
| **pfBlockerNG** (pfSense) | **Firewall → pfBlockerNG → DNSBL → DNSBL Groups**, add a feed with the URL (format *Auto*) |
| **Technitium DNS** | **Settings → Blocking → Block List URLs**, add the URL |
| **Blocky** | Add the URL under `blocking.denylists` in `config.yml` |
| **OPNsense Unbound** | **Services → Unbound DNS → Blocklist**, add it as a custom blocklist URL |

Whatever you use, keep `s.youtube.com` and the hostnames in `ignore.list` allowed — they are needed for videos to play.

---

## ✅ What it does and doesn't do

**It does**

- Block the DNS lookups for known YouTube ad-serving hostnames, network-wide, on every device that uses your DNS server — smart TVs, phones, consoles and browsers alike, with nothing to install on them.
- Stop many pre-roll and mid-roll video ads from loading at all, instead of showing a skippable ad.
- Stay current: the list is refreshed every day or two from the hostnames users report (see [Privacy](#-privacy)).

**It doesn't**

- Block every ad. YouTube serves ads and videos from the same `googlevideo.com` domains and rotates them constantly; some ads will always slip through, and new hostnames take a day or two to reach the list.
- Block ads that are stitched into the video stream itself (server-side ad insertion). No DNS blocker can — that needs a browser extension such as uBlock Origin or SponsorBlock on the device.
- Remove sponsor segments, banners, or ads inside the YouTube app on devices that bypass your DNS (for example, with DNS-over-HTTPS enabled or a hard-coded DNS server).
- Track you. Option 1 sends nothing anywhere; Option 2 shares only the hostnames described under [Privacy](#-privacy), and you can turn that off.

For the best result, use this list on your DNS blocker **and** a browser extension on the devices where you can install one.

---

## 🧠 How it works

YouTube serves ads and videos from the same family of domains (`*.googlevideo.com`), so a normal blocklist can't tell them apart. This project keeps a curated list of the hostnames that only serve ads, and an `ignore.list` of the ones that break video playback. Both published lists are filtered against `ignore.list` before every update.

| File | What it is |
|------|------------|
| `youtubelist.txt` | The list to add to Pi-hole ([Option 1](#-option-1--add-the-list-to-pi-hole-recommended)) |
| `black.list` | The same list, downloaded by `youtube.sh` ([Option 2](#-option-2--run-the-script)) |
| `ignore.list` | Hostnames (or parts of them) that must **never** be blocked because they break videos |
| `crowed_list.txt` | Raw, unfiltered domains gathered from the community — see [The crowd list](#-the-crowd-list-optional) |
| `youtube.sh` | The script behind Option 2 |

The list is refreshed every day or two.

---

## 👥 The crowd list (optional)

`crowed_list.txt` contains every `googlevideo.com` hostname reported by users of the script — **including the ones that serve videos**. It blocks more ads but is far more likely to break playback.

- As a Pi-hole list: `https://raw.githubusercontent.com/kboghdady/youTube_ads_4_pi-hole/refs/heads/master/crowed_list.txt`
- With the script: `sudo ./youtube.sh --crowd` (or set `INCLUDE_CROWD_LIST=true` at the top of the script)

Only use it if you know how to find and allow a blocked hostname in Pi-hole's query log.

---

## 🛠 Troubleshooting

<details>
<summary><b>Videos won't play, keep buffering or YouTube reloads in a loop</b></summary>

1. **Make sure `s.youtube.com` isn't blocked.** Pi-hole's default list (StevenBlack hosts) includes it, and blocking it breaks playback:
   ```bash
   pihole allow s.youtube.com      # Pi-hole v6
   pihole -w s.youtube.com         # Pi-hole v5
   ```
2. **Get the latest list.** Run `pihole -g` (Option 1) or `sudo ./youtube.sh` (Option 2) — the hostname may already have been removed from the list.
3. **Find the culprit.** Open the Pi-hole query log while the video fails and look for a *blocked* `r?---sn-xxxxxxx.googlevideo.com` entry. Allow it in Pi-hole, then please [open an issue](https://github.com/kboghdady/youTube_ads_4_pi-hole/issues) or a pull request adding the `sn-xxxxxxx` part to `ignore.list` so everyone benefits. Script users can also add it to their local `ignore.list` and run `sudo ./youtube.sh` again — it removes the domain from the denylist for you.

</details>

<details>
<summary><b>Remove everything the script added</b></summary>

```bash
pihole-FTL sqlite3 /etc/pihole/gravity.db "DELETE FROM domainlist WHERE type = 1 AND domain LIKE '%googlevideo.com';"
pihole reloadlists                  # Pi-hole v6
pihole restartdns reload-lists      # Pi-hole v5
```

If you also want the other ad domains gone (`doubleclick.net`, `googlesyndication.com`, …), delete by the comment the script writes instead:

```bash
pihole-FTL sqlite3 /etc/pihole/gravity.db "DELETE FROM domainlist WHERE comment = 'YouTube ads (youtube.sh)';"
```

</details>

<details>
<summary><b>"The 'pihole' command was not found"</b></summary>

The script has to run on the machine (or in the container) where Pi-hole is installed — it talks to Pi-hole through the `pihole` command. If Pi-hole runs in Docker, use [Option 1](#-option-1--add-the-list-to-pi-hole-recommended) instead.

</details>

<details>
<summary><b>Nothing happens when cron runs the script</b></summary>

- Use **root's** crontab (`sudo crontab -e`), not your user's.
- Use the full path to the script, e.g. `/home/pi/youTube_ads_4_pi-hole/youtube.sh`.
- Run it by hand once with `sudo ./youtube.sh` to see any error messages.

</details>

---

## 🔒 Privacy

Option 1 sends nothing anywhere — Pi-hole just downloads a text file from GitHub.

To keep the list up to date, the **script** (Option 2) shares the `googlevideo.com` hostnames that your Pi-hole has seen in the **last 24 hours**. That's all it sends — no IP addresses, no client names, no other domains. The hostnames are collected through a Google Form and reviewed before anything is added to the list.

Don't want to share? Run the script with `--no-share`, or set `SHARE_LOGS=false` at the top of `youtube.sh`. Everything else works exactly the same.

---

## 🤝 Contributing

- **Found an ad domain that isn't blocked?** Open an issue / pull request against `youtubelist.txt` and `black.list` — or run the script with log sharing on and it will reach the list.
- **A domain breaks video playback?** Open a pull request that adds it to `ignore.list`.
- **Something in the script or docs is unclear?** Issues and pull requests are very welcome.

---

## ☕ Support the project

Keeping the list current takes daily work. If it saves you from a few ads, consider buying me a coffee:

[![PayPal](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://paypal.me/KBoghdady?locale.x=en_US)
[![Buy Me A Coffee](https://img.shields.io/badge/Buy%20Me%20A%20Coffee-FFDD00?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black)](https://buymeacoffee.com/xmh7j53o1)

| Coin | Address |
|------|---------|
| **Bitcoin** | `36fD957SDWHJYYzuH2xmceJ6T2qE9vNiV4` |
| **XRP** | `rw2ciyaNshpHe7bCHo4bRWq6pqqynnWKQg` |

Thank you! 🙏
