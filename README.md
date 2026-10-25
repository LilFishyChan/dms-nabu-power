# Power Mode

Control-center widget that switches CPU power profiles on Snapdragon tablets.

Cycles through three profiles on click:

| Profile | cpu0-3 (little) | cpu4-6 (mid) | cpu7 (prime) |
|---|---|---|---|
| Saver | `powersave` | `powersave` | `schedutil` |
| Balanced | `schedutil` | `schedutil` | `schedutil` |
| Performance | `schedutil` | `performance` | `performance` |

The actual switching is done by `nabu-power`, which must be on `PATH`
(`/usr/local/bin/nabu-power`). The widget reads the current profile back from
`/sys/devices/system/cpu/cpufreq/policy*/scaling_governor`, so it stays in sync
when the profile is changed from a terminal.

Requires passwordless `sudo` for writing `scaling_governor`.
