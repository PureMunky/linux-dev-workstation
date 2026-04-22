#pragma once

// Tapping term: how long a key must be held to count as "held" vs "tapped"
#define TAPPING_TERM 200

// If a mod-tap key and another key are pressed within TAPPING_TERM,
// treat the mod-tap as held (allows faster typing without accidental mods)
#define PERMISSIVE_HOLD

// Combo term: window for pressing combo keys simultaneously
#define COMBO_TERM 50

// RGB matrix effects used by the theme system (see keymap.c)
#define ENABLE_RGB_MATRIX_RAINBOW_MOVING_CHEVRON
#define ENABLE_RGB_MATRIX_BREATHING
#define ENABLE_RGB_MATRIX_DIGITAL_RAIN
#define ENABLE_RGB_MATRIX_CYCLE_PINWHEEL
#define ENABLE_RGB_MATRIX_PIXEL_FLOW
#define ENABLE_RGB_MATRIX_TYPING_HEATMAP
#define ENABLE_RGB_MATRIX_SOLID_COLOR
