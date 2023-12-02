package fantasy_chess 

import "core:fmt"
import "core:strings"
import rl "vendor:raylib"

FILENAME :: `level.txt`
FILE :: string(#load(FILENAME))

entity_pool     : [256]Entity
entity_count    : int
spawn_timer     : f32 

init_gameplay :: proc() {
    using rl

    {// Create Player
        p : Entity
        
        p.active = true
        p.type = .ENT_PLAYER
        p.rec = Rectangle{ f32(3 * 16 * SCALE), f32(8 * 16 * SCALE), f32(16 * SCALE), f32(16 * SCALE) }
        
        p.spr.color = C_PLAYER
        p.spr.src = Rectangle{ 64, 0, 16, 16 }

        entity_pool[entity_count] = p
        entity_count += 1
    }

    read_level();
}

read_level :: proc() {
    using fmt

    file_lines := strings.split_lines(FILE)
    defer delete(file_lines)
    
    x, y : int
    for line in file_lines 
    {
        //printf("LINE: %s\n", line)
         
        for c in line 
        {
            switch c {
                case '0':
                {
                }
                case '1':
                {
                    create_wall_at(x, y);
                }
            }

            x += 1
        }
        
        x = 0
        y += 1
    }
}

create_wall_at :: proc(X, Y : int)
{
    using rl
    using fmt

    printf("Creating wall at: %i, %i\n", X, Y)

    w : Entity

    w.active = true
    w.type = .ENT_WALL

    w.spr.src = Rectangle{ 0, 64, 16, 16 }
    w.spr.color = C_TILE

    w.rec = Rectangle{ f32(X * 16 * SCALE), f32(Y * 16 * SCALE), f32(16 * SCALE), f32(16 * SCALE) }


    entity_pool[entity_count] = w
    entity_count += 1

}

update_gameplay :: proc() {
    using rl

    spawn_timer += rl.GetFrameTime()

    if rl.IsKeyPressed(rl.KeyboardKey.P){
        is_paused = !is_paused
    }

    if !is_paused
    {   
        update_check_mouse_collision()
        //update_board()
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
    //render_board()
    
    { //tiles
        {//grid
            for x := 0; x < 11; x += 1 {
                for y := 0; y < 11; y += 1
                {
                    DrawRectangleLinesEx(Rectangle{f32((x * 16 * SCALE) + 10), f32((y * 16 * SCALE) + 10), 16 * SCALE, 16 * SCALE}, 1, DARKGRAY) 
                }
            }
        }

        {
           render_ent_of_type(.ENT_WALL, false) 
           render_ent_of_type(.ENT_PLAYER, false) 
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

render_ent_of_type :: proc(TYPE : Entity_Type, DEBUG : bool) 
{
    using rl

    e : Entity

    for i := 0; i < entity_count; i+= 1
    {
        e = entity_pool[i]

        if e.active
        {
            e.rec.x += 10
            e.rec.y += 10

            DrawTexturePro(TEX_SPRITESHEET, e.spr.src, e.rec, Vector2{0,0}, 0, e.spr.color)
            
            if DEBUG
            {
                DrawRectangleLinesEx(e.rec, 2, RED)
            }
        }
    }

}
