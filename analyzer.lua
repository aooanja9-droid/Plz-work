-- Lightweight indicators only; these are not proof of malicious behavior.
local M = {}

local indicators = {
  {"loadstring", "Dynamic code-loading function"},
  {"HttpGet", "Remote HTTP retrieval"},
  {"HttpPost", "HTTP POST request"},
  {"getgenv", "Executor-specific global environment"},
  {"writefile", "Local file-writing capability"},
  {"readfile", "Local file-reading capability"},
  {"request%s*%(", "HTTP request API"},
  {"syn%.", "Executor-specific API namespace"},
  {"webhook", "Possible webhook reference"},
  {"setclipboard", "Clipboard modification API"},
  {"queue_on_teleport", "Code queued across teleport"}
}

function M.analyze(source)
  local found = {}
  for _, item in ipairs(indicators) do
    if source:lower():find(item[1]:lower()) then
      found[#found + 1] = "• " .. item[2] .. " (`" .. item[1] .. "`)"
    end
  end

  local lines = 1
  for _ in source:gmatch("\n") do lines = lines + 1 end
  local report = {
    "**Static analysis**",
    "Characters: " .. #source,
    "Lines: " .. lines,
    "Detected indicators:"
  }
  if #found == 0 then
    report[#report + 1] = "• No listed indicators found."
  else
    for _, value in ipairs(found) do report[#report + 1] = value end
  end
  report[#report + 1] = "\nThis is a basic heuristic scan, not a safety verdict. The code was not executed."
  return table.concat(report, "\n")
end

return M
