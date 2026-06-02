"""
T7 PLATE TRACER  --  find the plate input + the cache lever in a bloated rig.
Terminal 7 -- Craft Division.   Maya 2023 safe (cmds only, read-only).
Paste into the Script Editor (Python tab), run, screenshot the output.
{🌊:🌊∈🌊}
"""
import maya.cmds as cmds


def _g(node, attr):
    """Safe getAttr: value, or None if the attr is absent/unreadable."""
    try:
        if cmds.attributeQuery(attr, node=node, exists=True):
            return cmds.getAttr(node + "." + attr)
    except Exception:
        pass
    return None


def _src(node, attr):
    """Source-side connections into node.attr, as plug strings, or []."""
    try:
        return cmds.listConnections(node + "." + attr, s=True, d=False, p=True) or []
    except Exception:
        return []


def _is_net(path):
    return bool(path) and path.startswith(("/net/", "/job/", "/mnt/"))


def _kinds(nodes):
    k = {}
    for n in set(nodes or []):
        t = cmds.nodeType(n)
        k[t] = k.get(t, 0) + 1
    return ", ".join("%s x%d" % (t, c) for t, c in sorted(k.items()))


def trace_plate():
    BAR = "=" * 62
    o = [BAR, "  T7 PLATE TRACER", "  scene: " + (cmds.file(q=True, sn=True) or "(unsaved)"), BAR]

    # timeline (for cache sizing)
    try:
        amin = int(cmds.playbackOptions(q=True, min=True))
        amax = int(cmds.playbackOptions(q=True, max=True))
        span = amax - amin + 1
    except Exception:
        amin = amax = span = None
    o.append("  timeline: %s - %s   (%s frames)" % (amin, amax, span))
    o.append("")

    # cameras + rig depth
    o.append("-- CAMERAS / RIG DEPTH --")
    defaults = {"perspShape", "topShape", "frontShape", "sideShape",
                "backShape", "bottomShape", "leftShape"}
    cams = [c for c in (cmds.ls(type="camera") or []) if c.split("|")[-1] not in defaults]
    if not cams:
        o.append("  (only default cameras present)")
    for cs in cams:
        tp = cmds.listRelatives(cs, parent=True, fullPath=True) or []
        depth = tp[0].count("|") if tp else 0
        o.append("  %s" % cs)
        o.append("    transform: %s   |   rig depth: %d parent levels"
                 % (tp[0].split("|")[-1] if tp else "?", depth))
        if tp:
            drv = _kinds(cmds.listConnections(tp[0], s=True, d=False))
            if drv:
                o.append("    driven by: %s" % drv)
    o.append("")

    # image planes (the plate)
    o.append("-- IMAGE PLANES (the plate) --")
    ips = cmds.ls(type="imagePlane") or []
    if not ips:
        o += ["  NO IMAGE PLANES FOUND.",
              "  -> plate may be a custom plate-manager node, a fileTexture on",
              "     geo, or a UFE/USD camera. Send me the plate-manager tool",
              "     name and I'll widen the trace.", BAR]
        print("\n".join(o))
        return

    report = ["imageName", "type", "useFrameExtension", "frameExtension",
              "frameOffset", "frameCache", "displayMode", "fit", "depth",
              "displayOnlyIfCurrent"]

    for ip in ips:
        o.append("")
        cam = list(set(cmds.listConnections(ip, type="camera") or []))
        o.append("  [%s]  ->  camera: %s" % (ip, ", ".join(cam) if cam else "FREE (not attached)"))
        for a in report:
            v = _g(ip, a)
            if v is None:
                continue
            tag = ""
            if a == "imageName":
                tag = "   <== THE INPUT" + ("   [NFS network read]" if _is_net(v) else "")
            if a == "frameCache":
                tag = "   <== CACHE LEVER" + ("   (0 = NO RAM CACHE)" if v == 0 else "")
            o.append("      %-20s : %s%s" % (a, v, tag))

        o.append("      input chain (what drives the plate):")
        drove = False
        for a in ("imageName", "frameExtension", "frameOffset", "useFrameExtension"):
            s = _src(ip, a)
            if s:
                drove = True
                o.append("        .%-18s <- %s" % (a, ", ".join(s)))
        if not drove:
            o.append("        (no incoming connections -- values are static/baked)")

        up = _kinds(cmds.listConnections(ip, s=True, d=False))
        if up:
            o.append("      upstream nodes: %s" % up)

    # scene footprint (bloat gauge)
    o += ["", "-- SCENE FOOTPRINT --",
          "  expressions: %d   scriptNodes: %d   total nodes: %d"
          % (len(cmds.ls(type="expression") or []),
             len(cmds.ls(type="script") or []),
             len(cmds.ls() or []))]

    # the lever
    o += ["", "-- THE LEVER --"]
    for ip in ips:
        img = _g(ip, "imageName")
        if img is None:
            continue
        fc = _g(ip, "frameCache")
        o.append("  %s" % ip)
        o.append("    plate: %s" % img)
        if fc == 0 and span:
            o.append("    frameCache 0 -> pre-load the shot into RAM:")
            o.append("        cmds.setAttr('%s.frameCache', %d)" % (ip, span))
        elif fc:
            o.append("    frameCache = %d  (caching already active)" % fc)
        if _is_net(img):
            o.append("    plate is on a network share -> first scrub reads NFS;")
            o.append("    RAM caching is what makes repeat scrubs smooth.")
    o.append(BAR)
    print("\n".join(o))


trace_plate()
