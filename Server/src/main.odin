package main

import "core:fmt"
import "core:strings"
import "vendor:ENet"

main :: proc() {
  using fmt

  if ENet.initialize() != 0 {
    // println("An error occured while initializing ENet")
    panic("An error occured while initializing ENet")
  } else {
    printfln("---Server Starting---")
  }
  defer (ENet.deinitialize())

  adress: ENet.Address
  server: ^ENet.Host
  event: ENet.Event

  adress.host = ENet.HOST_ANY
  adress.port = 7777

  server = ENet.host_create(&adress, 16, 1, 0, 0)

  if server == nil {
    panic("An error occured while trying to create an ENet Server Host")
  }

  //GAME LOOP START

  for {
    for ENet.host_service(server, &event, 1000) > 0 {

      switch event.type 
      {
      case .CONNECT:
        printfln(
          "A new client connected from %i:%i.",
          event.peer^.address.host,
          event.peer^.address.port,
        )
        break


      case .RECEIVE:
        printfln(
          "A packet of length %u containing %s was received from %u:%u on channel %u.",
          event.packet.dataLength,
          event.packet.data,
          event.peer.address.host,
          event.peer.address.port,
          event.channelID,
        )
        break

      case .DISCONNECT:
        printfln(
          "%u:%u disconnected.",
          event.peer.address.host,
          event.peer.address.port,
        )
        break

      case .NONE:
        break

      }
    }
  }
  //GAME LOOP END

  ENet.host_destroy(server)

}
