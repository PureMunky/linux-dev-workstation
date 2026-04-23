// Moonlander QMK Keymap
// QWERTY base with OS-mode toggle (Linux/Windows vs macOS)
//
// OS mode toggle: press Space + Enter simultaneously
// - Linux/Windows: Ctrl on home row, Super for window snapping
// - macOS: Cmd on home row (via Ctrl/GUI swap), Alt+Ctrl for window snapping
//
// Layer 0: Base QWERTY
// Layer 1: Navigation, F-keys, OS-aware shortcuts, RGB theme selection
//
// RGB themes (Layer 1, Q-row): Beach, Ocean, Aurora, Starfield, Cyberpunk,
// Forest, Party, Splash, plus cycle-next and off. Selection persists to EEPROM.

#include QMK_KEYBOARD_H

#ifdef AUDIO_ENABLE
#include "song_list.h"
// Linux mode: two low ascending notes
float song_linux[][2] = SONG(E__NOTE(_E5), E__NOTE(_G5));
// Mac mode: two higher descending notes
float song_mac[][2]   = SONG(E__NOTE(_A5), E__NOTE(_E5));
#endif

// ---------------------------------------------------------------------------
// OS mode + theme mode: packed into a single eeconfig_user word
// ---------------------------------------------------------------------------
enum os_mode {
    OS_LINUX = 0,
    OS_MAC   = 1
};

enum theme_mode {
    THEME_BEACH = 0,     // Teal brightness band rolling across like waves
    THEME_OCEAN,         // Slow cyan breathing
    THEME_AURORA,        // Hue-breathing through green/teal/blue
    THEME_STARFIELD,     // Soft cool twinkle
    THEME_CYBERPUNK,     // Magenta base, neon crosshairs on keypress
    THEME_FOREST,        // Green breathing
    THEME_PARTY,         // Rainbow pinwheel
    THEME_SPLASH,        // Lavender ripple expands from each keypress
    THEME_OFF,           // LEDs off
    THEME_COUNT
};

typedef union {
    uint32_t raw;
    struct {
        uint8_t os_mode;
        uint8_t theme_mode;
    };
} user_config_t;

static user_config_t user_config;

// ---------------------------------------------------------------------------
// Custom keycodes
// ---------------------------------------------------------------------------
enum custom_keycodes {
    CU_OSTOGG = ZSA_SAFE_RANGE,  // OS mode toggle (fired by combo)
    CU_SNAP,               // Screenshot (OS-aware)
    CU_TERM,               // Terminal toggle (OS-aware)
    CU_WLFT,               // Window snap left (OS-aware)
    CU_WRGT,               // Window snap right (OS-aware)
    CU_WUP,                // Window snap up / maximize (OS-aware)
    CU_LOCK,               // Lock screen (OS-aware)
    CU_TH_BC,              // Theme: Beach
    CU_TH_OC,              // Theme: Ocean
    CU_TH_AU,              // Theme: Aurora
    CU_TH_SF,              // Theme: Starfield
    CU_TH_CP,              // Theme: Cyberpunk
    CU_TH_FO,              // Theme: Forest
    CU_TH_PT,              // Theme: Party
    CU_TH_SP,              // Theme: Splash
    CU_TH_NX,              // Theme: cycle next
    CU_TH_OF,              // Theme: Off
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
    COMBO(os_toggle_combo, CU_OSTOGG),
};

// ---------------------------------------------------------------------------
// EEPROM persistence for OS + theme
// ---------------------------------------------------------------------------
static void save_user_config(void) {
    eeconfig_update_user(user_config.raw);
}

void eeconfig_init_user(void) {
    user_config.raw        = 0;
    user_config.os_mode    = OS_LINUX;
    user_config.theme_mode = THEME_BEACH;
    save_user_config();
}

static void apply_os_mode(void) {
    eeconfig_read_keymap(&keymap_config);
    if (user_config.os_mode == OS_MAC) {
        keymap_config.swap_lctl_lgui = true;
    } else {
        keymap_config.swap_lctl_lgui = false;
    }
    eeconfig_update_keymap(&keymap_config);
}

