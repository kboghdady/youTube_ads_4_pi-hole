#!/bin/sh
#
#  youtube.sh - keep your Pi-hole denylist in sync with the YouTube ads list
#  https://github.com/kboghdady/youTube_ads_4_pi-hole
#
#  What it does every time it runs:
#    1. Downloads the latest list of YouTube ad domains from GitHub
#    2. Drops every domain listed in ignore.list (hosts that break video playback)
#    3. Adds ONLY the domains your Pi-hole does not have yet (fast on repeat runs)
#    4. Reloads Pi-hole's lists so the new domains are blocked right away
#    5. Optionally shares the googlevideo.com hostnames from your query log so
#       new ad servers can be added to the list for everyone (see SHARE_LOGS)
#
#  Works with Pi-hole v5 and v6. Needs root - it re-runs itself with sudo.
#
#  Usage:  sudo ./youtube.sh [--no-share] [--crowd] [--dry-run] [--help]
#
#  Run it every hour with cron (sudo crontab -e):
#    0 * * * * /home/pi/youTube_ads_4_pi-hole/youtube.sh > /dev/null 2>&1
#

# ----------------------------- Settings -----------------------------------
# Share the googlevideo.com hostnames Pi-hole saw in the last 24 hours so they
# can be added to the list. Hostnames only - no IPs, clients or other domains.
# Set to false (or run with --no-share) if you would rather not.
SHARE_LOGS=true

# Also block the crowd-sourced list (crowed_list.txt). It is NOT filtered
# against ignore.list, so it may break some videos. Or run with --crowd.
INCLUDE_CROWD_LIST=false

# Comment shown next to each domain in the Pi-hole web interface.
COMMENT="YouTube ads (youtube.sh)"
# --------------------------------------------------------------------------

BASE_URL="https://raw.githubusercontent.com/kboghdady/youTube_ads_4_pi-hole/master"
LIST_URL="$BASE_URL/black.list"
CROWD_URL="$BASE_URL/crowed_list.txt"
IGNORE_URL="$BASE_URL/ignore.list"
SHARE_URL="https://docs.google.com/forms/d/e/1FAIpQLSd_j3lQs_B7S3Hz3aA3IkwYMF4my0DnBMZFAn3e9grZo61VFQ/formResponse"
GRAVITY_DB="/etc/pihole/gravity.db"
FTL_DB="/etc/pihole/pihole-FTL.db"
BATCH_SIZE=200   # domains handed to the pihole command per call

set -u
export LC_ALL=C
# cron has a very short PATH; make sure pihole (/usr/local/bin) is found
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
SCRIPT_PATH="$SCRIPT_DIR/$(basename "$0")"
DRY_RUN=false

info() { printf '  [i] %s\n' "$*"; }
ok()   { printf '  [+] %s\n' "$*"; }
warn() { printf '  [!] %s\n' "$*" >&2; }
die()  { printf '  [x] %s\n' "$*" >&2; exit 1; }

usage() {
    cat <<EOF
Usage: sudo ./youtube.sh [options]

Keeps your Pi-hole denylist in sync with the YouTube ads list.

Options:
  --no-share   Do not share googlevideo.com hostnames from your query log
  --crowd      Also block the crowd-sourced list (unfiltered, may break videos)
  --dry-run    Show what would change without touching Pi-hole
  -h, --help   Show this help

Settings can also be changed at the top of this script.
EOF
}

for arg in "$@"; do
    case "$arg" in
        --no-share) SHARE_LOGS=false ;;
        --crowd)    INCLUDE_CROWD_LIST=true ;;
        --dry-run)  DRY_RUN=true ;;
        -h|--help)  usage; exit 0 ;;
        *)          die "Unknown option: $arg  (try --help)" ;;
    esac
done

# --- Root is needed to talk to Pi-hole; re-run ourselves with sudo if not ---
if [ "$(id -u)" -ne 0 ]; then
    command -v sudo >/dev/null 2>&1 || die "Please run this script as root."
    exec sudo /bin/sh "$SCRIPT_PATH" "$@"
fi

# --- Sanity checks ---------------------------------------------------------
command -v pihole >/dev/null 2>&1 || die "The 'pihole' command was not found. Is Pi-hole installed on this machine?"
command -v curl   >/dev/null 2>&1 || die "'curl' is required. Install it with:  sudo apt-get install curl"

