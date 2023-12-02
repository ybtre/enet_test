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
    rec         : rl.Rectangle,
    spr         : Sprite,
}

Player_Data :: struct {
    speed       : f32,
    move_dir    : rl.Vector2,
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

Background :: struct {
    spr: Sprite,
}
