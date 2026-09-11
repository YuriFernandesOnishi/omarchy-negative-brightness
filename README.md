# omarchy-negative-brightness

Lets the brightness slider on the [Omarchy](https://omarchy.org) bar go below
0%, for anyone who finds their monitor's physical (DDC/CI) minimum still too
bright.

- Range: **-70% to 100%** (0% to 100% is still normal physical brightness;
  below 0% the monitor is pinned at its physical minimum and the rest is
  gamma dimming, via [hyprgamma](https://github.com/surprizeattackxx-dotcom/hypr-gamma)).
- The Display panel on the bar gets a **per-monitor selector**: pick which
  screen the slider controls without having to focus it first.
- Adjustments below 0% are fast — the DDC command (slow on some monitors)
  only runs once when crossing the physical floor, not on every adjustment.

## Requirements

- Omarchy installed.
- One or more monitors with DDC/CI support (most external monitors).
- The compositor plugin [hyprgamma](https://github.com/surprizeattackxx-dotcom/hypr-gamma),
  which does the per-monitor gamma dimming.

## Install

```bash
git clone https://github.com/YuriFernandesOnishi/omarchy-negative-brightness.git
cd omarchy-negative-brightness
./install.sh
```

`install.sh`:

1. Clones the bar's `omarchy.monitor` plugin (if you don't already have a
   clone of your own).
2. Replaces that clone's `Panel.qml`/`Model.js` with the version that
   supports negative brightness and the per-monitor selector.
3. Installs the `omarchy-brightness-extended` and
   `omarchy-monitor-state-extended` scripts into `~/.local/bin`.
4. Makes sure `hyprgamma` gets reloaded on every Hyprland start
   (`~/.config/hypr/autostart.lua`).
5. Restarts the Omarchy shell.

### Manual step (needs your password)

`hyprpm` installs the plugin's `.so` as `root` for security (so a compromised
process can't swap out the binary loaded into the compositor), so this step
needs an interactive sudo password and **can't be automated**:

```bash
hyprpm add https://github.com/surprizeattackxx-dotcom/hypr-gamma.git
hyprpm enable hyprgamma
```

After that, open the Display panel on the bar — the slider now goes from
-70% to 100%, with the monitor picker above it.

## How it works

- `bin/omarchy-brightness-extended <monitor> {up|down|max|min|set N}` —
  applies a -70..100 value to a monitor: if `N >= 1`, it adjusts physical
  brightness via `omarchy-brightness-display`/DDC; if `N < 1`, it pins
  physical brightness at 1% and applies
  `hyprctl hyprgamma:set <monitor> brightness <0.30..1.00>`. Per-monitor
  state is kept in `~/.local/state/omarchy-brightness/<monitor>`.
- `bin/omarchy-monitor-state-extended` — like Omarchy's own
  `omarchy-monitor-state`, but swaps the hardware brightness (0-100) for the
  extended value (-70..100) and appends a JSON map
  `{"MONITOR": value, ...}` with every monitor's value, so the panel shows
  the right one when you switch the selector without re-reading hardware.
- `plugin/Panel.qml` + `plugin/Model.js` — a fork of the stock
  `omarchy.monitor` widget, with a -70..100 slider range and a row of pills
  (one per connected monitor) that switches which monitor the
  slider/scroll-wheel/keyboard shortcuts control.

## Adjusting the floor

The floor (-70% = gamma 0.30) is intentional — below that the screen becomes
hard to read. To change it, edit the `-70` occurrences in:

- `bin/omarchy-brightness-extended`
- `plugin/Model.js` (`clampBrightness`)
- `plugin/Panel.qml` (`minimum: -70` on the brightness `PanelSlider`)

then run `./install.sh` again (or copy the files over manually).

## Uninstall

```bash
rm -rf ~/.config/omarchy/plugins/*.monitor   # back to Omarchy's stock widget
rm ~/.local/bin/omarchy-brightness-extended ~/.local/bin/omarchy-monitor-state-extended
hyprpm disable hyprgamma   # optional
omarchy restart shell
```

Also remove the `hyprpm reload -n` line from
`~/.config/hypr/autostart.lua` if you're done with hyprgamma.

## Credits

- [hyprgamma](https://github.com/surprizeattackxx-dotcom/hypr-gamma) by
  surprizeattackxx-dotcom — the compositor plugin that does the per-monitor
  gamma dimming.
- [Omarchy](https://omarchy.org) for the original `omarchy.monitor` widget.
