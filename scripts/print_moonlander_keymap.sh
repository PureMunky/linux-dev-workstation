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
# Parse the LAYOUT_moonlander() calls to extract key names per layer
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
    [KC_LEFT]="Left"   [KC_RGHT]="Right" [KC_UP]="Up"       [KC_DOWN]="Down"
    [KC_HOME]="Home"   [KC_END]="End"    [KC_PGUP]="PgUp"   [KC_PGDN]="PgDn"
    # Editing
    [KC_ENT]="Enter"   [KC_ESC]="Esc"    [KC_BSPC]="Bksp"  [KC_TAB]="Tab"
    [KC_SPC]="Space"   [KC_DEL]="Del"    [KC_INS]="Ins"     [KC_PSCR]="PrtSc"
    [KC_PENT]="PdEnt"
    # F-keys
    [KC_F1]="F1"   [KC_F2]="F2"   [KC_F3]="F3"   [KC_F4]="F4"
    [KC_F5]="F5"   [KC_F6]="F6"   [KC_F7]="F7"   [KC_F8]="F8"
    [KC_F9]="F9"   [KC_F10]="F10" [KC_F11]="F11"  [KC_F12]="F12"
    # Custom keycodes
    [CU_SNAP]="Snap"   [CU_TERM]="Term"  [CU_WLFT]="WinL"  [CU_WRGT]="WinR"
    [OS_TOGG]="OSTog"
    # Transparent / blocked
    [_______]="  ."    [XXXXXXX]=" "
)

