package main

import "core:strings"
import "core:fmt"
import RL "vendor:raylib" 
import net "vendor:sdl2/net"

main :: proc() {
    using RL

	RL.SetRandomSeed(42)
	
	name := strings.clone_to_cstring(project_name)
	xxx : i32 = i32(SCREEN.x)
	yyy : i32 = i32(SCREEN.y)
	InitWindow(xxx, yyy, name)

    InitAudioDevice()
    //bg_music := LoadMusicStream("../assets/bg_music.wav")
    //bg_music.looping = true

	setup_window()

    ok := net.Init()
    if (ok == -1)
    {
        fmt.println("Could not init SDL Net")
        panic(string(net.GetError()))
    }

    ip : net.IPaddress
    if (net.ResolveHost(&ip, nil, 8099) == -1)
    {
        fmt.println("Could not resolve host")
        panic(string(net.GetError()))
    }
    
    server_socker = net.TCP_Open(&ip)
    if (server_socker == nil)
    {
        fmt.println("Could not open TCP")
        panic(string(net.GetError()))
    }

    socket_set = net.AllocSocketSet(MAX_SOCKETS + 1)    // + 1 to account for the server socket on top of client sockets
    if (socket_set == nil)
    {
        fmt.println("Could not allocate socket set")
        panic(string(net.GetError()))
    }

    if (net.TCP_AddSocket(socket_set, server_socker) == -1)
    {
        fmt.println("Could not add socket set to socker server")
        panic(string(net.GetError()))
    }


	is_running: bool = true
	for is_running && !WindowShouldClose()
    {
        //update net
        num_rdy : i32 = net.CheckSockets(socket_set, 1000)

        for i in 0..< MAX_SOCKETS
        {
            if (clients[i].in_use == 0) 
            {
                continue
            }

            clients[i].amt_wood += 4;
        }


        if (num_rdy <= 0)
        {
            // NOTE: none of the sockets are ready
        }
        else 
        {
            // NOTE: some number of sockets are ready
            if (net.SocketReady(server_socker))
            {
                got_socket := accept_socket(next_ind)
                if (got_socket == 0)
                {
                    num_rdy -= 1
                    continue
                }

                //NOTE: get a new index
                chk_count := 0
                for chk_count in 0..<MAX_SOCKETS 
                {
                    if(sockets[(next_ind + chk_count) % MAX_SOCKETS] == nil)
                    {
                        break
                    }
                }

                next_ind = (next_ind + chk_count) % MAX_SOCKETS
                fmt.println("DB: new connection ", next_ind)

                num_rdy -= 1
            }

            for i := 0; (i < MAX_SOCKETS) && (num_rdy > 0); i += 1
            {
                if (sockets[i] == nil)
                {
                    continue
                }

                if (!net.SocketReady(sockets[i]))
                {
                    continue
                }

                data    : ^u8
                flag    : u16
                length  : u16

                data = recv_data(i, &length, &flag)
                if (data == nil)
                {
                    num_rdy -= 1
                    continue
                }
            }
        }
        
        //update game 

        //render game 
        RL.BeginDrawing()
            
            ClearBackground(RAYWHITE)

            DrawText("SDL 2 Net", 190, 200, 20, LIGHTGRAY)

        EndDrawing()
	}

	clear_and_shutdown() // Cleanup SDL2 Net 

	CloseWindow()
}

recv_data :: proc(idx : int, len, flag : ^u16) -> ^u8
{
    temp_data : ^[MAX_PACKET]u8  // need to recast and interpret as [MAX_PACKET]u8
    num_recv := net.TCP_Recv(sockets[idx], cast(rawptr)temp_data, MAX_PACKET)

    if (num_recv <= 0)
    {
        close_socket(idx)
        err := net.GetError()
        fmt.printf("RECIEVE ISSUE")
        fmt.println(net.GetError())

        return nil
    }
    else 
    {
        //offset := 0
        //flag^ = cast(u16)temp_data[offset]^
    }
    return nil 
}

accept_socket :: proc(idx : int) -> int
{
    if(sockets[idx] != nil)
    {
        fmt.println("Overriding socket")
        close_socket(idx)
    }

    sockets[idx] = net.TCP_Accept(server_socker)
    if (sockets[idx] == nil)
    {
        return 0
    }

    clients[idx].in_use = 1;
    if (net.TCP_AddSocket(socket_set, sockets[idx]) == -1)
    {
        fmt.println("Add socket fail")
        panic(string(net.GetError()))
    }

    return 1
}

setup_window :: proc(){
    using RL
	SetTargetFPS(60)

	icon: Image = LoadImage("../assets/icons/window_icon.png")

	ImageFormat(&icon, PixelFormat.UNCOMPRESSED_R8G8B8A8)

	SetWindowIcon(icon)

	UnloadImage(icon)
}

close_socket :: proc(idx : int)
{
    using net

    if (sockets[idx] == nil)
    {
        fmt.println("Attempted to delete a NULL socket")
        panic("Nil socket deletion")
    }

    if (TCP_DelSocket(socket_set, sockets[idx]) == -1)
    {
        fmt.println("Could not TCP del socket")
        panic(string(net.GetError()))
    }

    clients = {}
    TCP_Close(sockets[idx])
    sockets[idx] = {} 
}

clear_and_shutdown :: proc()
{
    using net

    if (TCP_DelSocket(socket_set, server_socker) == -1)
    {
        fmt.println("Could not TCP del socket")
        panic(string(net.GetError()))
    }

    TCP_Close(server_socker)

    for i in 0..< MAX_SOCKETS
    {
        if (sockets[i] == nil)
        {
            continue
        }
        
        close_socket(i)
    }

    FreeSocketSet(socket_set)
    net.Quit()
}
