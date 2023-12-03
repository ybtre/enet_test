package fantasy_chess 

import "core:fmt"
import "core:strings"
import "core:math"
import rl "vendor:raylib"

SMALL :: `level_small.txt`
MEDIUM :: `level_medium.txt`
LARGE :: `level_large.txt`
FILE_SMALL :: string(#load(SMALL))
FILE_MEDIUM :: string(#load(MEDIUM))
FILE_LARGE :: string(#load(LARGE))

p_data          : Player_Data
p2_data         : Player_Data

entity_pool     : [512]Entity
entity_count    : int           = 2

spike_dt_pool   : [16]Spike_Data
spike_dt_count  : int     

ai_dt_pool      : [8]AI_Data
ai_dt_count     : int     

p1_score        : int
p2_score        : int

cam             : rl.Camera2D
cam_start_off   : rl.Vector2 
shaking         : bool
shake_timer     : f32
shake_duration  : f32
shake_intensity : f32
S_int           :: 1
M_int           :: 5
L_int           :: 20
S_dur           :: .1
M_dur           :: .2
L_dur           :: .3

init_gameplay :: proc() {
    using rl

    p1_score = 0
    p2_score = 0
    read_level_file();

    cam.target = Vector2{ SCREEN.x / 2, SCREEN.y / 2 }
    cam.offset = Vector2{ SCREEN.x / 2, SCREEN.y / 2 } 
    cam_start_off = cam.offset;
    cam.rotation = 0
    cam.zoom = 1

    shaking = false
    shake_timer = 0
    shake_duration = S_dur
    shake_intensity = S_int
}

create_player_two :: proc(X, Y : int) {
    using rl
    p : Entity
    
    p.active = true
    p.type = .ENT_PLAYER_TWO
    p.rec = Rectangle{ f32(X * 16 * SCALE), f32(Y * 16 * SCALE), f32(16 * SCALE), f32(16 * SCALE) }
    p.spawn_id = Vector2{f32(X), f32(Y)}
    p.id = 1
    p.rot = 180
    
    p.spr.color = C_PLAYER_TWO
    p.spr.src = Rectangle{ 64, 0, 16, 16 }

    entity_pool[1] = p
    
    p2_data.ent_id = p.id
    p2_data.speed    = 30
    p2_data.velocity = 0
    p2_data.move_dir = Vector2{0,0}
    p2_data.is_moving = false
}
create_player :: proc(X, Y : int) {
    using rl
    p : Entity
    
    p.active = true
    p.type = .ENT_PLAYER
    p.rec = Rectangle{ f32(X * 16 * SCALE), f32(Y * 16 * SCALE), f32(16 * SCALE), f32(16 * SCALE) }
    p.spawn_id = Vector2{f32(X), f32(Y)}
    p.id = 0
    
    p.spr.color = C_PLAYER
    p.spr.src = Rectangle{ 64, 0, 16, 16 }
    entity_pool[0] = p

    p_data.ent_id = p.id
    p_data.speed    = 30
    p_data.velocity = 0
    p_data.move_dir = Vector2{0,0}
    p_data.is_moving = false
}

read_level_file :: proc() {
    using fmt
   
    SCALE = 4
    file_lines := strings.split_lines(FILE_SMALL)
    defer delete(file_lines)

    entity_count = 2
    spike_dt_count = 0 
    
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
                    create_wall_at(x, y)
                }
                case '2':
                {
                    create_player(x, y)
                }
                case '3':
                {
                    create_spike_at_dir(x, y, 3)
                }
                case '4':
                {
                    create_spike_at_dir(x, y, 4)
                }
                case '5':
                {
                    create_spike_at_dir(x, y, 5)
                }
                case '6':
                {
                    create_spike_at_dir(x, y, 6)
                }
                case '7':
                {
                    create_enemy_at(x, y)
                }
                case '9':
                {
                    create_player_two(x, y)
                }
            }

            x += 1
        }
        
        x = 0
        y += 1
    }

    println("TOTAL ENTITIES: ", entity_count + ai_dt_count + spike_dt_count)
}

