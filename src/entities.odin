package fantasy_chess 

import rl "vendor:raylib"

Sprite :: struct {
    src: rl.Rectangle,
    color: rl.Color,

    center: rl.Vector2,
}

Entity_Type :: enum {
    ENT_PLAYER,
    ENT_PLAYER_TWO,
    ENT_WALL,
    ENT_SPIKE,
    ENT_AI,
}

Entity :: struct {
    active      : bool,
    type        : Entity_Type,
    id          : int,
    rec         : rl.Rectangle,
    rot         : int,
    spr         : Sprite,
}

Player_Data :: struct {
    is_moving   : bool,
    speed       : f32,
    velocity    : f32,
    move_dir    : rl.Vector2,
}

Spike_Data :: struct {
    ent_id      : int,

    active      : bool,
    trigger     : bool,
    can_kill    : bool,

    trigger_timer   : f32,
    trigger_delay   : f32,
    trigger_dur     : f32,
}

AI_Data :: struct {
    ent_id      : int,

    active      : bool,

    move_timer  : f32,
    move_delay  : f32,
    last_pos    : rl.Vector2,
}

Background :: struct {
    active      : bool,
    rec         : rl.Rectangle,
    spr         : Sprite,
}

Cursor :: struct {
    spr: Sprite,
}

Button :: struct {
    rec: rl.Rectangle,
    spr: Sprite,
    is_highlighted: bool,
    is_pressed: bool,
}
