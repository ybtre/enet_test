package fantasy_chess 

import rl "vendor:raylib"
// import "core:fmt"

spawn_timer : f32 = 0
beetle_spawn_timer : f32 = 10

update_gameplay :: proc() {
    using rl

    spawn_timer += rl.GetFrameTime()

    if rl.IsKeyPressed(rl.KeyboardKey.P){
        is_paused = !is_paused
    }

    if !is_paused
    {   
        update_check_mouse_collision()
        update_board()
    }
    else 
    {
        pause_blink_counter += 1
    }
}

render_gameplay :: proc() {
    using rl
 //void DrawRectangleLines(int posX, int posY, int width, int height, Color color);   
    // render_background()
    render_board()
    
    for x := 0; x < 11; x += 1 {
        for y := 0; y < 11; y += 1
        {
           DrawRectangleLinesEx(Rectangle{f32((x * 16 * SCALE) + 10), f32((y * 16 * SCALE) + 10), 16 * SCALE, 16 * SCALE}, 2, C_TILE) 
        }
    }
    if is_paused && ((pause_blink_counter / 30) % 2 == 0)
    {
        DrawText("GAME PAUSED", i32(SCREEN.x / 2 - 290), i32(SCREEN.y / 2 - 50), 80, rl.RED)
    } 

    {// UI
    //    render_buttons()
        DrawText(TextFormat("Mouse: %i, %i", GetMouseX(), GetMouseY()), 20, 20, 20, GRAY)
    }
}
