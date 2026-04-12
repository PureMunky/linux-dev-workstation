#pragma once

// Tapping term: how long a key must be held to count as "held" vs "tapped"
#define TAPPING_TERM 200

// If a mod-tap key and another key are pressed within TAPPING_TERM,
// treat the mod-tap as held (allows faster typing without accidental mods)
#define PERMISSIVE_HOLD

// Combo term: window for pressing combo keys simultaneously
#define COMBO_TERM 50
