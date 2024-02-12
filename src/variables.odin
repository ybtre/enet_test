package PushChase

import RL "vendor:raylib"

// --------- STRUCTS
bg      : Background

// --------- TEXTURES
tex_spritesheet 	:  RL.Texture2D  
tex_background      :  RL.Texture2D


// --------- BOOLS
game_paused := false

// --------- TIMERS
pause_blink_counter     :   i64     = 0
gameplay_time_total     :   f64     = 0.0
gameplay_time_current   :   f64     = 0.0
