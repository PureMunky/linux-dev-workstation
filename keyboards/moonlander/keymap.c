// Moonlander QMK Keymap
// QWERTY base with OS-mode toggle (Linux/Windows vs macOS)
//
// OS mode toggle: press Space + Enter simultaneously
// - Linux/Windows: Ctrl on home row, Super for window snapping
// - macOS: Cmd on home row (via Ctrl/GUI swap), Alt+Ctrl for window snapping
//
// Layer 0: Base QWERTY
// Layer 1: Navigation, F-keys, OS-aware shortcuts (hold either MO(1) thumb key)

#include QMK_KEYBOARD_H

// ---------------------------------------------------------------------------
// OS mode: persisted to EEPROM via eeconfig_user
// ---------------------------------------------------------------------------
enum os_mode {
    OS_LINUX = 0,
    OS_MAC   = 1
};

static uint8_t os_mode = OS_LINUX;

// ---------------------------------------------------------------------------
// Custom keycodes
// ---------------------------------------------------------------------------
enum custom_keycodes {
    OS_TOGG = SAFE_RANGE,  // OS mode toggle (fired by combo)
    CU_SNAP,               // Screenshot (OS-aware)
    CU_TERM,               // Terminal toggle (OS-aware)
    CU_WLFT,               // Window snap left (OS-aware)
    CU_WRGT,               // Window snap right (OS-aware)
};

// ---------------------------------------------------------------------------
// Layers
// ---------------------------------------------------------------------------
enum layers {
    _BASE = 0,
    _NAV  = 1,
};

// ---------------------------------------------------------------------------
// Combo: Space + Enter = OS toggle
// ---------------------------------------------------------------------------
const uint16_t PROGMEM os_toggle_combo[] = {KC_SPC, KC_ENT, COMBO_END};

combo_t key_combos[] = {
    COMBO(os_toggle_combo, OS_TOGG),
};

// ---------------------------------------------------------------------------
// EEPROM persistence for OS mode
// ---------------------------------------------------------------------------
void eeconfig_init_user(void) {
    eeconfig_update_user(OS_LINUX);
    os_mode = OS_LINUX;
}

static void apply_os_mode(void) {
    keymap_config.raw = eeconfig_read_keymap();
    if (os_mode == OS_MAC) {
        keymap_config.swap_lctl_lgui = true;
        keymap_config.swap_rctl_rgui = true;
    } else {
        keymap_config.swap_lctl_lgui = false;
        keymap_config.swap_rctl_rgui = false;
    }
    eeconfig_update_keymap(keymap_config.raw);
}

void keyboard_post_init_user(void) {
    os_mode = eeconfig_read_user() & 0xFF;
    if (os_mode > OS_MAC) {
        os_mode = OS_LINUX;
        eeconfig_update_user(OS_LINUX);
    }
    apply_os_mode();
}

static void toggle_os_mode(void) {
    os_mode = (os_mode == OS_LINUX) ? OS_MAC : OS_LINUX;
    eeconfig_update_user(os_mode);
    apply_os_mode();
}

