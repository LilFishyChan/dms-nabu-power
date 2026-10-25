# Power Mode

Control-center widget for DankMaterialShell that switches CPU power profiles on
Snapdragon tablets. Built for the Xiaomi Pad 5 (SM8150 / Snapdragon 860), whose
three CPU clusters map to `policy0` / `policy4` / `policy7`.

Cycles through three profiles on click:

| Profile | cpu0-3 (little) | cpu4-6 (mid) | cpu7 (prime) |
|---|---|---|---|
| Saver | `powersave` | `powersave` | `schedutil` |
| Balanced | `schedutil` | `schedutil` | `schedutil` |
| Performance | `schedutil` | `performance` | `performance` |

Only the clusters that actually render and dispatch are pinned in the
performance profile — pinning all eight cores costs battery for cores that only
run background work.

The tile is always rendered active: a power profile is never "off", so binding
the highlight to the performance profile would make the other two look disabled.
The current profile is shown in the subtitle and the icon instead.

## Requirements

- `nabu-power` on `PATH` (installed to `/usr/local/bin`, **not**
  `~/.local/bin` — that directory is often missing from `PATH` on these images)
- Passwordless `sudo` for writing `scaling_governor`

## Install

```bash
sudo install -Dm755 scripts/nabu-power /usr/local/bin/nabu-power

mkdir -p ~/.config/dms/plugins/nabuPower
cp -r plugin.json NabuPower.qml translations ~/.config/dms/plugins/nabuPower/

dms ipc call plugins enable nabuPower     # loads as [disabled] before this
```

Then add the tile to the control center — append to `controlCenterWidgets` in
`~/.config/dms/settings.json` (note the `plugin_` prefix on the id):

```json
{"id": "plugin_nabuPower", "enabled": true, "w": 2, "h": 1, "col": 6, "row": 5}
```

and restart the shell:

```bash
systemctl --user restart dms
```

DMS scans plugin directories only at startup, so any change to the QML needs the
same restart.

## The script

```bash
nabu-power performance    # pin mid + prime clusters
nabu-power balanced       # default
nabu-power saver
nabu-power current        # prints the profile name (used by the widget)
nabu-power status         # per-cluster governor and current frequency
```

`current` derives the profile from `scaling_governor` rather than reading a
stored state file, so a switch made in a terminal shows up in the widget within
one poll interval.

`/sys/devices/system/cpu/cpufreq/boost` is deliberately untouched: on
`qcom-cpufreq-hw` writing `1` returns `EINVAL`, and the `performance` governor
already reaches `cpuinfo_max_freq` on its own.

## License

MIT
