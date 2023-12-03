package fantasy_chess


import rl "vendor:raylib"
import "core:fmt"

small := rl.Rectangle{f32((SCREEN.x /2 - 220)), f32((SCREEN.y /2 - 30)), 100, 40}
medium := rl.Rectangle{f32((SCREEN.x /2 - 40)), f32((SCREEN.y /2 - 30)), 100, 40}
large := rl.Rectangle{f32((SCREEN.x /2 + 140)), f32((SCREEN.y /2 - 30)), 100, 40}

update_main_menu :: proc() {
    using rl
        // 0 - SMALL 1 - MEDIUM 2 - LARGE

    if CheckCollisionRecs(small, rl.Rectangle{f32(GetMouseX()), f32(GetMouseY()), 2, 2})
    {
        if IsMouseButtonPressed(MouseButton.LEFT)
        {
            level_to_load = 0
            init_gameplay()
            current_screen = .GAMEPLAY
        }
    }
    if CheckCollisionRecs(medium, rl.Rectangle{f32(GetMouseX()), f32(GetMouseY()), 2, 2})
    {
        if IsMouseButtonPressed(MouseButton.LEFT)
        {
            level_to_load = 1
            init_gameplay()
            current_screen = .GAMEPLAY
        }
    }
    if CheckCollisionRecs(large, rl.Rectangle{f32(GetMouseX()), f32(GetMouseY()), 2, 2})
    {
        if IsMouseButtonPressed(MouseButton.LEFT)
        {
            level_to_load = 2
            init_gameplay()
            current_screen = .GAMEPLAY
        }
    }
}

render_main_menu :: proc(){
    using rl

    render_background()

    DrawText("Sofia Game Jam", i32(SCREEN.x / 2 - 220), i32(SCREEN.y / 2 - 250), 60, C_TEXT)
    DrawText("  TAKE CONTROL OF AN AI", i32(SCREEN.x / 2 - 200), i32(SCREEN.y / 2 - 150), 30, RAYWHITE )
    DrawText("AND DEFEAT THE ROGUE AI", i32(SCREEN.x / 2 - 200), i32(SCREEN.y / 2 - 100), 30, RAYWHITE)
    // DrawText("PRESS SPACE TO PLAY", i32(SCREEN.x / 2 - 250), i32(SCREEN.y / 2), 40, C_TEXT)

    DrawText(TextFormat("SMALL"), i32(small.x + 20), i32(small.y + 10), 20, RED)
    DrawRectangleLinesEx(small, 5, DARKGRAY) 
    DrawText(TextFormat("MEDIUM"), i32(medium.x + 10), i32(medium.y + 10), 20, RED)
    DrawRectangleLinesEx(medium, 5, DARKGRAY) 
    DrawText(TextFormat("LARGE"), i32(large.x + 20), i32(large.y + 10), 20, RED)
    DrawRectangleLinesEx(large, 5, DARKGRAY) 


    src := Rectangle{48, 96, 80, 48}
    dest := Rectangle{SCREEN.x/2 - 150, SCREEN.y /2 + 50, src.width * 4, src.height * 4}

    DrawTexturePro(TEX_SPRITESHEET, src, dest, Vector2{0,0}, 0, WHITE)
}