static void apply_theme(void) {
#ifdef RGB_MATRIX_ENABLE
    // Moonlander's RGB_TOG persists LED_FLAG_NONE to EEPROM, which blanks
    // all LEDs regardless of mode. Restore LED_FLAG_ALL on every non-OFF
    // theme so the matrix is visible again.
    if (user_config.theme_mode != THEME_OFF) {
        rgb_matrix_set_flags(LED_FLAG_ALL);
    }
    switch (user_config.theme_mode) {
    case THEME_BEACH:
        // Brightness band rolling horizontally across a teal background
        rgb_matrix_enable_noeeprom();
        rgb_matrix_mode_noeeprom(RGB_MATRIX_BAND_VAL);
        rgb_matrix_sethsv_noeeprom(132, 255, 220);  // teal/sea
        rgb_matrix_set_speed_noeeprom(100);         // wave cadence
        break;
    case THEME_OCEAN:
        rgb_matrix_enable_noeeprom();
        rgb_matrix_mode_noeeprom(RGB_MATRIX_BREATHING);
        rgb_matrix_sethsv_noeeprom(140, 255, 200);  // teal/cyan
        rgb_matrix_set_speed_noeeprom(60);          // slow swell
        break;
    case THEME_AURORA:
        // Slow hue breathing around green/teal — northern lights
        rgb_matrix_enable_noeeprom();
        rgb_matrix_mode_noeeprom(RGB_MATRIX_HUE_BREATHING);
        rgb_matrix_sethsv_noeeprom(110, 255, 200);
        rgb_matrix_set_speed_noeeprom(50);
        break;
    case THEME_STARFIELD:
        rgb_matrix_enable_noeeprom();
        rgb_matrix_mode_noeeprom(RGB_MATRIX_STARLIGHT_SMOOTH);
        rgb_matrix_sethsv_noeeprom(170, 180, 180);  // cool blue-white twinkle
        rgb_matrix_set_speed_noeeprom(70);
        break;
    case THEME_CYBERPUNK:
        // Magenta base, neon crosshairs fire from each keypress
        rgb_matrix_enable_noeeprom();
        rgb_matrix_mode_noeeprom(RGB_MATRIX_SOLID_REACTIVE_MULTICROSS);
        rgb_matrix_sethsv_noeeprom(213, 255, 230);
        rgb_matrix_set_speed_noeeprom(180);
        break;
    case THEME_FOREST:
        rgb_matrix_enable_noeeprom();
        rgb_matrix_mode_noeeprom(RGB_MATRIX_BREATHING);
        rgb_matrix_sethsv_noeeprom(85, 255, 180);   // green
        rgb_matrix_set_speed_noeeprom(80);
        break;
    case THEME_PARTY:
        rgb_matrix_enable_noeeprom();
        rgb_matrix_mode_noeeprom(RGB_MATRIX_CYCLE_PINWHEEL);
        rgb_matrix_set_speed_noeeprom(200);
        break;
    case THEME_SPLASH:
        // Lavender ripple expands outward from each keypress
        rgb_matrix_enable_noeeprom();
        rgb_matrix_mode_noeeprom(RGB_MATRIX_SOLID_MULTISPLASH);
        rgb_matrix_sethsv_noeeprom(200, 220, 220);
        rgb_matrix_set_speed_noeeprom(150);
        break;
    case THEME_OFF:
        rgb_matrix_disable_noeeprom();
        break;
    }
#endif
}

void keyboard_post_init_user(void) {
    user_config.raw = eeconfig_read_user();
    if (user_config.os_mode > OS_MAC) {
        user_config.os_mode = OS_LINUX;
    }
    if (user_config.theme_mode >= THEME_COUNT) {
        user_config.theme_mode = THEME_BEACH;
    }
    apply_os_mode();
    apply_theme();
}

static void toggle_os_mode(void) {
    user_config.os_mode = (user_config.os_mode == OS_LINUX) ? OS_MAC : OS_LINUX;
    save_user_config();
    apply_os_mode();
#ifdef AUDIO_ENABLE
    if (user_config.os_mode == OS_MAC) {
        PLAY_SONG(song_mac);
    } else {
        PLAY_SONG(song_linux);
    }
#endif
}

static void set_theme(uint8_t theme) {
    if (theme >= THEME_COUNT) return;
    user_config.theme_mode = theme;
    save_user_config();
    apply_theme();
}

static void cycle_theme(void) {
    uint8_t next = (user_config.theme_mode + 1) % THEME_COUNT;
    set_theme(next);
}

