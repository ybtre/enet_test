package PushChase

import rl "vendor:raylib"

render_background :: proc()
{
   rl.DrawTexturePro(tex_background, bg.spr.src, bg.rec, bg.spr.center, 0, C_BACKGROUND) 
}
