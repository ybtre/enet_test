package fantasy_chess

import rl "vendor:raylib"

TEX_SPRITESHEET 	: rl.Texture2D

SRC_TILE_WHITE  				:: rl.Rectangle{ 35, 100, 34, 34 }

SRC_WHITE_PAWN		:: rl.Rectangle{ 0, 48, 32, 48 }

load_all_textures :: proc() {
	using rl

	TEX_SPRITESHEET = rl.LoadTexture("../assets/spritesheet.png")
}

setup_sprite_sources :: proc() {
}

unload_all_textures :: proc() {
	using rl

	UnloadTexture(TEX_SPRITESHEET)
}
