#!/bin/bash

# print_moonlander_keymap.sh - Generates a printable keymap reference from keymap.c
#
# Usage: ./scripts/print_moonlander_keymap.sh          (prints to stdout)
#        ./scripts/print_moonlander_keymap.sh > keymap.txt  (save to file)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KEYMAP_FILE="$SCRIPT_DIR/keyboards/moonlander/keymap.c"

if [[ ! -f "$KEYMAP_FILE" ]]; then
    echo "Error: keymap.c not found at $KEYMAP_FILE" >&2
    exit 1
fi

# ---------------------------------------------------------------------------
# Parse the LAYOUT() calls to extract key names per layer
# ---------------------------------------------------------------------------

# Map QMK keycodes to readable labels (5 chars max for alignment)
declare -A KC_MAP=(
    # Letters
    [KC_A]="A"     [KC_B]="B"     [KC_C]="C"     [KC_D]="D"     [KC_E]="E"
    [KC_F]="F"     [KC_G]="G"     [KC_H]="H"     [KC_I]="I"     [KC_J]="J"
    [KC_K]="K"     [KC_L]="L"     [KC_M]="M"     [KC_N]="N"     [KC_O]="O"
    [KC_P]="P"     [KC_Q]="Q"     [KC_R]="R"     [KC_S]="S"     [KC_T]="T"
    [KC_U]="U"     [KC_V]="V"     [KC_W]="W"     [KC_X]="X"     [KC_Y]="Y"
    [KC_Z]="Z"
    # Numbers
    [KC_0]="0"     [KC_1]="1"     [KC_2]="2"     [KC_3]="3"     [KC_4]="4"
    [KC_5]="5"     [KC_6]="6"     [KC_7]="7"     [KC_8]="8"     [KC_9]="9"
    # Symbols
    [KC_MINS]="-"       [KC_EQL]="="      [KC_LBRC]="["     [KC_RBRC]="]"
    [KC_BSLS]="\\"      [KC_GRV]="\`"     [KC_QUOT]="'"     [KC_SCLN]=";"
    [KC_COMM]=","       [KC_DOT]="."      [KC_SLSH]="/"     [KC_LCBR]="{"
    [KC_RCBR]="}"
    # Modifiers
    [KC_LCTL]="Ctrl"   [KC_RCTL]="Ctrl"  [KC_LSFT]="Shift" [KC_RSFT]="Shift"
    [KC_LALT]="Alt"    [KC_RALT]="Alt"   [KC_LGUI]="GUI"    [KC_RGUI]="GUI"
    # Navigation
    [KC_LEFT]="←"      [KC_RGHT]="→"     [KC_UP]="↑"        [KC_DOWN]="↓"
    [KC_HOME]="Home"   [KC_END]="End"    [KC_PGUP]="PgUp"   [KC_PGDN]="PgDn"
    # Editing
    [KC_ENT]="Enter"   [KC_ESC]="Esc"    [KC_BSPC]="Bksp"  [KC_TAB]="Tab"
    [KC_SPC]="Space"   [KC_DEL]="Del"    [KC_INS]="Ins"     [KC_PSCR]="PrtSc"
    [KC_PENT]="PdEnt"
    # Media
    [KC_VOLU]="Vol+"   [KC_VOLD]="Vol-"   [KC_MUTE]="Mute"
    [KC_MNXT]="Next"   [KC_MPRV]="Prev"   [KC_MPLY]="Play"
    # F-keys
    [KC_F1]="F1"   [KC_F2]="F2"   [KC_F3]="F3"   [KC_F4]="F4"
    [KC_F5]="F5"   [KC_F6]="F6"   [KC_F7]="F7"   [KC_F8]="F8"
    [KC_F9]="F9"   [KC_F10]="F10" [KC_F11]="F11"  [KC_F12]="F12"
    # Custom keycodes
    [CU_SNAP]="Snap"   [CU_TERM]="Term"  [CU_WLFT]="WinL"  [CU_WRGT]="WinR"  [CU_WUP]="WinUp"
    [CU_OSTOGG]="OSTog" [CU_LOCK]="Lock"
    # Theme selectors (Layer 1)
    [CU_TH_BC]="Beach" [CU_TH_OC]="Ocean" [CU_TH_AU]="Auror" [CU_TH_SF]="Star" [CU_TH_CP]="Cyber"
    [CU_TH_FO]="Frst"  [CU_TH_PT]="Prty"  [CU_TH_SP]="Splsh" [CU_TH_NX]="Next" [CU_TH_OF]="Off"
    # Transparent / blocked
    [_______]="·"      [XXXXXXX]=""
)

