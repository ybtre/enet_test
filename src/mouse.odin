package fantasy_chess

import rl "vendor:raylib"
import "base"

update_check_mouse_collision :: proc() 
{
	using rl
	
	for x in 0..<8 {
		for y in 0..<8
		{	
			t := &board.tiles[x][y]
			
			if CheckCollisionPointRec(GetMousePosition(), t.hitbox)
			{
				if t.state != .selected 
				{ 
					t.state = .highlighted
				}
				DrawText(TextFormat("HOVERING TILE: %i, %i", x, y), 20, 70, 30, GRAY)
				DrawText(TextFormat("TILE ID: %s", t.id), 20, 100, 30, GRAY)
				DrawText(TextFormat("TILE COORDS: %s", t.boads_coords), 20, 130, 30, GRAY)
				DrawText(TextFormat("PIECE ID: %s", t.piece_on_tile.id), 20, 160, 30, GRAY)

				if IsMouseButtonPressed(MouseButton.LEFT)
				{
					if selected_tile != nil
					{ 
						selected_tile.state = .idle 
					}
					t.state = .selected
					selected_tile = t
				}
			}
			else 
			{	
				if t.state == .highlighted
				{
					t.state = .idle
				}
			}	
		}
	}
}