# Pi-hole v6 keeps its config in pihole.toml; v5 does not have that file.
if [ -f /etc/pihole/pihole.toml ]; then PIHOLE_VER=6; else PIHOLE_VER=5; fi

# Pi-hole ships its own sqlite3 inside pihole-FTL; fall back to the system one.
if pihole-FTL sqlite3 -version >/dev/null 2>&1; then
    SQLITE="pihole-FTL sqlite3"
elif command -v sqlite3 >/dev/null 2>&1; then
    SQLITE="sqlite3"
else
    SQLITE=""
fi
sql() { $SQLITE "$@" 2>/dev/null | tr -d '\r'; }

WORK=$(mktemp -d) || die "Could not create a temporary directory"
trap 'rm -rf "$WORK"' EXIT INT TERM HUP

# Strip Windows line endings, comments, surrounding whitespace and blank lines.
clean() { tr -d '\r' | sed -e 's/#.*$//' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | grep -v '^$'; }

printf '\n  YouTube ads blocker for Pi-hole v%s\n' "$PIHOLE_VER"
[ "$DRY_RUN" = true ] && info "Dry run: nothing will be changed"
printf '\n'

# --- 1. Download the lists -------------------------------------------------
info "Downloading the latest YouTube ad list..."
curl -fsSL --retry 3 "$LIST_URL" -o "$WORK/list.raw" \
    || die "Download failed: $LIST_URL  (is the internet connection working?)"

if [ "$INCLUDE_CROWD_LIST" = true ]; then
    info "Downloading the crowd-sourced list..."
    curl -fsSL --retry 3 "$CROWD_URL" -o "$WORK/crowd.raw" \
        || warn "Could not download the crowd list - skipping it this time"
fi

# ignore.list = the copy next to this script (edit it to add your own entries)
# merged with the latest copy from GitHub.
: > "$WORK/ignore.raw"
[ -f "$SCRIPT_DIR/ignore.list" ] && cat "$SCRIPT_DIR/ignore.list" >> "$WORK/ignore.raw"
echo >> "$WORK/ignore.raw"
curl -fsSL --retry 3 "$IGNORE_URL" >> "$WORK/ignore.raw" \
    || warn "Could not download ignore.list from GitHub - using the local copy only"
clean < "$WORK/ignore.raw" | sort -u > "$WORK/ignore.txt"

# --- 2. Clean the list and apply ignore.list -------------------------------
{ cat "$WORK/list.raw"; echo; [ -f "$WORK/crowd.raw" ] && cat "$WORK/crowd.raw"; } \
    | clean | sort -u > "$WORK/all.txt"

if [ -s "$WORK/ignore.txt" ]; then
    grep -vFf "$WORK/ignore.txt" "$WORK/all.txt" > "$WORK/wanted.txt" || true
else
    cp "$WORK/all.txt" "$WORK/wanted.txt"
fi

all=$(wc -l < "$WORK/all.txt" | tr -d ' ')
total=$(wc -l < "$WORK/wanted.txt" | tr -d ' ')
[ "$total" -gt 0 ] || die "The downloaded list is empty - nothing to do."
ok "$total domains in the list ($((all - total)) skipped because of ignore.list)"

# --- 3. Remove ignored domains that were blocked by an earlier run ---------
removed=0
if [ -n "$SQLITE" ] && [ -s "$WORK/ignore.txt" ] && [ -f "$GRAVITY_DB" ]; then
    # Build:  domain LIKE '%abc%' OR domain LIKE '%def%' ...
    where=$(awk -v q="'" '{ gsub(q, ""); printf "%sdomain LIKE %s%%%s%%%s", (NR > 1 ? " OR " : ""), q, $0, q }' "$WORK/ignore.txt")
    if [ "$DRY_RUN" = true ]; then
        removed=$(sql "$GRAVITY_DB" "SELECT COUNT(*) FROM domainlist WHERE type = 1 AND ($where);")
    else
        removed=$(sql "$GRAVITY_DB" "DELETE FROM domainlist WHERE type = 1 AND ($where); SELECT changes();")
    fi
    removed=${removed:-0}
    if [ "$removed" -gt 0 ]; then
        if [ "$DRY_RUN" = true ]; then
            info "Would remove $removed blocked domain(s) that are now in ignore.list"
        else
            ok "Removed $removed blocked domain(s) that are now in ignore.list"
        fi
    fi