// ---------------------------------------------------------------------------
// Custom keycode handling
// ---------------------------------------------------------------------------
bool process_record_user(uint16_t keycode, keyrecord_t *record) {
    switch (keycode) {

    case OS_TOGG:
        if (record->event.pressed) {
            toggle_os_mode();
        }
        return false;

    case CU_SNAP:
        // Linux/Win: PrintScreen | Mac: Cmd+Shift+4
        if (record->event.pressed) {
            if (os_mode == OS_MAC) {
                register_code(KC_LGUI);
                register_code(KC_LSFT);
                register_code(KC_4);
            } else {
                register_code(KC_PSCR);
            }
        } else {
            if (os_mode == OS_MAC) {
                unregister_code(KC_4);
                unregister_code(KC_LSFT);
                unregister_code(KC_LGUI);
            } else {
                unregister_code(KC_PSCR);
            }
        }
        return false;

    case CU_TERM:
        // Linux/Win: Ctrl+` | Mac: Cmd+`
        if (record->event.pressed) {
            if (os_mode == OS_MAC) {
                register_code(KC_LGUI);
            } else {
                register_code(KC_LCTL);
            }
            register_code(KC_GRV);
        } else {
            unregister_code(KC_GRV);
            if (os_mode == OS_MAC) {
                unregister_code(KC_LGUI);
            } else {
                unregister_code(KC_LCTL);
            }
        }
        return false;

    case CU_WLFT:
        // Linux/Win: Super+Left | Mac: Alt+Ctrl+Left
        if (record->event.pressed) {
            if (os_mode == OS_MAC) {
                register_code(KC_LCTL);
                register_code(KC_LALT);
            } else {
                register_code(KC_LGUI);
            }
            register_code(KC_LEFT);
        } else {
            unregister_code(KC_LEFT);
            if (os_mode == OS_MAC) {
                unregister_code(KC_LALT);
                unregister_code(KC_LCTL);
            } else {
                unregister_code(KC_LGUI);
            }
        }
        return false;

    case CU_WRGT:
        // Linux/Win: Super+Right | Mac: Alt+Ctrl+Right
        if (record->event.pressed) {
            if (os_mode == OS_MAC) {
                register_code(KC_LCTL);
                register_code(KC_LALT);
            } else {
                register_code(KC_LGUI);
            }
            register_code(KC_RGHT);
        } else {
            unregister_code(KC_RGHT);
            if (os_mode == OS_MAC) {
                unregister_code(KC_LALT);
                unregister_code(KC_LCTL);
            } else {
                unregister_code(KC_LGUI);
            }
        }
        return false;
    }

    return true;
}

// ---------------------------------------------------------------------------
// Keymaps
// ---------------------------------------------------------------------------

