# WebSocketsAreFun
In its current form WebSocketsAreFun is composed of a python client/server setup and a powershell client, which is a work in progress.

The powershell client will connect to a websocket server on whatever host/port you specify and await input, it is not proxy aware at the moment but there are some testing commands built in.

## Current Setup

- [WS-ClientCMD.py](https://github.com/ZephrFish/WebsocketsC2/blob/main/WS-ClientCMD.py) - This script will connect to a specified websockets host, as outlined on line 9 and listen for command output to execute serverside, however this process needs to be switched to get it working properly.
- [WS-ServerCMD.py](https://github.com/ZephrFish/WebsocketsC2/blob/main/WS-ServerCMD.py) - This listens for output, then executes commands on the server and returns the resposne to the client, it's like a reverse C2 Server.
- [SockMe-It.ps1](https://github.com/ZephrFish/WebsocketsC2/blob/main/SockMe-It.ps1) - This is a powershell client that will connect to a server and listen for commands from a fixed location then send output back.
- [PadSockets](https://github.com/ZephrFish/PadSockets) - Some more WebSockets fun for setting up a notepad and some python for a web app.

Additional tools in this repo include PadSockets. Which is a second project which uses websockets in a web server setup with a note pad application which is a good place of reference for copy and pasting into an environment.

Future plans are to roll in some tradecraft for file uploads and downloads plus secure websockets for Pad, but not today satan.
