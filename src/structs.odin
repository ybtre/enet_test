package main

import rl "vendor:raylib"

//--------- SERVER

//--------- CLIENT
Client :: struct 
{
    in_use      : i32,  // is current user being used by active socker connection
    questing    : i32,
    amt_wood    : u8,   // amount of wood client has
    timer_wood  : u32,  
}