// ---------------------------------------------------------------------------
// Custom keycode handling
// ---------------------------------------------------------------------------
bool process_record_user(uint16_t keycode, keyrecord_t *record) {
    switch (keycode) {

    case CU_OSTOGG:
        if (record->event.pressed) {
            toggle_os_mode();
        }
        return false;

    case CU_SNAP:
        // Linux/Win: PrintScreen | Mac: Cmd+Shift+4
        if (record->event.pressed) {
            if (user_config.os_mode == OS_MAC) {
                register_code(KC_LGUI);
                register_code(KC_LSFT);
                register_code(KC_4);
            } else {
                register_code(KC_PSCR);
            }
        } else {
            if (user_config.os_mode == OS_MAC) {
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
            if (user_config.os_mode == OS_MAC) {
                register_code(KC_LGUI);
            } else {
                register_code(KC_LCTL);
            }
            register_code(KC_GRV);
        } else {
            unregister_code(KC_GRV);
            if (user_config.os_mode == OS_MAC) {
                unregister_code(KC_LGUI);
            } else {
                unregister_code(KC_LCTL);
            }
        }
        return false;

    case CU_WLFT:
        // Linux/Win: Super+Left | Mac: Alt+Ctrl+Left
        if (record->event.pressed) {
            if (user_config.os_mode == OS_MAC) {
                register_code(KC_LCTL);
                register_code(KC_LALT);
            } else {
                register_code(KC_LGUI);
            }
            register_code(KC_LEFT);
        } else {
            unregister_code(KC_LEFT);
            if (user_config.os_mode == OS_MAC) {
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
            if (user_config.os_mode == OS_MAC) {
                register_code(KC_LCTL);
                register_code(KC_LALT);
            } else {
                register_code(KC_LGUI);
            }
            register_code(KC_RGHT);
        } else {
            unregister_code(KC_RGHT);
            if (user_config.os_mode == OS_MAC) {
                unregister_code(KC_LALT);
                unregister_code(KC_LCTL);
            } else {
                unregister_code(KC_LGUI);
            }
        }
        return false;

    case CU_WUP:
        // Linux/Win: Super+Up | Mac: Alt+Ctrl+Up
        if (record->event.pressed) {
            if (user_config.os_mode == OS_MAC) {
                register_code(KC_LCTL);
                register_code(KC_LALT);
            } else {
                register_code(KC_LGUI);
            }
            register_code(KC_UP);
        } else {
            unregister_code(KC_UP);
            if (user_config.os_mode == OS_MAC) {
                unregister_code(KC_LALT);
                unregister_code(KC_LCTL);
            } else {
                unregister_code(KC_LGUI);
            }
        }
        return false;

    case CU_LOCK:
        // Linux/Win: Super+L | Mac: Cmd+Ctrl+Q
        if (record->event.pressed) {
            if (user_config.os_mode == OS_MAC) {
                register_code(KC_LGUI);
                register_code(KC_LCTL);
                register_code(KC_Q);
            } else {
                register_code(KC_LGUI);
                register_code(KC_L);
            }
        } else {
            if (user_config.os_mode == OS_MAC) {
                unregister_code(KC_Q);
                unregister_code(KC_LCTL);
                unregister_code(KC_LGUI);
            } else {
                unregister_code(KC_L);
                unregister_code(KC_LGUI);
            }
        }
        return false;

    case CU_TH_BC: if (record->event.pressed) set_theme(THEME_BEACH);     return false;
    case CU_TH_OC: if (record->event.pressed) set_theme(THEME_OCEAN);     return false;
    case CU_TH_AU: if (record->event.pressed) set_theme(THEME_AURORA);    return false;
    case CU_TH_SF: if (record->event.pressed) set_theme(THEME_STARFIELD); return false;
    case CU_TH_CP: if (record->event.pressed) set_theme(THEME_CYBERPUNK); return false;
    case CU_TH_FO: if (record->event.pressed) set_theme(THEME_FOREST);    return false;
    case CU_TH_PT: if (record->event.pressed) set_theme(THEME_PARTY);     return false;
    case CU_TH_SP: if (record->event.pressed) set_theme(THEME_SPLASH);    return false;
    case CU_TH_OF: if (record->event.pressed) set_theme(THEME_OFF);       return false;
    case CU_TH_NX: if (record->event.pressed) cycle_theme();              return false;
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
// │  `/~  │  1  │  2  │  3  │  4  │  5  │  [  │   │  ]   │  6  │  7  │  8  │  9  │  0  │  -/_  │
// ├───────┼─────┼─────┼─────┼─────┼─────┼─────┤   ├─────┼─────┼─────┼─────┼─────┼─────┼───────┤
// │  Tab  │  Q  │  W  │  E  │  R  │  T  │Copy │   │Vol+ │  Y  │  U  │  I  │  O  │  P  │   \   │
// ├───────┼─────┼─────┼─────┼─────┼─────┼─────┤   ├─────┼─────┼─────┼─────┼─────┼─────┼───────┤
// │ Nav   │  A  │  S  │  D  │  F  │  G  │Paste│   │Vol- │  H  │  J  │  K  │  L  │  ;  │   '   │
// ├───────┼─────┼─────┼─────┼─────┼─────┘─────┘   └─────└─────┼─────┼─────┼─────┼─────┼───────┤
// │ Shift │  Z  │  X  │  C  │  V  │  B  │                     │  N  │  M  │  ,  │  .  │  /  │  =/+  │
// ├───────┼─────┼─────┼─────┼─────┘─────┘                     └─────└─────┼─────┼─────┼─────┼───────┤
// │ RCtrl │RAlt │Super│ F5  │ F12 │      Esc                    Nav       │ Alt │  ←  │  ↓  │  ↑  │   →   │
// └───────┴─────┴─────┴─────┴─────┘                                       └─────┴─────┴─────┴─────┴───────┘
//                             ┌─────┬─────┬─────┐ ┌─────┬─────┬─────┐
//                             │Ctrl │ Alt │Enter│ │Bksp │ Del │Space│
//                             └─────┴─────┴─────┘ └─────┴─────┴─────┘
[_BASE] = LAYOUT(
    KC_GRV,  KC_1,    KC_2,    KC_3,    KC_4,    KC_5,    KC_LBRC,      KC_RBRC, KC_6,    KC_7,    KC_8,    KC_9,    KC_0,    KC_MINS,
    KC_TAB,  KC_Q,    KC_W,    KC_E,    KC_R,    KC_T,    C(KC_C),      KC_VOLU, KC_Y,    KC_U,    KC_I,    KC_O,    KC_P,    KC_BSLS,
    MO(_NAV),KC_A,    KC_S,    KC_D,    KC_F,    KC_G,    C(KC_V),      KC_VOLD, KC_H,    KC_J,    KC_K,    KC_L,    KC_SCLN, KC_QUOT,
    KC_LSFT, KC_Z,    KC_X,    KC_C,    KC_V,    KC_B,                           KC_N,    KC_M,    KC_COMM, KC_DOT,  KC_SLSH, KC_EQL,
    KC_RCTL, KC_RALT, KC_RGUI, KC_F5,   KC_F12,           KC_ESC,     MO(_NAV),          KC_RALT, KC_LEFT, KC_DOWN, KC_UP,   KC_RGHT,
                                         KC_LCTL, KC_LALT, KC_ENT,      KC_BSPC, KC_DEL,  KC_SPC
),

// Nav/Function Layer
// Theme row (Q..P positions): Beach, Ocean, Aurora, Star, Cyber |
//                             Forest, Party, Splash, Next, Off
// ┌───────┬─────┬─────┬─────┬─────┬─────┬─────┐   ┌─────┬─────┬─────┬─────┬─────┬─────┬───────┐
// │ Lock  │ F1  │ F2  │ F3  │ F4  │ F5  │  =  │   │  -  │ F6  │ F7  │ F8  │ F9  │ F10 │  Del  │
// ├───────┼─────┼─────┼─────┼─────┼─────┼─────┤   ├─────┼─────┼─────┼─────┼─────┼─────┼───────┤
// │       │Beach│Ocean│Auror│Star │Cyber│  [  │   │  ]  │Frst │Prty │Splsh│Next │Off  │       │
// ├───────┼─────┼─────┼─────┼─────┼─────┼─────┤   ├─────┼─────┼─────┼─────┼─────┼─────┼───────┤
// │       │     │Snap │     │     │     │  `  │   │Enter│  ←  │  ↓  │  ↑  │  →  │     │       │
// ├───────┼─────┼─────┼─────┼─────┼─────┘─────┘   └─────└─────┼─────┼─────┼─────┼─────┼───────┤
// │       │     │     │     │     │     │                     │     │     │     │     │     │       │
// ├───────┼─────┼─────┼─────┼─────┘─────┘                     └─────└─────┼─────┼─────┼─────┼───────┤
// │ WinL  │WinUp│WinR │Home │ End │                                      │     │PgDn │PgUp │     │       │
// └───────┴─────┴─────┴─────┴─────┘                                       └─────┴─────┴─────┴─────┴───────┘
//                             ┌─────┬─────┬─────┐ ┌─────┬─────┬─────┐
//                             │     │     │     │ │Term │     │     │
//                             └─────┴─────┴─────┘ └─────┴─────┴─────┘
[_NAV] = LAYOUT(
    CU_LOCK, KC_F1,   KC_F2,   KC_F3,   KC_F4,   KC_F5,   KC_EQL,       KC_MINS, KC_F6,   KC_F7,   KC_F8,   KC_F9,   KC_F10,  KC_DEL,
    _______, CU_TH_BC,CU_TH_OC,CU_TH_AU,CU_TH_SF,CU_TH_CP,KC_LBRC,      KC_RBRC, CU_TH_FO,CU_TH_PT,CU_TH_SP,CU_TH_NX,CU_TH_OF,_______,
    _______, _______, CU_SNAP, _______, _______, _______, KC_GRV,       KC_ENT,  KC_LEFT, KC_DOWN, KC_UP,   KC_RGHT, _______, _______,
    _______, _______, _______, _______, _______, _______,                        _______, _______, _______, _______, _______, _______,
    CU_WLFT, CU_WUP,  CU_WRGT, KC_HOME, KC_END,           _______,     _______,          _______, KC_PGDN, KC_PGUP, _______, _______,
                                         _______, _______, _______,      CU_TERM, _______, _______
),

};
// clang-format on
