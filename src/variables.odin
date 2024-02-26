package main

import RL "vendor:raylib"
import net "vendor:sdl2/net"

// --------- STRUCTS

// --------- SERVER
next_ind        : int                           // index into sockets and clients array for the next player to connect
server_socker   : net.TCPsocket
clients         : [MAX_SOCKETS]Client
socket_set      : net.SocketSet
sockets         : [MAX_SOCKETS]net.TCPsocket

// --------- CLIENT


// --------- BOOLS
game_paused := false

// --------- TIMERS
pause_blink_counter     :   i64     = 0
gameplay_time_total     :   f64     = 0.0
gameplay_time_current   :   f64     = 0.0
