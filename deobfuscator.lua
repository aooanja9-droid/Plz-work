-- Conservative static loader recognizer. Does not execute code or fetch URLs.
local M = {}

local function unescape(s)
  return (s:gsub("\\\\", "\\"):gsub('\\"', '"'):gsub("\\'", "'"))
end

function M.process(source)
  local text = source
  local url =
    source:match('HttpGet%s*%(%s*"([^"]+)"%s*%)') or
    source:match("HttpGet%s*%(%s*'([^']+)'%s*%)") or
    source:match('http%s*%.%s*request%s*%(%s*{.-Url%s*=%s*"([^"]+)"') or
    source:match("https?://[%w%-%._~:/%?#%[%]@!$&'()*+,;=%%]+")
  if url then url = unescape(url) end

  -- Recognize a direct loadstring(HttpGet(...)) wrapper and expose the URL.
  -- Keep the original text because the remote body is not retrieved.
  local simplified = source
  simplified = simplified:gsub("loadstring%s*%(%s*game%s*:%s*HttpGet", "loadstring(game:HttpGet")
  return {
    text = "-- Static inspection only. No remote code was fetched or executed.\n" .. simplified,
    url = url
  }
end

return M