create_enemy_at :: proc(X, Y : int)
{
    using rl 
    using fmt 

    e : Entity

    println("CREATE ENEMY")
    e.active = true
    e.type = .ENT_AI
    e.id = int(GetRandomValue(2001, 2500))

    e.spr.src = Rectangle{ 64, 32, 16, 16 }
    e.spr.color = C_AI
    e.rot = 0
    e.rec = Rectangle{ f32(X * 16 * SCALE), f32(Y * 16 * SCALE), f32(16 * SCALE), f32(16 * SCALE) }

    entity_pool[entity_count] = e
    entity_count += 1
    
    ed : AI_Data
    ed.ent_id = e.id
    ed.active = e.active

    ed.move_timer = 0
    ed.move_delay = 1

    ai_dt_pool[ai_dt_count] = ed
    ai_dt_count += 1
}

create_spike_at_dir :: proc (X, Y, DIR : int)
{
    using rl

    s : Entity

    s.active = true
    s.type   = .ENT_SPIKE
    s.id = int(GetRandomValue(1001, 2000))
    //fmt.printf("ID %i\n", s.id)

    s.spr.src = Rectangle{ f32(80 + (16 * (DIR - 3))), 16, 16, 16}
    s.spr.color = C_SPIKE 
    s.rot = 0
    s.rec = Rectangle{ f32(X * 16 * SCALE), f32(Y * 16 * SCALE), f32(16 * SCALE), f32(16 * SCALE) }


    entity_pool[entity_count] = s
    entity_count += 1

    sd : Spike_Data

    sd.ent_id = s.id

    sd.active = s.active
    sd.trigger = false
    sd.can_kill = false

    sd.trigger_timer = 0
    sd.trigger_delay = .3
    sd.trigger_dur   = 1

    spike_dt_pool[spike_dt_count] = sd
    spike_dt_count += 1
}

create_wall_at :: proc(X, Y : int)
{
    using rl
    using fmt
    
    debug_wall_creation :: false
    if debug_wall_creation 
    {
        printf("Creating wall at: %i, %i\n", X, Y)
    }

    w : Entity

    w.active = true
    w.type = .ENT_WALL
    w.id = int(GetRandomValue(100, 1000))
    //printf("ID %i\n", w.id)

    w.spr.src = Rectangle{ 0, 64, 16, 16 }
    w.spr.color = C_TILE
    
    w.rec = Rectangle{ f32(X * 16 * SCALE), f32(Y * 16 * SCALE), f32(16 * SCALE), f32(16 * SCALE) }

    entity_pool[entity_count] = w
    entity_count += 1
}

