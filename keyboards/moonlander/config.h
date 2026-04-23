#pragma once

// Tapping term: how long a key must be held to count as "held" vs "tapped"
#define TAPPING_TERM 200

// If a mod-tap key and another key are pressed within TAPPING_TERM,
// treat the mod-tap as held (allows faster typing without accidental mods)
#define PERMISSIVE_HOLD

// Combo term: window for pressing combo keys simultaneously
#define COMBO_TERM 50

// Required so reactive effects (MULTICROSS, MULTISPLASH) compile in
#define RGB_MATRIX_KEYPRESSES

// RGB matrix effects used by the theme system (see keymap.c)
#define ENABLE_RGB_MATRIX_BREATHING                  // Ocean, Forest
#define ENABLE_RGB_MATRIX_CYCLE_PINWHEEL             // Party
#define ENABLE_RGB_MATRIX_BAND_VAL                   // Beach
#define ENABLE_RGB_MATRIX_HUE_BREATHING              // Aurora
#define ENABLE_RGB_MATRIX_STARLIGHT_SMOOTH           // Starfield
#define ENABLE_RGB_MATRIX_SOLID_REACTIVE_MULTICROSS  // Cyberpunk
#define ENABLE_RGB_MATRIX_SOLID_MULTISPLASH          // Splash
