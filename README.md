# nim_slack
Nim-lang newAsyncHttpServer for receiving commands, responding and sending messages 

# General

This nim file was created with the purpose to control a Raspberry Pi 3.

When running the main.nim a newAsyncHttpServer will spawn and listen for incoming connections. I has two ways to act:
1) Responding with a challenge to verify the connection with slack
2) Parsing a command and responding

# Prerequisites

## Slack account
Get a slack account (https://slack.com)

## Slack app
You need to build a slack app to communicate with.

1) Create a new slack app (https://api.slack.com/apps/new)
2) Permissions: Incoming webhooks, Slash commands, Permissions
3) Install the app to your team
4) Scopes: commands, incoming webhooks

## Adjust the main.nim

Adjust the parameters:
1) const incomingWebhookUrl <-- the incoming webhook URL from you slack app
2) const slackPort <-- the port opened in your router

## Router

You need to open the port in your router according to the specificed port in main.nim

# Run

Run it with:

`nim c -d:ssl main.nim`

