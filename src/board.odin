package fantasy_chess

import rl "vendor:raylib"
import "base"
import "core:strconv"
import "core:strings"

board : Board
selected_tile : ^Tile
TILE_SCALE_FACTOR :f32: 2
board_letters_lookup : [8]string = { "A", "B", "C", "D", "E", "F", "G", "H" }


setup_board :: proc(){
	using rl

	for x in 0..<8 {
		for y in 0..<8 
		{
			board.tiles[x][y] = setup_tile(x, y)
		}
	}
}

setup_tile :: proc(X, Y: int) -> Tile {
    t : Tile
    return t
}

update_board :: proc() 
{
	handle_selected_tile_piece()
}

handle_selected_tile_piece :: proc()
{	
	using strconv 
	
	if selected_tile == nil 
	{
		return
	}

	if selected_tile.piece_on_tile == nil
	{
		return
	}
	
	switch selected_tile.piece_on_tile.type
	{	
		//@Incomplete: need to make separate []^Board.Tiles for each tile state
		case .PAWN:
			if selected_tile.piece_on_tile.e_color == .WHITE
			{
				tile_coords := strings.split(selected_tile.boads_coords, "-")
				x := atoi(tile_coords[0])
				y := atoi(tile_coords[1]) + 1
				t := &board.tiles[x-1][y-1]
				t.state = .moves
			}
			else if selected_tile.piece_on_tile.e_color == .BLACK
			{
				tile_coords := strings.split(selected_tile.boads_coords, "-")
				x := atoi(tile_coords[0])
				y := atoi(tile_coords[1]) - 2
				t := &board.tiles[x-1][y-1]
				t.state = .moves
			}
		break

		case .ROOK:
		break

		case .KNIGHT:
		break

		case .BISHOP:
		break

		case .QUEEN:
		break

		case .KING:
		break
	}
	
}

render_board :: proc() {
	using rl

	// tile.pos.x += 1
	// on_tile_pos_update(&tile)
			
	// DrawLine(i32(SCREEN.x) /2, 0, i32(SCREEN.x) /2, i32(SCREEN.y), RED)
	// DrawLine(0, i32(SCREEN.y) /2, i32(SCREEN.x), i32(SCREEN.y) /2, RED)

	render_board_tiles()
}

render_board_tiles :: proc() 
{
	using rl
}

draw_board_tile :: proc(TILE: ^Tile)
{
	rl.DrawTexturePro(
		TEX_SPRITESHEET, 
		TILE.spr.src, 
		TILE.spr.dest, 
		TILE.spr.center, 
		// f32(GetTime()) * 90,
		0, 
		rl.WHITE)
}

on_tile_pos_update :: proc(TILE: ^Tile) {
	update_tile_sprite_dest(TILE)
	update_tile_hitbox_pos(TILE)
}

update_tile_hitbox_pos :: proc(TILE: ^Tile) {
    TILE.hitbox = { TILE.pos.x - TILE.spr.src.width * TILE.spr.SCALE_FACTOR / 2, TILE.pos.y - TILE.spr.src.height * TILE.spr.SCALE_FACTOR / 2, TILE.spr.dest.width, TILE.spr.dest.height }
}

update_tile_sprite_dest :: proc(TILE: ^Tile) {
    TILE.spr.dest = { TILE.pos.x, TILE.pos.y, TILE.spr.dest.width, TILE.spr.dest.height }
}
