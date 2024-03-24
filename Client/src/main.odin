package main

import "core:fmt"
import "core:strings"
import "vendor:ENet"

main :: proc() {
  using fmt

  if ENet.initialize() != 0 {
    printfln("An error occured while initializing ENet")
    panic("Error")
  }
  defer (ENet.deinitialize())

  client: ^ENet.Host
  client = ENet.host_create(nil, 1, 1, 0, 0)

  if client == nil {
    panic("Could not create ENet client")
  }

  adress: ENet.Address
  event: ENet.Event
  peer: ^ENet.Peer

  ENet.address_set_host(&adress, "127.0.0.1")
  adress.port = 7777

  peer = ENet.host_connect(client, &adress, 1, 0)
  if peer == nil {
    panic("No available peer for ENet connection")
  }

  if ENet.host_service(client, &event, 5000) > 0 &&
     event.type == ENet.EventType.CONNECT {

    printfln("Connection to 127.0.0.1 SUCCESS")

  } else {

    ENet.peer_reset(peer)
    printfln("Connection to 127.0.0.1 FAILED")
  }

  // GAME LOOP START
  for ENet.host_service(client, &event, 1000) > 0 {
    switch event.type 
    {
    case .RECEIVE:
      printfln(
        "A packet of length %u containing %s was received from %x:%u on channel %u.\n",
        event.packet.dataLength,
        event.packet.data,
        event.peer.address.host,
        event.peer.address.port,
        event.channelID,
      )
      break

    case .DISCONNECT:
      break
    case .CONNECT:
      break
    case .NONE:
      break
    }
  }

  // GAME LOOP END

  ENet.peer_disconnect(peer, 0)

  for ENet.host_service(client, &event, 3000) > 0 {
    switch event.type 
    {
    case .RECEIVE:
      ENet.packet_destroy(event.packet)
      break

    case .DISCONNECT:
      printfln("Disconnection succeeded")
      break

    case .CONNECT:
      break
    case .NONE:
      break
    }
  }


}
