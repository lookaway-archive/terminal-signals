#!/usr/bin/env bash
# =============================================================================
# T7 NET PROBE — can a command-line tool reach the internet from this box?
# Terminal 7 — Craft Division
# Run as yourself (no root). Screenshot the output.
# {🌊:🌊∈🌊}
# =============================================================================

echo "== T7 NET PROBE =="
echo

echo "-- proxy env (does the shell already know a proxy?) --"
env | grep -i proxy || echo "  none set"
echo

echo "-- DNS --"
getent hosts www.youtube.com >/dev/null 2>&1 \
  && echo "  youtube resolves: OK" || echo "  youtube resolve: FAILED"
echo

echo "-- direct outbound HTTPS, no proxy (the real question) --"
for host in https://www.youtube.com https://pypi.org https://github.com; do
  curl -s -o /dev/null --max-time 10 \
    -w "  ${host}  ->  HTTP %{http_code}  (%{time_total}s)\n" "$host" \
    || echo "  ${host}  ->  FAILED / timed out"
done
echo

echo "-- python / pip (can we install yt-dlp --user?) --"
for py in python3 python; do
  if command -v "$py" >/dev/null 2>&1; then
    echo "  $py: $($py --version 2>&1)  [$(command -v $py)]"
    "$py" -m pip --version >/dev/null 2>&1 \
      && echo "    pip: present" || echo "    pip: NOT present"
  fi
done
command -v yt-dlp >/dev/null 2>&1 \
  && echo "  yt-dlp already here: $(yt-dlp --version 2>&1)" \
  || echo "  yt-dlp: not on PATH"
echo
echo "== END =="
