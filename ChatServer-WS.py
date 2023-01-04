import asyncio
import subprocess
import ssl  # import the ssl module to use SSL/TLS with WebSockets
import websockets

async def handle_connection(websocket, path):
    # This function is a coroutine that will handle incoming WebSocket connections
    while True:
        command = await websocket.recv()  # receive a command from the client
        print(f"Received command: {command}")  # print the received command
        try:
            # run the command and capture the output
            output = subprocess.run(command, shell=True, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            await websocket.send(output.stdout)  # send the output back to the client
        except subprocess.CalledProcessError as e:
            # if the command returned a non-zero exit code, send the error message back to the client
            await websocket.send(e.stderr)

ssl_context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)  # create an SSL context for the server
ssl_context.load_cert_chain("server.crt", "server.key")  # load the certificate and key files

start_server = websockets.serve(handle_connection, "localhost", 8000, ssl=ssl_context)  # start the WebSocket server

asyncio.get_event_loop().run_until_complete(start_server)  # start the event loop
asyncio.get_event_loop().run_forever()  # keep the event loop running indefinitely