update_gameplay :: proc() {
    using rl

    if rl.IsKeyPressed(rl.KeyboardKey.P){
        is_paused = !is_paused
    }

    update_entities()

    if shaking
    {
        shake_timer += GetFrameTime();
    }
    if shaking && shake_timer <= shake_duration
    {
        shake_screen(&cam, shake_intensity);
    }
    else {
        shaking = false;
        shake_timer = 0;
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

update_entities :: proc() {
    using rl
    using fmt

        if IsKeyPressed(KeyboardKey.LEFT) && !p_data.is_moving
        {
            p_data.move_dir = Vector2{-1, 0}
            p_data.is_moving = true
        }

        if IsKeyPressed(KeyboardKey.RIGHT) && !p_data.is_moving
        {
            p_data.move_dir = Vector2{+1, 0}
            p_data.is_moving = true

        }

        if IsKeyPressed(KeyboardKey.UP) && !p_data.is_moving
        {
            p_data.move_dir = Vector2{0, -1}
            p_data.is_moving = true

        }

        if IsKeyPressed(KeyboardKey.DOWN) && !p_data.is_moving
        {
            p_data.move_dir = Vector2{0, +1}
            p_data.is_moving = true

        }

        if IsKeyPressed(KeyboardKey.A) && !p2_data.is_moving
        {
            p2_data.move_dir = Vector2{-1, 0}
            p2_data.is_moving = true
        }

        if IsKeyPressed(KeyboardKey.D) && !p2_data.is_moving
        {
            p2_data.move_dir = Vector2{+1, 0}
            p2_data.is_moving = true
        }

        if IsKeyPressed(KeyboardKey.W) && !p2_data.is_moving
        {
            p2_data.move_dir = Vector2{0, -1}
            p2_data.is_moving = true
        }

        if IsKeyPressed(KeyboardKey.S) && !p2_data.is_moving
        {
            p2_data.move_dir = Vector2{0, +1}
            p2_data.is_moving = true
        }


    //for sd in spike_dt_pool
    for i := 0; i < spike_dt_count; i+=1
    {
        if spike_dt_pool[i].trigger 
        {
            spike_dt_pool[i].trigger_timer += GetFrameTime()
        }
    }

    for i := 0; i < spike_dt_count; i+=1
    {
        timer := spike_dt_pool[i].trigger_timer
        delay := spike_dt_pool[i].trigger_delay
        dur   := spike_dt_pool[i].trigger_dur
        if timer > delay && timer < (delay + dur)
        {
            for j := 0; j < entity_count; j+=1
            {
                if entity_pool[j].id == spike_dt_pool[i].ent_id
                {
                    entity_pool[j].spr.src.y = 0
                    spike_dt_pool[i].can_kill = true
                }
            }
        }
        else if timer > (delay + dur)
        {
            spike_dt_pool[i].trigger_timer = 0
            spike_dt_pool[i].trigger = false
            spike_dt_pool[i].can_kill = false
            for j := 0; j < entity_count; j+=1
            {
                if entity_pool[j].id == spike_dt_pool[i].ent_id
                {
                    entity_pool[j].spr.src.y = 16
                }
            }
        }
    }
    
    p1 := &entity_pool[0]
    p2 := &entity_pool[1]
    if p1.active && p2.active
    {
        if CheckCollisionRecs(p1.rec, p2.rec)
        {
            //println(p1.rec.y, p2.rec.y)
            if p1.rec.x > p2.rec.x && p1.rec.y == p2.rec.y
            {// p1 right p2 left
                //println("RIGHT")
                if p_data.is_moving && p2_data.is_moving
                {
                    p_data.move_dir = Vector2{+1,0}
                    p2_data.move_dir = Vector2{-1,0}
                    shaking = true
                    shake_intensity = M_int
                    shake_duration = L_dur
                    //p1.rec.x = f32(p2.rec.x + (16 * f32(SCALE)))
                }

                if !p_data.is_moving && p2_data.is_moving
                {
                    p_data.move_dir = p2_data.move_dir
                    p2_data.move_dir = Vector2{-1,0}
                    shaking = true
                    shake_intensity = M_int
                    shake_duration = L_dur
                }

                if p_data.is_moving && !p2_data.is_moving
                {
                    p2_data.move_dir = p_data.move_dir
                    p_data.move_dir = Vector2{+1,0}
                    shaking = true
                    shake_intensity = M_int
                    shake_duration = L_dur
                }
            }
            if p1.rec.x < p2.rec.x && p1.rec.y == p2.rec.y
            {// p1 left p2 right
                if p_data.is_moving && p2_data.is_moving
                {
                    p_data.move_dir = Vector2{-1,0}
                    p2_data.move_dir = Vector2{+1,0}
                    shaking = true
                    shake_intensity = M_int
                    shake_duration = L_dur
                }
                if !p_data.is_moving && p2_data.is_moving
                {
                    p_data.move_dir = p2_data.move_dir
                    p2_data.move_dir = Vector2{+1,0}
                    shaking = true
                    shake_intensity = M_int
                    shake_duration = L_dur
                }

                if p_data.is_moving && !p2_data.is_moving
                {
                    p2_data.move_dir = p_data.move_dir
                    p_data.move_dir = Vector2{-1,0}
                    shaking = true
                    shake_intensity = M_int
                    shake_duration = L_dur
                }
            }
            if p1.rec.y > p2.rec.y
            {// p1 bot p2 top
                if p_data.is_moving && p2_data.is_moving
                {
                    p_data.move_dir = Vector2{0,+1}
                    p2_data.move_dir = Vector2{0,-1}
                    shaking = true
                    shake_intensity = M_int
                    shake_duration = L_dur
                }
                if !p_data.is_moving && p2_data.is_moving
                {
                    p_data.move_dir = p2_data.move_dir
                    p2_data.move_dir = Vector2{0,-1}
                    shaking = true
                    shake_intensity = M_int
                    shake_duration = L_dur
                }

                if p_data.is_moving && !p2_data.is_moving
                {
                    p2_data.move_dir = p_data.move_dir
                    p_data.move_dir = Vector2{0,+1}
                    shaking = true
                    shake_intensity = M_int
                    shake_duration = L_dur
                }
            }
            if p1.rec.y < p2.rec.y
            {// p1 top p2 bot
                if p_data.is_moving && p2_data.is_moving
                {
                    p_data.move_dir = Vector2{0,-1}
                    p2_data.move_dir = Vector2{0,+1}
                    shaking = true
                    shake_intensity = M_int
                    shake_duration = L_dur
                }
                if !p_data.is_moving && p2_data.is_moving
                {
                    p_data.move_dir = p2_data.move_dir
                    p2_data.move_dir = Vector2{0,+1}
                    shaking = true
                    shake_intensity = M_int
                    shake_duration = L_dur
                }

                if p_data.is_moving && !p2_data.is_moving
                {
                    p2_data.move_dir = p_data.move_dir
                    p_data.move_dir = Vector2{0,-1}
                    shaking = true
                    shake_intensity = M_int
                    shake_duration = L_dur
                }
            }
        }
    }
    
    entity_pool[0].rec.x += p_data.move_dir.x * p_data.speed
    entity_pool[0].rec.y += p_data.move_dir.y * p_data.speed
    entity_pool[1].rec.x += p2_data.move_dir.x * p2_data.speed
    entity_pool[1].rec.y += p2_data.move_dir.y * p2_data.speed

    for e in entity_pool
    {
        if e.type == .ENT_WALL
        {
            if e.active
            {
                if CheckCollisionRecs(entity_pool[0].rec, e.rec)
                {
                    p_data.is_moving = false

                    if entity_pool[0].rec.x > e.rec.x
                    {// player on right
                        entity_pool[0].rec.x = f32(e.rec.x + (16 * f32(SCALE)))
                        entity_pool[0].rot = 90;
                        shaking = true
                        shake_intensity = S_int
                        shake_duration = S_dur
                    }
                    if entity_pool[0].rec.x < e.rec.x
                    {// player on left
                        entity_pool[0].rec.x = f32(e.rec.x - (16 * f32(SCALE)))
                        entity_pool[0].rot = -90;
                        shaking = true
                        shake_intensity = S_int
                        shake_duration = S_dur
                    }
                    if entity_pool[0].rec.y > e.rec.y
                    {// player on bot
                        entity_pool[0].rec.y = f32(e.rec.y + (16 * f32(SCALE)))
                        entity_pool[0].rot = 180;
                        shaking = true
                        shake_intensity = S_int
                        shake_duration = S_dur
                    }
                    if entity_pool[0].rec.y < e.rec.y
                    {// player on top
                        entity_pool[0].rec.y = f32(e.rec.y - (16 * f32(SCALE)))
                        entity_pool[0].rot = 0;
                        shaking = true
                        shake_intensity = S_int
                        shake_duration = S_dur
                    }
                }
                if CheckCollisionRecs(entity_pool[1].rec, e.rec)
                {
                    p2_data.is_moving = false

                    if entity_pool[1].rec.x > e.rec.x
                    {// player on right
                        entity_pool[1].rec.x = f32(e.rec.x + (16 * f32(SCALE)))
                        entity_pool[1].rot = 90;
                        shaking = true
                        shake_intensity = S_int
                        shake_duration = S_dur
                    }
                    if entity_pool[1].rec.x < e.rec.x
                    {// player on left
                        entity_pool[1].rec.x = f32(e.rec.x - (16 * f32(SCALE)))
                        entity_pool[1].rot = -90;
                        shaking = true
                        shake_intensity = S_int
                        shake_duration = S_dur
                    }
                    if entity_pool[1].rec.y > e.rec.y
                    {// player on bot
                        entity_pool[1].rec.y = f32(e.rec.y + (16 * f32(SCALE)))
                        entity_pool[1].rot = 180;
                        shaking = true
                        shake_intensity = S_int
                        shake_duration = S_dur
                    }
                    if entity_pool[1].rec.y < e.rec.y
                    {// player on top
                        entity_pool[1].rec.y = f32(e.rec.y - (16 * f32(SCALE)))
                        entity_pool[1].rot = 0;
                        shaking = true
                        shake_intensity = S_int
                        shake_duration = S_dur
                    }
                }
            }
        }
        if e.type == .ENT_AI
        {
            if e.active
            {
                //DrawRectangleLinesEx(e.rec, 1, GREEN)
                //get AI data from current ent
                for i := 0; i < ai_dt_count; i+=1
                {
                    if ai_dt_pool[i].ent_id == e.id
                    {
                        ai_dt_pool[i].move_timer += GetFrameTime()

                        timer := ai_dt_pool[i].move_timer
                        delay := ai_dt_pool[i].move_delay

                        //move
                        if timer > delay 
                        {
                            ai_dt_pool[i].last_pos = Vector2{e.rec.x, e.rec.y}

                            can_move := false
                            
                            new_pos : Vector2

                            w := 0
                            while: for w < 15
                            {
                                w += 1

                                dir := GetRandomValue(0, 3)
                                switch dir 
                                {
                                    case 0:
                                        new_pos = Vector2{e.rec.x, (e.rec.y) - e.rec.height}
                                    case 1:
                                        new_pos = Vector2{e.rec.x - e.rec.width, e.rec.y}
                                    case 2:
                                        new_pos = Vector2{e.rec.x + e.rec.width, e.rec.y}
                                    case 3:
                                        new_pos = Vector2{e.rec.x, e.rec.y + e.rec.height}
                                }

                                can_move = check_valid_move(new_pos, ai_dt_pool[i].last_pos)

                                if can_move
                                {
                                    break while
                                }
                            }

                            if can_move {
                                for x := 0; x < entity_count; x+=1
                                {
                                    if entity_pool[x].id == e.id 
                                    {
                                        entity_pool[x].rec.x = new_pos.x
                                        entity_pool[x].rec.y = new_pos.y
                                    }
                                }
                            }

                            ai_dt_pool[i].move_timer = 0
                        }
                    }
                }
            }
        }
        if e.type == .ENT_SPIKE
        {
            if e.active
            {
                if CheckCollisionRecs(entity_pool[0].rec, e.rec)
                {
                    //get spike data from current ent
                    for i := 0; i < spike_dt_count; i+=1
                    {
                        if spike_dt_pool[i].ent_id == e.id
                        {
                            if spike_dt_pool[i].trigger == false
                            {
                                spike_dt_pool[i].trigger = true
                                //fmt.printf("FIRE SPIKE\n")
                            }
                        }
                    }
                }

                if CheckCollisionRecs(entity_pool[0].rec, e.rec)
                {
                    //get spike data from current ent
                    for i := 0; i < spike_dt_count; i+=1
                    {
                        if spike_dt_pool[i].ent_id == e.id
                        {
                            if spike_dt_pool[i].can_kill
                            {
                                fmt.printf("KILL PLAYER 1\n")
                                shaking = true
                                shake_intensity = L_int
                                shake_duration = S_dur
                                p2_score += 1
                                respawn_player(&entity_pool[0])
                                //current_screen = .MAIN_MENU
                            }
                        }
                    }
                }

                if CheckCollisionRecs(entity_pool[1].rec, e.rec)
                {
                    //get spike data from current ent
                    for i := 0; i < spike_dt_count; i+=1
                    {
                        if spike_dt_pool[i].ent_id == e.id
                        {
                            if spike_dt_pool[i].trigger == false
                            {
                                spike_dt_pool[i].trigger = true
                                //fmt.printf("FIRE SPIKE\n")
                            }
                        }
                    }
                }

                if CheckCollisionRecs(entity_pool[1].rec, e.rec)
                {
                    //get spike data from current ent
                    for i := 0; i < spike_dt_count; i+=1
                    {
                        if spike_dt_pool[i].ent_id == e.id
                        {
                            if spike_dt_pool[i].can_kill
                            {
                                fmt.printf("KILL PLAYER 2\n")
                                shaking = true
                                shake_intensity = L_int
                                shake_duration = S_dur
                                p1_score += 1
                                respawn_player(&entity_pool[1])
                                //entity_pool[1].active = false
                                //current_screen = .MAIN_MENU
                            }
                        }
                    }
                }
            }
        }
    }

    //printf("P POS: %f, %f\n", entity_pool[0].rec.x, entity_pool[0].rec.y)
    if !p_data.is_moving
    {
        p_data.move_dir = Vector2{0,0}
    }
    if !p2_data.is_moving
    {
        p2_data.move_dir = Vector2{0,0}
    }
}

respawn_player :: proc(P : ^Entity)
{
    using rl

    if P.id == 0
    {
        create_player(int(P.spawn_id.x), int(P.spawn_id.y))
    }

    if P.id == 1
    {
        create_player_two(int(P.spawn_id.x), int(P.spawn_id.y))
    }
}

check_valid_move :: proc(POS, LAST_POS : rl.Vector2) -> bool
{
    using rl
    using fmt

    can_move := false
    for i := 0; i < ai_dt_count; i+= 1
    {
        for k := 0; k < entity_count; k+= 1
            {
                if CheckCollisionPointRec(POS, entity_pool[k].rec)
                {
                    if entity_pool[k].type != .ENT_WALL
                    {
                        if POS == LAST_POS 
                        {   
                            println("VBACKTRACK")
                        }
                        can_move = true
                    }
                    else 
                    {
                        can_move = false
                    }
                }
            }
    }

    return can_move
}
render_gameplay :: proc() {
    using rl

    BeginMode2D(cam);
	{
        render_background()
        
        { //tiles
            {//grid
                debug_grid :: false
                if debug_grid
                {
                    for x := 0; x < 11; x += 1 {
                        for y := 0; y < 11; y += 1
                        {
                            DrawRectangleLinesEx(Rectangle{f32((x * 16 * SCALE) + 10), f32((y * 16 * SCALE) + 10), 16 * f32(SCALE), 16 * f32(SCALE)}, 1, DARKGRAY) 
                        }
                    }
                }
            }

            {// entities
                render_ent_of_type(.ENT_WALL, false) 
                render_ent_of_type(.ENT_SPIKE, false)
                render_ent_of_type(.ENT_PLAYER, true) 
                render_ent_of_type(.ENT_PLAYER_TWO, true) 
                render_ent_of_type(.ENT_AI, false)
            }
        }
    }
    EndMode2D()

    if is_paused && ((pause_blink_counter / 30) % 2 == 0)
    {
        DrawText("GAME PAUSED", i32(SCREEN.x / 2 - 290), i32(SCREEN.y / 2 - 50), 80, rl.RED)
    } 

    {// UI
    //    render_buttons()
        DrawText(TextFormat("Mouse: %i, %i", GetMouseX(), GetMouseY()), 20, 20, 20, GRAY)
        DrawText(TextFormat("P1 Kill Count: %i", p1_score), 20, 40, 30, C_PLAYER)
        DrawText(TextFormat("%f %f", entity_pool[0].rec.x, entity_pool[0].rec.y), 20, 80, 20, C_PLAYER)
        DrawText(TextFormat("P2 Kill Count: %i", p2_score), i32(SCREEN.x - 250), 40, 30, C_PLAYER_TWO)
        DrawText(TextFormat("%f %f", entity_pool[1].rec.x, entity_pool[1].rec.y), i32(SCREEN.x - 250), 80, 20, C_PLAYER_TWO)
    }
    
}

render_ent_of_type :: proc(TYPE : Entity_Type, DEBUG : bool) 
{
    using rl
    using fmt

    e : Entity

    for i := 0; i < entity_count; i+= 1
    {
        e = entity_pool[i]
        
        if e.type == TYPE
        {

            if e.active
            {
                e.rec.x += 15
                e.rec.y += 15

                if e.type == .ENT_PLAYER || e.type == .ENT_PLAYER_TWO
                {
                    DrawTexturePro(TEX_SPRITESHEET, e.spr.src, e.rec, Vector2{0,0}, 0, e.spr.color)
                }
                else 
                {
                    DrawTexturePro(TEX_SPRITESHEET, e.spr.src, e.rec, Vector2{0,0}, f32(e.rot), e.spr.color)
                }
                
                if DEBUG
                {
                    DrawRectangleLinesEx(e.rec, 2, RED)
                }
            }
        }

    }
}

shake_screen :: proc(CAM : ^rl.Camera2D, INTENSITY : f32)
{
    using rl

    if shaking 
    {
		cam.offset = Vector2{ math.sin_f32(f32(GetTime() * 90)) * INTENSITY, math.sin_f32(f32(GetTime() * 180)) * INTENSITY };
		cam.offset.x += cam_start_off.x;
		cam.offset.y += cam_start_off.y;
	}
	else {
		cam.offset = cam_start_off;
	}
}
