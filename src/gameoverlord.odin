package PushChase

import rl "vendor:raylib"

load_all_textures :: proc()
{
    using rl

    tex_spritesheet = rl.LoadTexture(PATH_SPRITESHEET)
    tex_background = LoadTexture(PATH_BACKGROUND)
}

startup_game_overlord :: proc() 
{
    current_screen      = .MAIN_MENU
    game_paused         = false
}

setup_background :: proc()
{
    using rl

    bg.active = true
    bg.rec = Rectangle{ 0, 0, 720, 720}
    bg.spr.src = Rectangle{0,0,1024,1024}
    bg.spr.color = C_BACKGROUND
}

setup_game :: proc()
{
    load_all_textures()

    startup_game_overlord()

    setup_background()
}

update_screens :: proc()
{
    switch current_screen {
        case .MAIN_MENU:
            update_main_menu()
        case .GAMEPLAY:
            update_gameplay()
        case .GAME_OVER:
    }
}

render_screens :: proc()
{
    rl.BeginDrawing()
    rl.ClearBackground(C_BACKGROUND)

    {// RENDER
        switch current_screen {
            case .MAIN_MENU:
                render_main_menu()
            case .GAMEPLAY:
                render_gameplay()
            case .GAME_OVER:
        }
        // background.render()
        // cursor.render()
    }
    rl.DrawFPS(0, 0)

    rl.EndDrawing()
}


reset_game :: proc()
{
    game_paused = false;
}

unload_all_textures :: proc() {
	using rl

	UnloadTexture(tex_spritesheet)
    UnloadTexture(tex_background)
}
