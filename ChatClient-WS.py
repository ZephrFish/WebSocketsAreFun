import asyncio
import ssl  # import the ssl module to use SSL/TLS with WebSockets
import websockets

async def send_command(command):
    # This function is a coroutine that sends a command to the server and prints the response
    ssl_context = ssl.SSLContext(ssl.PROTOCOL_TLS_CLIENT)  # create an SSL context for the client
    async with websockets.connect("wss://localhost:8000", ssl=ssl_context) as websocket:  # connect to the server
        await websocket.send(command)  # send the command to the server
        response = await websocket.recv()  # receive the response from the server
        print(response)  # print the response

command = input("Enter a command to execute on the server: ")  # get the command from the user
asyncio.get_event_loop().run_until_complete(send_command(command))  # run the send_command coroutine
