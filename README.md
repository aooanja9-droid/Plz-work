# Lua Discord Static Analyzer

A small Lua/Discord bot starter for inspecting Roblox Lua loader snippets. It is designed to be conservative:

- Recognizes common `loadstring(game:HttpGet("URL"))()` patterns.
- Reports suspicious or powerful API indicators.
- Provides basic formatting.
- **Never executes submitted Lua.**
- **Does not download or run remote scripts.**

## Important limitations

This is a safe starter, not a universal deobfuscator. It cannot reverse every obfuscator, virtual machine, encrypted payload, or server-side loader. A loader URL is extracted for inspection, but its contents are not fetched. The `!deobfuscate` output preserves the original code and adds a static-analysis note.

File attachment download and true slash-command registration are not included in this starter version. Users can paste text using prefix commands. These are deliberate gaps to avoid pretending untested functionality works.

## Requirements

- Luvit
- Discordia for Luvit
- A Discord bot application and token

Install Luvit, then install Discordia using the package manager documented by the Discordia project. Package installation commands can change, so follow the current Discordia/Luvit installation guide.

## Configure

Set the bot token as an environment variable named `DISCORD_BOT_TOKEN`. Do not put your real token in source code, GitHub, screenshots, or chat.

Optional:
- `BOT_PREFIX` (default `!`)
- `MAX_INPUT_BYTES` (default `120000`)
- `MAX_OUTPUT_BYTES` (default `180000`)

## Run

From this folder, run:

```sh
luvit bot.lua
```

## Commands

```text
!help
!deobfuscate loadstring(game:HttpGet("https://example.com/script.lua"))()
!analyze <paste Lua or loader text>
!beautify <paste Lua>
```

The starter currently accepts pasted text. `.lua` and `.txt` attachment handling is listed as a future task; it is not yet implemented.

## Discord permissions

For the basic prefix-command starter, enable the Message Content Intent in the Discord Developer Portal and grant the bot View Channels, Send Messages, and Attach Files permissions.

## Security notes

Treat all pasted code and URLs as untrusted. Do not execute unknown scripts. Do not add automatic remote fetching without strict URL allowlists, DNS/IP validation, redirect controls, size limits, and timeouts. Never log bot tokens.
