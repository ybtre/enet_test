package fantasy_chess 

import rl "vendor:raylib"

bg : Background
bg_tex : rl.Texture2D

setup_background :: proc(){
    // bg_tex = rl.LoadTexture("../assets/paper_background.png")

    /*
    bg.spr.src = { 0, 0, SCREEN.x, SCREEN.y}
    bg.spr.dest =  { 0, 0, bg.spr.src.width , bg.spr.src.height}
    bg.spr.center = { 0, 0 }
    */
}

render_background :: proc(){
    //rl.DrawTexturePro(bg_tex, bg.spr.src, bg.spr.dest, bg.spr.center, 0, rl.WHITE)
}

unload_background :: proc() {
    rl.UnloadTexture(bg_tex)
}
