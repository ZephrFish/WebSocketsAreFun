import asyncio
import websockets

async def netcat_listener(port):
    # Start the WebSocket server
    async def handler(websocket, path):
        # Start the reader and writer tasks
        reader_task = asyncio.create_task(reader(websocket))
        writer_task = asyncio.create_task(writer(websocket))
        # Wait for the tasks to complete
        await asyncio.gather(reader_task, writer_task)

    start_server = websockets.serve(handler, "localhost", port)
    await start_server

async def reader(websocket):
    # Read messages from the client and print them to the console
    while True:
        message = await websocket.recv()
        print(message)

async def writer(websocket):
    # Read input from the console and send it to the client
    while True:
        message = input()
        await websocket.send(message)

# Set the port
port = 8000

# Run the netcat_listener function
asyncio.run(netcat_listener(port))