// clang-format off
const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {

// Base Layer: QWERTY
// ┌───────┬─────┬─────┬─────┬─────┬─────┬─────┐   ┌─────┬─────┬─────┬─────┬─────┬─────┬───────┐
// │  Esc  │  1  │  2  │  3  │  4  │  5  │  =  │   │  -  │  6  │  7  │  8  │  9  │  0  │ Bksp  │
// ├───────┼─────┼─────┼─────┼─────┼─────┼─────┤   ├─────┼─────┼─────┼─────┼─────┼─────┼───────┤
// │  Tab  │  Q  │  W  │  E  │  R  │  T  │  [  │   │  ]  │  Y  │  U  │  I  │  O  │  P  │   \   │
// ├───────┼─────┼─────┼─────┼─────┼─────┼─────┤   ├─────┼─────┼─────┼─────┼─────┼─────┼───────┤
// │ Ctrl  │  A  │  S  │  D  │  F  │  G  │  `  │   │  '  │  H  │  J  │  K  │  L  │  ;  │ Enter │
// ├───────┼─────┼─────┼─────┼─────┼─────┼─────┤   ├─────┼─────┼─────┼─────┼─────┼─────┼───────┤
// │ Shift │  Z  │  X  │  C  │  V  │  B  │ GUI │   │ GUI │  N  │  M  │  ,  │  .  │  /  │ Shift │
// ├───────┼─────┼─────┼─────┼─────┼─────┘─────┘   └─────└─────┼─────┼─────┼─────┼─────┼───────┤
// │       │     │     │     │ Alt │                             │ Alt │     │     │     │       │
// └───────┴─────┴─────┴─────┴─────┘                             └─────┴─────┴─────┴─────┴───────┘
//                             ┌─────┬─────┬─────┐ ┌─────┬─────┬─────┐
//                             │Space│Bksp │MO(1)│ │Enter│ Tab │MO(1)│
//                             └─────┴─────┴─────┘ └─────┴─────┴─────┘
[_BASE] = LAYOUT_moonlander(
    KC_ESC,  KC_1,    KC_2,    KC_3,    KC_4,    KC_5,    KC_EQL,       KC_MINS, KC_6,    KC_7,    KC_8,    KC_9,    KC_0,    KC_BSPC,
    KC_TAB,  KC_Q,    KC_W,    KC_E,    KC_R,    KC_T,    KC_LBRC,      KC_RBRC, KC_Y,    KC_U,    KC_I,    KC_O,    KC_P,    KC_BSLS,
    KC_LCTL, KC_A,    KC_S,    KC_D,    KC_F,    KC_G,    KC_GRV,       KC_QUOT, KC_H,    KC_J,    KC_K,    KC_L,    KC_SCLN, KC_ENT,
    KC_LSFT, KC_Z,    KC_X,    KC_C,    KC_V,    KC_B,    KC_LGUI,      KC_RGUI, KC_N,    KC_M,    KC_COMM, KC_DOT,  KC_SLSH, KC_RSFT,
    XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, KC_LALT,                                         KC_RALT, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX,
                                         KC_SPC,  KC_BSPC, MO(_NAV),    KC_ENT,  KC_TAB,  MO(_NAV)
),

// Nav/Function Layer
// ┌───────┬─────┬─────┬─────┬─────┬─────┬─────┐   ┌─────┬─────┬─────┬─────┬─────┬─────┬───────┐
// │       │ F1  │ F2  │ F3  │ F4  │ F5  │ F11 │   │ F12 │ F6  │ F7  │ F8  │ F9  │ F10 │  Del  │
// ├───────┼─────┼─────┼─────┼─────┼─────┼─────┤   ├─────┼─────┼─────┼─────┼─────┼─────┼───────┤
// │       │     │     │     │     │     │     │   │     │     │     │     │     │     │       │
// ├───────┼─────┼─────┼─────┼─────┼─────┼─────┤   ├─────┼─────┼─────┼─────┼─────┼─────┼───────┤
// │       │     │Snap │     │     │     │     │   │     │  ←  │  ↓  │  ↑  │  →  │     │       │
// ├───────┼─────┼─────┼─────┼─────┼─────┼─────┤   ├─────┼─────┼─────┼─────┼─────┼─────┼───────┤
// │       │     │     │     │     │     │WinL │   │WinR │     │     │     │     │     │       │
// ├───────┼─────┼─────┼─────┼─────┼─────┘─────┘   └─────└─────┼─────┼─────┼─────┼─────┼───────┤
// │       │     │Home │ End │     │                             │     │PgDn │PgUp │     │       │
// └───────┴─────┴─────┴─────┴─────┘                             └─────┴─────┴─────┴─────┴───────┘
//                             ┌─────┬─────┬─────┐ ┌─────┬─────┬─────┐
//                             │     │     │     │ │Term │     │     │
//                             └─────┴─────┴─────┘ └─────┴─────┴─────┘
[_NAV] = LAYOUT_moonlander(
    _______, KC_F1,   KC_F2,   KC_F3,   KC_F4,   KC_F5,   KC_F11,       KC_F12,  KC_F6,   KC_F7,   KC_F8,   KC_F9,   KC_F10,  KC_DEL,
    _______, _______, _______, _______, _______, _______, _______,      _______, _______, _______, _______, _______, _______, _______,
    _______, _______, CU_SNAP, _______, _______, _______, _______,      _______, KC_LEFT, KC_DOWN, KC_UP,   KC_RGHT, _______, _______,
    _______, _______, _______, _______, _______, _______, CU_WLFT,      CU_WRGT, _______, _______, _______, _______, _______, _______,
    _______, _______, KC_HOME, KC_END,  _______,                                          _______, KC_PGDN, KC_PGUP, _______, _______,
                                         _______, _______, _______,      CU_TERM, _______, _______
),

};
// clang-format on
