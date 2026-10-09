# ST3215 chassis layout — MEC-172

Date: 2026-10-09. Working geometry; actual hardware fit and mass unqualified.

Use a175 x160 mm floor/end-wall chassis with identical current leg parts and
rear leg assemblies rotated180 degrees about z. Keep the existing70/85 mm links
and85 mm hip carrier offset. Do not create handed servo brackets or shorten
carriers before the first real interface test.

The earlier nominal180 x110 mm body target is widened for the existing60 mm-wide
J1 fixture plates, two hip axes100 mm apart and accessible end-wall hardware.
The end-wall fixture holes span152 mm across y; a160 mm wall leaves room for the
provisional M3 washers. Hip axes at x=+/-115 mm place the mounting interfaces at
x=+/-87.5 mm, leaving a165 mm central bay for the134 mm battery tray.
The slight reduction to175 mm body length comes from this matching mount stack.

Place the battery low on the floor, centred in x/y. Raise a removable140 mm-square
generic electronics deck on four printed spacers rather than buying special
standoffs or locking an unknown board hole pattern. Use commodity M3 through
bolts, slots and insulating board mounts after measuring the real modules.

End walls need34 mm reliefs at the rotating hip hubs; a solid matching wall would
interfere with the fork. Verify this interface using actual exported hip meshes.
The layout is intentionally long: nominal foot references span400 x100 mm.
The wide body/long carriers are acceptable for an affordable static/crawl trial;
compactness can be revisited if physical loading or packaging justifies it.

Consequences: body-to-leg transforms and outward-J1 signs differ across the four
positions and must be implemented/calibrated later. Actual centre of mass and
sustained torque remain unknown. No gait range, loaded limit, motor upgrade or
manufacturing release follows from this layout alone.
