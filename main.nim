import
  os, strutils, asynchttpserver, asyncdispatch, json, cgi, httpclient

const
  incomingWebhookUrl = """https://hooks.slack.com/services/your/specialdata"""
  slackPort = 20446

var server = newAsyncHttpServer()

proc slackRepsonseMsg(username, fallback, color, title, value: string): JsonNode =
  result = 
    %*{"channel": "#general", 
      "username": username,
      "attachments":[
            {
              "fallback":fallback,
              "pretext":"",
              "color":color,
              "fields":[
                  {
                    "title":title,
                    "value":value,
                    "short":false
                  }
              ]
            }
        ]
      }


const msgFail = $slackRepsonseMsg("nimslack", "Failed task", "danger", "Alarm Update", "Failed to run the command")
  

proc slackRepsonseSend(message: string) {.async.} =
  var client = newAsyncHttpClient()
  client.headers = newHttpHeaders({ "Content-Type": "application/json" })
  discard await client.request(incomingWebhookUrl, httpMethod = HttpPost, body = message)
  client.close()


proc slackVerifyConn(challenge: string, req: Request, headers: HttpHeaders) {.async.} =
  let msg = %* {"challenge": challenge}
  echo "Send verification for connection"
  await req.respond(Http200, $msg, headers)


proc cb(req: Request) {.async.} =
  let responseRaw = req.body
  
  # Always responding in JSON format
  let headers = newHttpHeaders([("Content-Type","application/json")])

  # No yield inside try/except, therefore workaround with dummy if
  var veri = ""
  try:
    veri = parseJson(req.body)["challenge"].getStr()
  except:  
    discard

  if veri != "":
    # Run the verification process with challenge
    await slackVerifyConn(parseJson(req.body)["challenge"].getStr(), req, headers)
  else:
    # Parse received and respond
    # Create JSON
    var json_string = ""
    for items in split(decodeUrl(responseRaw), "&"):
      json_string.add("\"" & split(items, "=")[0] & "\": \"" & split(items, "=")[1] & "\",\n")
    let jsonNode = parseJson("{" & json_string[0 .. ^2] & "}")
    
    # Case the command
    case jsonNode["command"].getStr()
    # This here is the commands, which you will respond to
    of "/arm":
      # Run a proc and respond depending on result
      let exProc = 1
      if exProc == 1:
        let msg = $slackRepsonseMsg("nimslack", "Alarm is ARMED", "warning", "Alarm Update", "The alarm has been turned on")
        await req.respond(Http200, $msg, headers)
      else:
        await req.respond(Http200, $msgFail, headers)

    of "/disarm":
      let exProc = 1
      if exProc == 1:
        let msg = $slackRepsonseMsg("nimslack", "Alarm is DISARMED", "good", "Alarm Update", "The alarm has been disarmed")
        await req.respond(Http200, $msg, headers)
      else:
        await req.respond(Http200, $msgFail, headers)
    
    else:
      echo $req.body
      discard


asyncCheck slackRepsonseSend($slackRepsonseMsg("nimslack", "Connected", "good", "Alarm Update", "The controller has been turned on"))

asyncCheck server.serve(Port(slackPort), cb)

runForever()

