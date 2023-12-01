package fantasy_chess


import rl "vendor:raylib"

update_main_menu :: proc() {
    if rl.IsKeyPressed(rl.KeyboardKey.SPACE)
    {
        current_screen = .GAMEPLAY
    }
}

render_main_menu :: proc(){
    using rl

    // render_background()

    DrawText("Sofia Game Jam", i32(SCREEN.x / 2 - 175), i32(SCREEN.y / 2 - 60), 60, C_TEXT)
    // DrawText("PRESS SPACE TO PLAY", i32(SCREEN.x / 2 - 250), i32(SCREEN.y / 2), 40, C_TEXT)
}
