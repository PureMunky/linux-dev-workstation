# Keyboard Layouts

This page covers every input layout the repo defines:

1. [ZSA Moonlander](#zsa-moonlander): the custom QMK firmware in `keyboards/moonlander/`
2. [WezTerm key bindings](#wezterm-key-bindings): `dotfiles/.wezterm.lua`
3. [Stream Deck button grids](#stream-deck-button-grids): `streamdeck/`

> The source of truth is `keyboards/moonlander/keymap.c`. If you change it,
> regenerate the printable reference with
> `./scripts/print_moonlander_keymap.sh > keymap.txt` and update this page.

---

## ZSA Moonlander

The firmware has a QWERTY base, three layers, an OS-mode toggle that persists
in EEPROM, and RGB themes you pick from the Nav layer.

| Layer | Name | How to reach it |
|-------|------|-----------------|
| 0 | **Base** (QWERTY) | Default |
| 1 | **Nav / Function** | Hold either **Nav** key (left home-row pinky, or the right red thumb key) |
| 2 | **Shortcuts** | Hold the right-thumb **Del** key (`LT(_SHORTCUTS, KC_DEL)`). A tap sends Del |

Legend: `·` = transparent (falls through to the base layer). `C+C` / `C+V` =
Copy / Paste. `Del/S` = tap for Del, hold for the Shortcuts layer.

### Layer 0: Base (QWERTY)

```
┌─────┬─────┬─────┬─────┬─────┬─────┬─────┐   ┌─────┬─────┬─────┬─────┬─────┬─────┬─────┐
│  `  │  1  │  2  │  3  │  4  │  5  │  [  │   │  ]  │  6  │  7  │  8  │  9  │  0  │  -  │
├─────┼─────┼─────┼─────┼─────┼─────┼─────┤   ├─────┼─────┼─────┼─────┼─────┼─────┼─────┤
│ Tab │  Q  │  W  │  E  │  R  │  T  │ C+C │   │Vol+ │  Y  │  U  │  I  │  O  │  P  │  \  │
├─────┼─────┼─────┼─────┼─────┼─────┼─────┤   ├─────┼─────┼─────┼─────┼─────┼─────┼─────┤
│ Nav │  A  │  S  │  D  │  F  │  G  │ C+V │   │Vol- │  H  │  J  │  K  │  L  │  ;  │  '  │
├─────┼─────┼─────┼─────┼─────┼─────┤               ├─────┼─────┼─────┼─────┼─────┼─────┤
│Shift│  Z  │  X  │  C  │  V  │  B  │               │  N  │  M  │  ,  │  .  │  /  │  =  │
└─────┴─────┴─────┴─────┴─────┴─────┘               └─────┴─────┴─────┴─────┴─────┴─────┘
┌─────┬─────┬─────┬─────┬─────┐                           ┌─────┬─────┬─────┬─────┬─────┐
│Ctrl │ Alt │ GUI │ F5  │ F12 │                           │ Alt │  ←  │  ↓  │  ↑  │  →  │
└─────┴─────┴─────┴─────┴─────┘                           └─────┴─────┴─────┴─────┴─────┘
                            ┌─────┐   ┌─────┐
              (red thumb)   │ Esc │   │ Nav │   (red thumb)
                            └─────┘   └─────┘
                        ┌─────┬─────┬─────┐   ┌─────┬─────┬─────┐
                        │Ctrl │ Alt │Enter│   │Bksp │Del/S│Space│
                        └─────┴─────┴─────┘   └─────┴─────┴─────┘
```

Notes:
- The inner column holds Copy/Paste on the left and Volume up/down on the right.
- The bottom-left modifier row sends the **right-hand** modifiers (`RCtrl`,
  `RAlt`, `RGUI`). The left thumb cluster sends the **left-hand** ones
  (`LCtrl`, `LAlt`). The OS-mode swap below affects only the left-hand Ctrl
  and GUI.

### Layer 1: Nav / Function (hold Nav)

```
┌─────┬─────┬─────┬─────┬─────┬─────┬─────┐   ┌─────┬─────┬─────┬─────┬─────┬─────┬─────┐
│Lock │ F1  │ F2  │ F3  │ F4  │ F5  │  =  │   │  -  │ F6  │ F7  │ F8  │ F9  │ F10 │ Del │
├─────┼─────┼─────┼─────┼─────┼─────┼─────┤   ├─────┼─────┼─────┼─────┼─────┼─────┼─────┤
│  ·  │Beach│Ocean│Auror│Star │Cyber│  [  │   │  ]  │Frst │Prty │Splsh│Next │ Off │  ·  │
├─────┼─────┼─────┼─────┼─────┼─────┼─────┤   ├─────┼─────┼─────┼─────┼─────┼─────┼─────┤
│  ·  │  ·  │Snap │  ·  │  ·  │  ·  │  `  │   │Enter│  ←  │  ↓  │  ↑  │  →  │  ·  │  ·  │
├─────┼─────┼─────┼─────┼─────┼─────┤               ├─────┼─────┼─────┼─────┼─────┼─────┤
│  ·  │  ·  │  ·  │  ·  │  ·  │  ·  │               │  ·  │  ·  │  ·  │  ·  │  ·  │  ·  │
└─────┴─────┴─────┴─────┴─────┴─────┘               └─────┴─────┴─────┴─────┴─────┴─────┘
┌─────┬─────┬─────┬─────┬─────┐                           ┌─────┬─────┬─────┬─────┬─────┐
│WinL │WinUp│WinR │Home │ End │                           │  ·  │PgDn │PgUp │  ·  │  ·  │
└─────┴─────┴─────┴─────┴─────┘                           └─────┴─────┴─────┴─────┴─────┘
                            ┌─────┐   ┌─────┐
                            │  ·  │   │  ·  │
                            └─────┘   └─────┘
                        ┌─────┬─────┬─────┐   ┌─────┬─────┬─────┐
                        │  ·  │  ·  │Lchr │   │Term │  ·  │  ·  │
                        └─────┴─────┴─────┘   └─────┴─────┴─────┘
```

- **H J K L** become Vim-style arrow keys.
- The **Q–P row** picks an RGB theme (see [RGB themes](#rgb-themes)).
- **Lock, Snap, WinL/WinUp/WinR, Lchr, Term** are OS-aware macros (see
  [OS mode](#os-mode-toggle)).

### Layer 2: Shortcuts (hold right-thumb Del)

Edit commands sit on the bottom row (Z X C V B), where Ctrl/Cmd shortcuts
already are. The right hand gets a navigation block. Every shortcut sends Cmd
on macOS and Ctrl on Linux/Windows.

```
┌─────┬─────┬─────┬─────┬─────┬─────┬─────┐   ┌─────┬─────┬─────┬─────┬─────┬─────┬─────┐
│  ·  │  ·  │  ·  │  ·  │  ·  │  ·  │  ·  │   │  ·  │  ·  │  ·  │  ·  │  ·  │  ·  │  ·  │
├─────┼─────┼─────┼─────┼─────┼─────┼─────┤   ├─────┼─────┼─────┼─────┼─────┼─────┼─────┤
│  ·  │  ·  │  ·  │  ·  │  ·  │  ·  │  ·  │   │  ·  │  ·  │PgUp │  ↑  │PgDn │  ·  │  ·  │
├─────┼─────┼─────┼─────┼─────┼─────┼─────┤   ├─────┼─────┼─────┼─────┼─────┼─────┼─────┤
│  ·  │SAll │Save │  ·  │Find │  ·  │  ·  │   │  ·  │Home │  ←  │  ↓  │  →  │ End │  ·  │
├─────┼─────┼─────┼─────┼─────┼─────┤               ├─────┼─────┼─────┼─────┼─────┼─────┤
│Shift│Undo │ Cut │Copy │Paste│Redo │               │ DWb │WrdL │WrdR │ DWf │  ·  │  ·  │
└─────┴─────┴─────┴─────┴─────┴─────┘               └─────┴─────┴─────┴─────┴─────┴─────┘
┌─────┬─────┬─────┬─────┬─────┐                           ┌─────┬─────┬─────┬─────┬─────┐
│  ·  │  ·  │  ·  │  ·  │  ·  │                           │  ·  │  ·  │  ·  │  ·  │  ·  │
└─────┴─────┴─────┴─────┴─────┘                           └─────┴─────┴─────┴─────┴─────┘
                            ┌─────┐   ┌─────┐
                            │  ·  │   │  ·  │
                            └─────┘   └─────┘
                        ┌─────┬─────┬─────┐   ┌─────┬─────┬─────┐
                        │  ·  │  ·  │  ·  │   │  ·  │(held)│  ·  │
                        └─────┴─────┴─────┘   └─────┴─────┴─────┘
```

| Key | Linux / Windows | macOS |
|-----|-----------------|-------|
| SAll / Save / Find | Ctrl+A / Ctrl+S / Ctrl+F | Cmd+A / Cmd+S / Cmd+F |
| Undo / Redo | Ctrl+Z / Ctrl+Shift+Z | Cmd+Z / Cmd+Shift+Z |
| Cut / Copy / Paste | Ctrl+X / C / V | Cmd+X / C / V |
| WrdL / WrdR (word jump) | Ctrl+← / Ctrl+→ | Option+← / Option+→ |
| DWb / DWf (delete word) | Ctrl+Bksp / Ctrl+Del | Option+Bksp / Option+Del |
| Home / End (line) | Home / End | Cmd+← / Cmd+→ |

Left Shift stays live on this layer, so Shift + the nav block selects text.

### OS mode toggle

Press **Space + Enter** together (a combo with a 50 ms window) to switch
between Linux/Windows and macOS mode. The keyboard plays a short tone: two
rising low notes for Linux, two falling high notes for Mac. The mode is saved
in EEPROM and survives power cycles.

In Mac mode, the firmware swaps left Ctrl and left GUI (`swap_lctl_lgui`), so
the left-thumb Ctrl key sends Cmd.

| Action | Linux / Windows | macOS |
|--------|-----------------|-------|
| Copy / Paste (base inner column) | Ctrl+C / Ctrl+V | Cmd+C / Cmd+V (via swap) |
| Snap window left / right | Super+← / Super+→ | Ctrl+Alt+← / Ctrl+Alt+→ |
| Snap up / maximize | Super+↑ | Ctrl+Alt+↑ |
| Screenshot (Snap) | PrintScreen | Cmd+Shift+4 |
| Terminal toggle (Term) | Ctrl+` | Cmd+` |
| App launcher (Lchr) | Tap Super (GNOME Activities) | Cmd+Space (Spotlight) |
| Lock screen | Super+L | Cmd+Ctrl+Q |

### RGB themes

Hold **Nav**, then tap a key on the Q row. Your choice is saved in EEPROM.

| Keys | Theme | Effect |
|------|-------|--------|
| Nav + Q | Beach *(default)* | Teal brightness band rolling across like waves |
| Nav + W | Ocean | Slow cyan breathing |
| Nav + E | Aurora | Hue breathing through green/teal/blue |
| Nav + R | Starfield | Soft cool blue-white twinkle |
| Nav + T | Cyberpunk | Magenta base, neon crosshairs on keypress |
| Nav + Y | Forest | Green breathing |
| Nav + U | Party | Spinning rainbow pinwheel |
| Nav + I | Splash | Lavender ripple from each keypress |
| Nav + O | Next | Cycle to the next theme |
| Nav + P | Off | LEDs off |

### Firmware files and workflow

| File | Purpose |
|------|---------|
| `keyboards/moonlander/keymap.c` | Layers, custom keycodes, OS-aware macros, themes |
| `keyboards/moonlander/config.h` | `TAPPING_TERM 200`, `PERMISSIVE_HOLD`, `COMBO_TERM 50`, enabled RGB effects |
| `keyboards/moonlander/rules.mk` | `COMBO_ENABLE`, `AUDIO_ENABLE` |
| `keyboards/moonlander/keymap.json` | QMK keymap metadata |
| `keymap.txt` | Printable reference generated from `keymap.c` |

```bash
./scripts/setup_moonlander.sh        # One-time: install QMK dependencies
./scripts/build_moonlander.sh        # Build against ZSA's QMK fork (zsa/moonlander/revb)
./scripts/flash_moonlander.sh        # Flash the built .bin via Keymapp
./scripts/print_moonlander_keymap.sh > keymap.txt   # Regenerate the printable reference
```

`setup.sh` does not install the Moonlander dependencies by default (that step
is commented out). Run `setup_moonlander.sh` yourself when you need it.

---

## WezTerm key bindings

These are defined in `dotfiles/.wezterm.lua` and symlinked to
`~/.wezterm.lua`. Other settings: Monokai Pro (Gogh) color scheme, JetBrains
Mono 11pt, WebGPU front end at 120 fps, 95% opacity, 10,000-line scrollback.

| Keys | Action |
|------|--------|
| Ctrl+Shift+D (`key = 'd'`) | Split pane horizontally (side by side) |
| Ctrl+Shift+D (`key = 'D'`) | Split pane vertically (stacked) |
| Ctrl+Shift+← / → / ↑ / ↓ | Move focus to the pane in that direction |
| Ctrl+Shift+W | Close the current pane (asks first) |

> Both split bindings are written as Ctrl+Shift with `d` and `D`, which is the
> same physical chord. Depending on how WezTerm normalizes Shift, only one of
> them may fire. If that happens, move one to a different key.

---

## Stream Deck button grids

`scripts/setup_streamdeck.sh` installs `streamdeck-gui-ng` and loads a
3×5 (15-key) layout. `STREAMDECK_SCRIPTS` is replaced with the path to
`streamdeck/scripts/` at install time. Replace `YOUR_SERIAL_HERE` in the
config with your device serial.

### Default: `streamdeck/config.json` (Linux dev)

```
┌──────────┬──────────┬──────────┬──────────┬──────────┐
│ Terminal │ VS Code  │ Browser  │   k9s    │  Files   │   launchers
├──────────┼──────────┼──────────┼──────────┼──────────┤
│ CPU/Mem  │  Docker  │   K8s    │   Disk   │ Network  │   live status (press = detail view)
├──────────┼──────────┼──────────┼──────────┼──────────┤
│Screenshot│   Lock   │  Vol −   │  Vol +   │   Mute   │   system
└──────────┴──────────┴──────────┴──────────┴──────────┘
```

`streamdeck-status-update.sh` refreshes row 2 (buttons 5–9) on a timer with
output from the `status-*.sh` scripts. Pressing a status key runs the script
with `--detail`, which opens htop, `docker ps`, k9s, a disk breakdown, or
network info.

### Work template: `streamdeck/configs/work-template.json` (macOS)

```
┌──────────┬──────────┬──────────┬──────────┬──────────┐
│  Slack   │  Teams   │   Mail   │ Calendar │ Browser  │   apps
├──────────┼──────────┼──────────┼──────────┼──────────┤
│ Claude 1 │  ⏳ C1   │  ⚠ C1    │  ✅ C1   │  👁 C1   │   Claude session 1
├──────────┼──────────┼──────────┼──────────┼──────────┤
│ Claude 2 │  ⏳ C2   │  ⚠ C2    │  ✅ C2   │  👁 C2   │   Claude session 2
└──────────┴──────────┴──────────┴──────────┴──────────┘
```

- **Claude N** runs `claude-launch.sh N`, which starts Claude Code in a named
  tmux session.
- **⏳ / ⚠ / ✅** run `claude-status.sh N <in_progress|needs_attention|complete>`
  to set the session's status indicator.
- **👁** runs `claude-focus.sh N`, which switches to that tmux session.
