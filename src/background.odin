package fantasy_chess 

import rl "vendor:raylib"

bg : Background
bg_tex : rl.Texture2D

setup_background :: proc(){
    using rl
    bg_tex = LoadTexture("../assets/background.png")

    bg.active = true
    bg.rec = Rectangle{ 0, 0, 720, 720}
    bg.spr.src = Rectangle{0,0,1024,1024}
    bg.spr.color = C_BACKGROUND
}

render_background :: proc(){
    rl.DrawTexturePro(bg_tex, bg.spr.src, bg.rec, bg.spr.center, 0, C_BACKGROUND)
}

unload_background :: proc() {
    rl.UnloadTexture(bg_tex)
}