fi

# --- 4. Work out which domains are new -------------------------------------
if [ -n "$SQLITE" ] && [ -f "$GRAVITY_DB" ]; then
    sql "$GRAVITY_DB" "SELECT domain FROM domainlist WHERE type = 1;" | sort -u > "$WORK/existing.txt"
    comm -23 "$WORK/wanted.txt" "$WORK/existing.txt" > "$WORK/new.txt"
else
    warn "sqlite3 not found - every domain will be sent to Pi-hole (slower, but works)"
    cp "$WORK/wanted.txt" "$WORK/new.txt"
fi
new=$(wc -l < "$WORK/new.txt" | tr -d ' ')

# --- 5. Add the new domains to the denylist --------------------------------
failed=0
last_error=""
if [ "$new" -eq 0 ]; then
    ok "Your Pi-hole denylist already has every domain - nothing to add"
elif [ "$DRY_RUN" = true ]; then
    info "Would add $new new domain(s) to the denylist"
else
    info "Adding $new new domain(s) to the denylist..."
    [ "$new" -gt 1000 ] && info "This takes a few minutes the first time - later runs only add what is new"

    split -l "$BATCH_SIZE" "$WORK/new.txt" "$WORK/batch."
    printf '  '
    for batch in "$WORK"/batch.*; do
        if [ "$PIHOLE_VER" -eq 6 ]; then
            out=$(xargs pihole deny -q --comment "$COMMENT" < "$batch" 2>&1)
        else
            out=$(xargs pihole -b -q -nr --comment "$COMMENT" < "$batch" 2>&1)
        fi
        if [ $? -ne 0 ]; then failed=$((failed + 1)); last_error=$out; fi
        printf '.'
    done
    printf '\n'

    if [ "$failed" -gt 0 ]; then
        warn "Pi-hole reported an error for $failed batch(es). Last message:"
        printf '%s\n' "$last_error" | tail -n 5 | sed 's/^/      /' >&2
    else
        ok "Added $new domain(s)"
    fi
fi

# --- 6. Reload Pi-hole so the changes take effect --------------------------
if [ "$DRY_RUN" != true ] && { [ "$new" -gt 0 ] || [ "$removed" -gt 0 ]; }; then
    info "Reloading Pi-hole's lists..."
    if [ "$PIHOLE_VER" -eq 6 ]; then
        pihole reloadlists > /dev/null 2>&1 || warn "'pihole reloadlists' failed - changes apply after the next restart"
    else
        pihole restartdns reload-lists > /dev/null 2>&1 || warn "'pihole restartdns reload-lists' failed - changes apply after the next restart"
    fi
fi

# --- 7. Share googlevideo.com hostnames from the query log (optional) ------
if [ "$SHARE_LOGS" = true ] && [ "$DRY_RUN" != true ] && [ -n "$SQLITE" ] && [ -f "$FTL_DB" ]; then
    seen=$(sql "$FTL_DB" "SELECT DISTINCT domain FROM queries WHERE timestamp >= strftime('%s','now') - 86400 AND domain LIKE '%googlevideo.com';" | tr '\n' ',')
    if [ -n "$seen" ]; then
        count=$(printf '%s' "$seen" | tr -cd ',' | wc -c | tr -d ' ')
        if curl -fsS -G --retry 2 -o /dev/null --data-urlencode "usp=pp_url" --data-urlencode "entry.275594062=$seen" "$SHARE_URL"; then
            ok "Shared $count googlevideo.com hostname(s) from your query log - thank you!"
        else
            warn "Could not share your query log hostnames (no harm done)"
        fi
    fi
fi

printf '\n'
if [ "$DRY_RUN" = true ]; then
    ok "Dry run finished - nothing was changed"
elif [ "$failed" -gt 0 ]; then
    warn "Finished with errors - some domains were not added. Run the script again; if it keeps failing, check that Pi-hole is running ('pihole status')."
    printf '\n'
    exit 1
else
    ok "All done. Pi-hole is blocking $total YouTube ad domains."
fi
printf '\n'
