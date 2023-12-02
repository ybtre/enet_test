package fantasy_chess 

import rl "vendor:raylib"

Sprite :: struct {
    src: rl.Rectangle,
    color: rl.Color,

    center: rl.Vector2,
}

Entity_Type :: enum {
    ENT_PLAYER,
    ENT_WALL,
}

Entity :: struct {
    active      : bool,
    type        : Entity_Type,
    id          : rl.Vector2,
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
