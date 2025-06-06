text = require("text")

--convert a table into a printable string
local function tableToString(tbl, indent)
  indent = indent or 0
  local str = ""
  local spaces = string.rep("  ", indent)
  
  if type(tbl) ~= "table" then
    return tostring(tbl)
  end
  
  str = str .. "{\n"
  for k, v in pairs(tbl) do
    local key = type(k) == "string" and ('["'..k..'"]') or ("["..tostring(k).."]")
    str = str .. spaces .. "  " .. key .. " = "
    if type(v) == "table" then
      str = str .. tableToString(v, indent + 1)
    else
      str = str .. tostring(v)
    end
    str = str .. ",\n"
  end
  str = str .. spaces .. "}"
  return str
end

--colour hsv to rgb converter (for rainbow text)
function HSVtoRGB(h, s, v)
    local c = v * s
    local x = c * (1 - math.abs((h / 60) % 2 - 1))
    local m = v - c

    local r, g, b

    if h < 60 then
        r, g, b = c, x, 0
    elseif h < 120 then
        r, g, b = x, c, 0
    elseif h < 180 then
        r, g, b = 0, c, x
    elseif h < 240 then
        r, g, b = 0, x, c
    elseif h < 300 then
        r, g, b = x, 0, c
    else
        r, g, b = c, 0, x
    end

    r = math.floor((r + m) * 255)
    g = math.floor((g + m) * 255)
    b = math.floor((b + m) * 255)

    return (r << 16) + (g << 8) + b
end

--wrap a text within a width
function tableWrap(txt, width)
    lines = {}
    i = 1
    while i < #txt do
        line = text.wrap(string.sub(txt, i, #txt), width, width)
        len = #line -- buffer
        line = text.trim(line)
        if #line > 0 then
            table.insert(lines, line)
        end
        i = i + len -- +2 spaces to ignore the space after the word
    end
    return lines
end

return {
    tableToString = tableToString,
    HSVtoRGB = HSVtoRGB,
    tableWrap = tableWrap
}