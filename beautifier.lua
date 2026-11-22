-- A deliberately small formatter. It does not parse Lua syntax or deobfuscate VM code.
local M = {}

local function trim(s)
  return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

function M.format(source)
  local out, depth = {}, 0
  for line in (source .. "\n"):gmatch("(.-)\n") do
    local s = trim(line)
    if s ~= "" then
      local lower = s:lower()
      if lower:match("^end[%s;]*$") or lower:match("^until[%s%(]") or
         lower:match("^else[%s;]*$") or lower:match("^elseif[%s]") then
        depth = math.max(0, depth - 1)
      end
      out[#out + 1] = string.rep("  ", depth) .. s
      if lower:match("%f[%a]function%f[%A]") or lower:match("^if%f[%A].*then%s*$") or
         lower:match("^for%f[%A].*do%s*$") or lower:match("^while%f[%A].*do%s*$") or
         lower:match("^repeat%s*$") or lower:match("^else%s*$") or lower:match("^elseif.*then%s*$") then
        depth = depth + 1
      end
    end
  end
  return table.concat(out, "\n") .. "\n"
end

return M
