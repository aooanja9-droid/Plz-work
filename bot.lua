-- Lua Discord Deobfuscator bot
-- Static analysis only: submitted code is NEVER executed.
local discordia = require("discordia")
local json = require("json")
local fs = require("fs")
local path = require("path")
local deobfuscator = require("./src/deobfuscator")
local analyzer = require("./src/analyzer")
local beautifier = require("./src/beautifier")

local client = discordia.Client({
  cacheAllMembers = false,
  logLevel = "warning"
})

local PREFIX = os.getenv("BOT_PREFIX") or "!"
local MAX_INPUT = tonumber(os.getenv("MAX_INPUT_BYTES") or "120000")
local MAX_OUTPUT = tonumber(os.getenv("MAX_OUTPUT_BYTES") or "180000")

local function safe_send(channel, content)
  if #content > 1900 then
    content = content:sub(1, 1850) .. "\n...[message shortened]"
  end
  channel:send(content)
end

local function read_attachment(attachment)
  -- Discord attachment URLs are treated as untrusted input.
  -- Downloading attachments is intentionally not implemented in this starter.
  return nil, "Attachment reading is not enabled in this starter build. Paste the text instead."
end

local function get_input(message, args)
  local text = table.concat(args, " ")
  if text == "" and message.attachments and message.attachments.first then
    local attachment = message.attachments:first()
    return read_attachment(attachment)
  end
  if text == "" then return nil, "Please paste a loader, URL, or Lua text after the command." end
  if #text > MAX_INPUT then return nil, "Input is too large. Maximum: " .. MAX_INPUT .. " bytes." end
  return text
end

local function send_report(message, heading, body, filename)
  body = tostring(body or "")
  if #body > MAX_OUTPUT then body = body:sub(1, MAX_OUTPUT) .. "\n-- Output truncated." end
  local file = filename or "result.lua"
  local tmp = path.join(os.tmpname(), file)
  local ok, err = fs.writeFileSync(tmp, body)
  if not ok then
    safe_send(message.channel, heading .. "\n```text\n" .. tostring(err) .. "\n```")
    return
  end
  message.channel:send({
    content = heading,
    file = {file = tmp, name = file}
  })
  pcall(fs.unlinkSync, tmp)
end

client:on("ready", function()
  print("Logged in as " .. client.user.username .. ". Static-only mode is active.")
end)

client:on("messageCreate", function(message)
  if message.author.bot then return end
  local content = message.content or ""
  if content:sub(1, #PREFIX) ~= PREFIX then return end

  local command, rest = content:sub(#PREFIX + 1):match("^(%S+)%s*(.*)$")
  if not command then return end
  command = command:lower()
  local args = {}
  for token in (rest or ""):gmatch("%S+") do args[#args + 1] = token end

  if command == "help" then
    safe_send(message.channel,
      "**Lua Static Analyzer**\n" ..
      "`!deobfuscate <loader/url/Lua>` — unwrap common loader patterns and format text\n" ..
      "`!analyze <loader/url/Lua>` — inspect indicators without running code\n" ..
      "`!beautify <Lua>` — basic indentation/spacing cleanup\n" ..
      "You can also attach `.lua` or `.txt` files, but attachment download is not enabled yet.\n" ..
      "**Safety:** this bot never executes submitted code or fetches remote scripts.")
    return
  end

  local input, input_err = get_input(message, args)
  if not input then safe_send(message.channel, "⚠️ " .. input_err); return end

  if command == "deobfuscate" then
    local result = deobfuscator.process(input)
    local formatted = beautifier.format(result.text)
    send_report(message, "Static result (not executed; remote URLs are not fetched):", formatted, "deobfuscated.lua")
    if result.url then
      safe_send(message.channel, "Loader URL found: `" .. result.url .. "`\nThe target was **not downloaded**. Review it manually before using it.")
    end
  elseif command == "analyze" then
    local report = analyzer.analyze(input)
    safe_send(message.channel, report)
  elseif command == "beautify" then
    send_report(message, "Formatted Lua (basic formatter; review the result):",
      beautifier.format(input), "beautified.lua")
  end
end)

client:run("Bot " .. assert(os.getenv("DISCORD_BOT_TOKEN"), "Set DISCORD_BOT_TOKEN in your environment"))
