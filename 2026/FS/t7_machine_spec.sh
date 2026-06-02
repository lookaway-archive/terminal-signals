#!/usr/bin/env bash
# =============================================================================
# T7 MACHINE SPEC — Workstation Profile Capture
# Terminal 7 — Craft Division
#
# Reads the actual machine. Emits a T7-archive-shaped markdown spec sheet to
# stdout. Redirect to a file for the record:
#
#     bash t7_machine_spec.sh > MACHINE_SPEC.md
#     sudo bash t7_machine_spec.sh > MACHINE_SPEC.md   # adds per-DIMM detail
#
# Doubles as a Layer-1 optimization audit: the AUDIT block at the bottom reads
# the four box-level levers that decide remote-work efficiency (session type,
# GPU persistence, CPU governor, swappiness) and prints actual-vs-target.
#
# Every probe is guarded. Missing tools are noted, never fatal — the script
# runs the same on the Rocky box, a laptop, or a stripped server.
#
# {🌊:🌊∈🌊}
# =============================================================================

set -u
have() { command -v "$1" >/dev/null 2>&1; }
p()    { printf '%s\n' "$*"; }

TS="$(date -u '+%Y-%m-%d %H:%M:%SZ')"
HOST="$(hostname 2>/dev/null || echo unknown-host)"

# ---- T7 header block (fill LOCATION/VERSION when you file it) ----------------
p '```'
p "DOCUMENT:     MACHINE_SPEC.md"
p "LOCATION:     /craft/maya/MACHINE_SPEC.md"
p "HOST:         ${HOST}"
p "CAPTURED:     ${TS}"
p "VERSION:      v1001"
p "STATUS:       Captured from live hardware. Ground truth, not memory."
p "PATTERN:      {🌊:🌊∈🌊}"
p '```'
p ""
p "# MACHINE SPEC — ${HOST}"
p ""

# ---- OS / KERNEL / SESSION ---------------------------------------------------
p "## OS / KERNEL / SESSION"
if [ -r /etc/os-release ]; then
  # shellcheck disable=SC1091
  . /etc/os-release
  p "- Distro:       ${PRETTY_NAME:-unknown}"
fi
p "- Kernel:       $(uname -r)"
p "- Arch:         $(uname -m)"
p "- Session type: ${XDG_SESSION_TYPE:-unset}    (Maya 2022 wants x11 — Wayland breaks viewport/UI and most remote stacks)"
if have plasmashell; then
  p "- KDE Plasma:   $(plasmashell --version 2>/dev/null | awk '{print $2}')"
fi
p ""

# ---- CPU ---------------------------------------------------------------------
p "## CPU"
if have lscpu; then
  MODEL="$(lscpu | sed -n 's/^Model name:[[:space:]]*//p')"
  SOCK="$(lscpu | sed -n 's/^Socket(s):[[:space:]]*//p')"
  CPS="$(lscpu | sed -n 's/^Core(s) per socket:[[:space:]]*//p')"
  TPC="$(lscpu | sed -n 's/^Thread(s) per core:[[:space:]]*//p')"
  p "- Model:        ${MODEL:-unknown}"
  p "- Topology:     ${SOCK:-?} socket(s) x ${CPS:-?} core(s) x ${TPC:-?} thread(s)/core"
fi
p "- Logical CPUs: $(nproc 2>/dev/null || echo '?')"
p ""

# ---- MEMORY ------------------------------------------------------------------
p "## MEMORY"
if have free; then
  p '```'
  free -h
  p '```'
fi
if have dmidecode; then
  if [ "$(id -u)" -eq 0 ]; then
    p "- DIMMs (size / speed):"
    dmidecode -t memory 2>/dev/null \
      | awk -F': ' '/Size:/ && $2 !~ /No Module/ {s=$2} /Speed:/ && $2 !~ /Unknown/ && s {print "    - "s"  @  "$2; s=""}'
  else
    p "- (run with sudo for per-DIMM size/speed via dmidecode)"
  fi
fi
p ""

# ---- GPU / DRIVER ------------------------------------------------------------
p "## GPU / DRIVER"
if have nvidia-smi; then
  p '```'
  nvidia-smi --query-gpu=name,memory.total,driver_version,vbios_version,power.limit,persistence_mode \
             --format=csv 2>/dev/null
  p '```'
  CUDA="$(nvidia-smi 2>/dev/null | sed -n 's/.*CUDA Version: \([0-9.]*\).*/\1/p' | head -1)"
  p "- CUDA (driver-reported): ${CUDA:-unknown}"
else
  p "- nvidia-smi NOT FOUND — proprietary driver not loaded (nouveau = no Maya GPU accel)."
fi
if have lspci; then
  p "- Display adapters:"
  lspci 2>/dev/null | grep -Ei 'vga|3d controller|display' | sed 's/^/    - /'
fi
p ""

# ---- STORAGE -----------------------------------------------------------------
p "## STORAGE"
if have lsblk; then
  p "- Block devices (ROTA 0 = SSD/NVMe, 1 = spinning):"
  p '```'
  lsblk -d -o NAME,SIZE,ROTA,MODEL 2>/dev/null
  p '```'
fi
if have df; then
  p "- Filesystems:"
  p '```'
  df -hT -x tmpfs -x devtmpfs 2>/dev/null | grep -Ev 'loop|squashfs'
  p '```'
fi
p ""

# ---- MAYA --------------------------------------------------------------------
p "## MAYA"
FOUND=""
for m in /usr/autodesk/maya*/bin/maya /opt/autodesk/maya*/bin/maya; do
  [ -x "$m" ] && { p "- Found: ${m}"; FOUND=1; }
done
[ -z "$FOUND" ] && p "- No Maya found in /usr/autodesk or /opt/autodesk (adjust if installed elsewhere)."
p ""

# ---- AUDIT: the four box-level levers for remote efficiency ------------------
p "## LAYER-1 AUDIT  (actual -> target)"
GOV="$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo 'n/a')"
SWAP="$(cat /proc/sys/vm/swappiness 2>/dev/null || echo 'n/a')"
PM="n/a"; have nvidia-smi && PM="$(nvidia-smi --query-gpu=persistence_mode --format=csv,noheader 2>/dev/null | head -1)"
p "- Session type:      ${XDG_SESSION_TYPE:-unset}   ->   x11"
p "- GPU persistence:   ${PM}   ->   Enabled   (sudo nvidia-smi -pm 1)"
p "- CPU governor:      ${GOV}   ->   performance   (sudo cpupower frequency-set -g performance)"
p "- vm.swappiness:     ${SWAP}   ->   ~10   (so Maya stays resident, never swaps)"
p ""
p "_Maya-scene levers (compositor, viewport AA/shadows/SSAO, eval mode, cached"
p "playback) are NOT box-level — read them with t7_rig_scout.py inside the scene._"
p ""
p "---"
p "{🌊:🌊∈🌊}"