# Extract keys from a LAYOUT() block given a layer name pattern
# Returns an array of key labels
extract_layer_keys() {
    local layer_pattern="$1"
    local in_layout=0
    local keys=()

    while IFS= read -r line; do
        # Detect start of the target layout block
        if [[ "$line" =~ $layer_pattern.*LAYOUT ]]; then
            in_layout=1
            continue
        fi
        if [[ $in_layout -eq 0 ]]; then
            continue
        fi
        # Detect end of layout block
        if [[ "$line" =~ ^\) ]]; then
            break
        fi
        # Skip comments and blank lines
        [[ "$line" =~ ^[[:space:]]*//.* ]] && continue
        [[ -z "${line// /}" ]] && continue

        # Extract keycodes from this line
        # First, resolve C(x) → Ctrl+label, S(x) → Shft+label, etc.
        cleaned="$line"
        while [[ "$cleaned" =~ C\(([A-Z_0-9]+)\) ]]; do
            local inner="${BASH_REMATCH[1]}"
            local inner_label="${KC_MAP[$inner]:-${inner#KC_}}"
            local replacement="CX_${inner_label// /}"
            KC_MAP["$replacement"]="C+${inner_label}"
            cleaned="${cleaned/C(${inner})/$replacement}"
        done
        cleaned="${cleaned//,/ }"
        for token in $cleaned; do
            token="$(echo "$token" | xargs)"
            [[ -z "$token" ]] && continue
            # Handle MO() layer keys
            if [[ "$token" =~ ^MO\((.+)\)$ ]]; then
                local layer_num="${BASH_REMATCH[1]}"
                case "$layer_num" in
                    _NAV|1)  keys+=("Nav")  ;;
                    _BASE|0) keys+=("Base") ;;
                    *)       keys+=("L${layer_num}") ;;
                esac
                continue
            fi
            # Look up in map
            if [[ -n "${KC_MAP[$token]+x}" ]]; then
                keys+=("${KC_MAP[$token]}")
            elif [[ "$token" =~ ^KC_ || "$token" =~ ^CU_ || "$token" =~ ^OS_ || "$token" =~ ^CX_ ]]; then
                # Unknown keycode - use short form
                local short="${token#KC_}"
                short="${short#CU_}"
                short="${short#OS_}"
                keys+=("$short")
            fi
        done
    done < "$KEYMAP_FILE"

    printf '%s\n' "${keys[@]}"
}