# Extract keys from a LAYOUT_moonlander() block given a layer name pattern
# Returns an array of key labels
extract_layer_keys() {
    local layer_pattern="$1"
    local in_layout=0
    local keys=()

    while IFS= read -r line; do
        # Detect start of the target layout block
        if [[ "$line" =~ $layer_pattern.*LAYOUT_moonlander ]]; then
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
        cleaned="${line//,/ }"
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
            elif [[ "$token" =~ ^KC_ || "$token" =~ ^CU_ || "$token" =~ ^OS_ ]]; then
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

    # Moonlander layout: 72 keys total
    # Row 0-3: 7 left + 7 right = 14 per row (56 total)
    # Row 4:   5 left + 5 right = 10
    # Thumb:   3 left + 3 right = 6
    # Total: 56 + 10 + 6 = 72

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

    # Key widths
    local W=5  # standard key cell width

    # Row rendering function
    # Args: index_start, count_left, count_right
    render_row() {
        local start=$1 left_count=$2 right_count=$3
        local sep_l="" sep_r="" row_l="" row_r=""
        local i

        # Left side
        for (( i=start; i<start+left_count; i++ )); do
            local label
            label="$(pad "${keys[$i]}" $W)"
            if [[ $i -eq $start ]]; then
                row_l="│${label}"
            else
                row_l="${row_l}│${label}"
            fi
        done
        row_l="${row_l}│"

        # Right side
        local rstart=$(( start + left_count ))
        for (( i=rstart; i<rstart+right_count; i++ )); do
            local label
            label="$(pad "${keys[$i]}" $W)"
            if [[ $i -eq $rstart ]]; then
                row_r="│${label}"
            else
                row_r="${row_r}│${label}"
            fi
        done
        row_r="${row_r}│"

        echo "  ${row_l}   ${row_r}"
    }

    render_border() {
        local left_count=$1 right_count=$2 char_l=$3 char_m=$4 char_r=$5
        local line_l="" line_r=""
        local i

        for (( i=0; i<left_count; i++ )); do
            local seg
            seg=$(printf '%0.s─' $(seq 1 $W))
            if [[ $i -eq 0 ]]; then
                line_l="${char_l}${seg}"
            else
                line_l="${line_l}${char_m}${seg}"
            fi
        done
        line_l="${line_l}${char_r}"

        for (( i=0; i<right_count; i++ )); do
            local seg
            seg=$(printf '%0.s─' $(seq 1 $W))
            if [[ $i -eq 0 ]]; then
                line_r="${char_l}${seg}"
            else
                line_r="${line_r}${char_m}${seg}"
            fi
        done
        line_r="${line_r}${char_r}"

        echo "  ${line_l}   ${line_r}"
    }

    # Rows 0-3: 7+7
    for row in 0 1 2 3; do
        local idx=$(( row * 14 ))
        if [[ $row -eq 0 ]]; then
            render_border 7 7 "┌" "┬" "┐"
        else
            render_border 7 7 "├" "┼" "┤"
        fi
        render_row $idx 7 7
    done

    # Helper to build a border of N cells
    border_of() {
        local count=$1 cl=$2 cm=$3 cr=$4
        local line=""
        for (( i=0; i<count; i++ )); do
            local seg
            seg=$(printf '%0.s─' $(seq 1 $W))
            if [[ $i -eq 0 ]]; then line="${cl}${seg}"; else line="${line}${cm}${seg}"; fi
        done
        echo "${line}${cr}"
    }

    # Row 4: 5 left + 5 right (bottom row, no outer columns)
    # Transition border: left 5 connect to row above, right 5 connect to row above
    local seg
    seg=$(printf '%0.s─' $(seq 1 $W))
    local trans_l="├${seg}┼${seg}┼${seg}┼${seg}┼${seg}┤"
    local trans_r="├${seg}┼${seg}┼${seg}┼${seg}┼${seg}┤"
    echo "  ${trans_l}                     ${trans_r}"

    local row4_l="" row4_r=""
    for (( i=56; i<61; i++ )); do
        local label
        label="$(pad "${keys[$i]}" $W)"
        if [[ $i -eq 56 ]]; then row4_l="│${label}"; else row4_l="${row4_l}│${label}"; fi
    done
    row4_l="${row4_l}│"
    for (( i=61; i<66; i++ )); do
        local label
        label="$(pad "${keys[$i]}" $W)"
        if [[ $i -eq 61 ]]; then row4_r="│${label}"; else row4_r="${row4_r}│${label}"; fi
    done
    row4_r="${row4_r}│"
    echo "  ${row4_l}                     ${row4_r}"

    local bl br
    bl="$(border_of 5 "└" "┴" "┘")"
    br="$(border_of 5 "└" "┴" "┘")"
    echo "  ${bl}                     ${br}"

    # Thumb cluster: 3+3 (indices 66-71)
    local thumb_border
    thumb_border="$(border_of 3 "┌" "┬" "┐")"
    echo "                          ${thumb_border}   ${thumb_border}"
    local thumb_l="" thumb_r=""
    for (( i=66; i<69; i++ )); do
        local label
        label="$(pad "${keys[$i]}" $W)"
        if [[ $i -eq 66 ]]; then thumb_l="│${label}"; else thumb_l="${thumb_l}│${label}"; fi
    done
    thumb_l="${thumb_l}│"
    for (( i=69; i<72; i++ )); do
        local label
        label="$(pad "${keys[$i]}" $W)"
        if [[ $i -eq 69 ]]; then thumb_r="│${label}"; else thumb_r="${thumb_r}│${label}"; fi
    done
    thumb_r="${thumb_r}│"
    echo "                          ${thumb_l}   ${thumb_r}"
    thumb_border="$(border_of 3 "└" "┴" "┘")"
    echo "                          ${thumb_border}   ${thumb_border}"
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

echo ""
echo "${BOLD}╔══════════════════════════════════════════════════════════════════════════════╗${RESET}"
echo "${BOLD}║                     MOONLANDER KEYMAP REFERENCE                             ║${RESET}"
echo "${BOLD}╚══════════════════════════════════════════════════════════════════════════════╝${RESET}"

# --- Layer 0: Base ---
echo ""
echo "${BOLD}  LAYER 0: BASE (QWERTY)${RESET}"
echo ""
extract_layer_keys '\[_BASE\]' | render_layer

# --- Layer 1: Nav ---
echo ""
echo "${BOLD}  LAYER 1: NAV / FUNCTION  (hold Nav thumb key)${RESET}"
echo "  ( . = transparent, falls through to base layer)"
echo ""
extract_layer_keys '\[_NAV\]' | render_layer

# --- OS mode reference ---
echo ""
echo "${BOLD}  OS MODE TOGGLE${RESET}"
echo "  Press Space + Enter simultaneously to switch modes."
echo "  Mode is saved to EEPROM and persists across power cycles."
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
echo "  Generated from: keyboards/moonlander/keymap.c"
echo "  Date: $(date +%Y-%m-%d)"
echo ""
