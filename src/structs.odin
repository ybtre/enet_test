package PushChase

import rl "vendor:raylib"

Sprite :: struct 
{
    src         : rl.Rectangle,
    color       : rl.Color,
    center      : rl.Vector2,
}

Background :: struct
{
    active      : bool,
    rec         : rl.Rectangle,
    spr         : Sprite,
}