# ---------------------------------------------------------------------------
# Render a layer as a formatted ASCII keyboard diagram
# ---------------------------------------------------------------------------
render_layer() {
    local -a keys=()
    while IFS= read -r line; do
        keys+=("$line")
    done

    # ZSA fork LAYOUT for Moonlander rev B: 72 keys total
    # Row 0-2: 7 left + 7 right = 14 per row (42 total)
    # Row 3:   6 left + 6 right = 12 (no inner big key)
    # Row 4:   5 left + big + big + 5 right = 12
    # Thumb:   3 left + 3 right = 6
    # Total: 42 + 12 + 12 + 6 = 72

    if [[ ${#keys[@]} -lt 72 ]]; then
        echo "  (incomplete layer data: got ${#keys[@]} keys, expected 72)" >&2
        return
    fi

    # Helper: pad/truncate a label to exactly N chars, centered
    pad() {
        local label="$1" width="$2"
        local len=${#label}
        if (( len >= width )); then
            echo "${label:0:$width}"
        else
            local total_pad=$(( width - len ))
            local left_pad=$(( total_pad / 2 ))
            local right_pad=$(( total_pad - left_pad ))
            printf '%*s%s%*s' "$left_pad" "" "$label" "$right_pad" ""
        fi
    }

    local W=5  # standard key cell width
    local S="─────"  # segment (W dashes)

    # Build a row of cells from keys array
    # Args: start_index count
    build_row() {
        local start=$1 count=$2 out=""
        for (( i=start; i<start+count; i++ )); do
            out="${out}│$(pad "${keys[$i]}" $W)"
        done
        echo "${out}│"
    }

    # Build a border line of N cells
    # Args: count left_char mid_char right_char
    build_border() {
        local count=$1 cl=$2 cm=$3 cr=$4 out=""
        for (( i=0; i<count; i++ )); do
            if [[ $i -eq 0 ]]; then out="${cl}${S}"; else out="${out}${cm}${S}"; fi
        done
        echo "${out}${cr}"
    }

    local G="   "  # gap between halves

    # Rows 0-2: 7 left + 7 right
    for row in 0 1 2; do
        local idx=$(( row * 14 ))
        local cl="┌" cm="┬" cr="┐"
        if [[ $row -gt 0 ]]; then cl="├"; cm="┼"; cr="┤"; fi
        echo "  $(build_border 7 $cl $cm $cr)${G}$(build_border 7 $cl $cm $cr)"
        echo "  $(build_row $idx 7)${G}$(build_row $((idx+7)) 7)"
    done

    # Row 3: 6 left + 6 right (no inner column)
    # gap = 91 - 2 - 37 - 37 = 15
    local G3="               "  # 15 spaces
    echo "  $(build_border 6 "├" "┼" "┤")${G3}$(build_border 6 "├" "┼" "┤")"
    echo "  $(build_row 42 6)${G3}$(build_row 48 6)"
    echo "  $(build_border 6 "└" "┴" "┘")${G3}$(build_border 6 "└" "┴" "┘")"

    # Row 4: 5 left + 5 right
    # gap = 91 - 2 - 31 - 31 = 27
    local G4="                           "  # 27 spaces
    echo "  $(build_border 5 "┌" "┬" "┐")${G4}$(build_border 5 "┌" "┬" "┐")"
    echo "  $(build_row 54 5)${G4}$(build_row 61 5)"
    echo "  $(build_border 5 "└" "┴" "┘")${G4}$(build_border 5 "└" "┴" "┘")"

    # Big keys (indices 59 and 60) — centered
    local big_l big_r
    big_l="$(pad "${keys[59]}" $W)"
    big_r="$(pad "${keys[60]}" $W)"
    echo "                              ┌─────┐   ┌─────┐"
    echo "                              │${big_l}│   │${big_r}│"
    echo "                              └─────┘   └─────┘"

    # Thumb cluster: 3 left + 3 right (indices 66-71) — centered
    echo "                          $(build_border 3 "┌" "┬" "┐")${G}$(build_border 3 "┌" "┬" "┐")"
    echo "                          $(build_row 66 3)${G}$(build_row 69 3)"
    echo "                          $(build_border 3 "└" "┴" "┘")${G}$(build_border 3 "└" "┴" "┘")"
}

# ---------------------------------------------------------------------------
# Main output
# ---------------------------------------------------------------------------

BOLD=''
RESET=''
# Enable bold if outputting to a terminal
if [[ -t 1 ]]; then
    BOLD=$'\033[1m'
    RESET=$'\033[0m'
fi

DIV="  ──────────────────────────────────────────────────────────────────────────────"

echo ""
echo "${BOLD}  MOONLANDER KEYMAP REFERENCE${RESET}"
echo "$DIV"

# --- Layer 0: Base ---
echo ""
echo "${BOLD}  LAYER 0 — BASE (QWERTY)${RESET}"
echo ""
extract_layer_keys '\[_BASE\]' | render_layer

# --- Layer 1: Nav ---
echo ""
echo "$DIV"
echo ""
echo "${BOLD}  LAYER 1 — NAV / FUNCTION  (hold any Nav key)${RESET}"
echo "  · = transparent, falls through to base layer"
echo ""
extract_layer_keys '\[_NAV\]' | render_layer

# --- OS mode reference ---
echo ""
echo "$DIV"
echo ""
echo "${BOLD}  OS MODE TOGGLE  (Space + Enter simultaneously)${RESET}"
echo "  Mode persists across power cycles (stored in EEPROM)."
echo ""
echo "  ┌──────────────────┬──────────────────────┬──────────────────────┐"
echo "  │ Action           │ Linux / Windows       │ macOS                │"
echo "  ├──────────────────┼──────────────────────┼──────────────────────┤"
echo "  │ Copy / Paste     │ Ctrl+C / Ctrl+V      │ Cmd+C / Cmd+V       │"
echo "  │ Alt-Tab          │ Alt+Tab               │ Alt+Tab (via addon)  │"
echo "  │ Snap left        │ Super+Left            │ Alt+Ctrl+Left        │"
echo "  │ Snap right       │ Super+Right           │ Alt+Ctrl+Right       │"
echo "  │ Screenshot       │ PrintScreen           │ Cmd+Shift+4          │"
echo "  │ Terminal toggle  │ Ctrl+\`               │ Cmd+\`               │"
echo "  └──────────────────┴──────────────────────┴──────────────────────┘"
echo ""
echo "  Ctrl/Cmd swap is automatic — physical Ctrl key sends Cmd in Mac mode."
echo ""
echo "$DIV"
echo ""
echo "${BOLD}  RGB THEMES  (Layer 1, Q-row)${RESET}"
echo "  Hold Nav, then tap a theme key. Current theme persists across reboots."
echo ""
echo "  ┌──────────┬──────────────────────────────────────────────┐"
echo "  │ Nav + Q  │ Beach      — teal wave rolls across keys    │"
echo "  │ Nav + W  │ Ocean      — slow cyan breathing             │"
echo "  │ Nav + E  │ Aurora     — hue breathing, northern lights  │"
echo "  │ Nav + R  │ Starfield  — cool blue twinkle               │"
echo "  │ Nav + T  │ Cyberpunk  — magenta, neon cross on keypress │"
echo "  │ Nav + Y  │ Forest     — green breathing                 │"
echo "  │ Nav + U  │ Party      — spinning rainbow pinwheel       │"
echo "  │ Nav + I  │ Splash     — lavender ripple on keypress     │"
echo "  │ Nav + O  │ Next       — cycle to the next theme         │"
echo "  │ Nav + P  │ Off        — disable RGB                     │"
echo "  └──────────┴──────────────────────────────────────────────┘"
echo ""
echo "  Generated from: keyboards/moonlander/keymap.c"
echo "  Date: $(date +%Y-%m-%d)"
echo ""
