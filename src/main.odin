package PushChase

import "core:strings"
import "core:fmt"
import RL "vendor:raylib" 

main :: proc() {
    using RL

	RL.SetRandomSeed(42)
	
	name := strings.clone_to_cstring(project_name)
	xxx : i32 = i32(SCREEN.x)
	yyy : i32 = i32(SCREEN.y)
	InitWindow(xxx, yyy, name)

    InitAudioDevice()
    //bg_music := LoadMusicStream("../assets/bg_music.wav")
    //bg_music.looping = true

	setup_window()

	// initialize_engine()
	setup_game()

	is_running: bool = true
	for is_running && !WindowShouldClose()
    {
        //UpdateMusicStream(bg_music)

        //PlayMusicStream(bg_music)

		{// UPDATE
			// update_engine()
			update_screens()
		}

		{// RENDER
			// render_engine()
			render_screens()
		}
	}

	clear_and_shutdown()

	CloseWindow()
}

setup_window :: proc(){
    using RL
	SetTargetFPS(60)

	icon: Image = LoadImage("../assets/icons/window_icon.png")

	ImageFormat(&icon, PixelFormat.UNCOMPRESSED_R8G8B8A8)

	SetWindowIcon(icon)

	UnloadImage(icon)
}

clear_and_shutdown :: proc()
{
	unload_all_textures()
}
