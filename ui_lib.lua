local component = require("component")
local gpu = component.gpu
local term = require("term")
local stru = require("stringutils")

box_chars = {
    hline = "━",
    vline = "┃",
    topleft = "┏",
    topright = "┓",
    botleft = "┗",
    botright = "┛"
}

--wrtie directly to the screen without moveCursor
function fwrite(x, y, _text, fg, bg)
    local saveFg, saveBg = false, false
    local oldFg, oldBg = nil, nil
    if fg then
        oldFg = gpu.getForeground()
        gpu.setForeground(fg)
        saveFg = true
    end

    if bg then
        oldBg = gpu.getBackground()
        gpu.setBackground(bg)
        saveBg = true
    end

    gpu.set(x, y, _text)

    if saveFg then gpu.setForeground(oldFg) end
    if saveBg then gpu.setBackground(oldBg) end

end

--baseElement class - abstract, has basic fields
baseElement = {id, x=1, y=1, w=1, h=1, fg, bg}
baseElement.__index = baseElement

function baseElement.new(id)
    local obj = setmetatable({}, baseElement)
    obj.id = id
    return obj
end

function baseElement:setX(x) self.x = x end
function baseElement:setY(y) self.y = y end
function baseElement:setWidth(w) self.w = w end
function baseElement:setHeight(h) self.h = h end
function baseElement:setForeground(fg) self.fg = fg end
function baseElement:setBackground(bg) self.bg = bg end

function baseElement:getX() return self.x end
function baseElement:getY() return self.y end
function baseElement:getWidth() return self.w end
function baseElement:getHeight() return self.h end
function baseElement:getForeground() return self.fg end
function baseElement:getBackground() return self.bg end

--container element class - baseElement with childrens table
containerElement = setmetatable({}, baseElement)
containerElement.__index = containerElement

function containerElement.new(id)
    local obj = setmetatable({}, containerElement)
    obj.id = id
    obj.children = {}

    return obj
end

function containerElement:addChild(child)
    table.insert(self.children, child)
end

function containerElement:removeChild(id)
    for i, child in ipairs(self.children) do
        if child.id == id then 
            table.remove(self.children, i) 
            break
        end
    end
end

function containerElement:findChild(id)
    for i, child in ipairs(self.children) do
        if child.id == id then return child end
    end
end

function containerElement:getChildren()
    return self.children
end

function containerElement:clearChildren()
    for i, child in ipairs(self.children) do
        self.children[i] = nil
    end
end

linearLayout = setmetatable({}, containerElement)
linearLayout.__index = linearLayout

--layout drawn without splitting children, only supports vertical layout bc why would you need a horizontal one
function linearLayout.new(id, gap)
    local gap = gap or 0
    local obj = containerElement.new(id)
    setmetatable(obj, linearLayout)

    obj.gap = gap

    return obj
end

function linearLayout:getGap() return self.gap end
function linearLayout:setGap(gap) self.gap = gap end 

function linearLayout:draw()
    local count = #self.children
    if count == 0 then return end
    local gap = self:getGap()

    -- colors
    local fg = self:getForeground()
    local bg = self:getBackground()
    
    -- coordinates
    local x = self:getX()
    local y = self:getY()
    local w = self:getWidth()
    local h = self:getHeight()

    -- check space
    local totalHeight = (count - 1) * gap
    for _, child in ipairs(self.children) do
        child:setWidth(w) --set width needs to be before getheight
        totalHeight = totalHeight + child:getHeight()
    end

    if totalHeight > h then
        term.clear()
        print(string.format("Not enough height in layout %s! Needed %d, got %d", self.id, totalHeight, h))
        error()
    end

    -- draw
    for _, child in ipairs(self.children) do
        child:setX(x)
        child:setY(y)
        child:draw()

        y = y + child:getHeight() + gap
    end
end


splitLayout = setmetatable({}, containerElement)
splitLayout.__index = splitLayout

--split layout, splits space equally to all children, mode is "vertical" or "horizontal"
function splitLayout.new(id, mode, gap)
    local gap = gap or 0
    local obj = containerElement.new(id)
    setmetatable(obj, splitLayout)

    if not mode then 
        term.clear()
        print(string.format("Mode for %s wasnt specified!", id))
        error()
     end
    obj.mode = mode
    obj.gap = gap

    return obj
end

function splitLayout:getGap() return self.gap end
function splitLayout:setGap(gap) self.gap = gap end
function splitLayout:getMode() return self.mode end
function splitLayout:setMode(gap) self.mode = gap end

function splitLayout:draw()
    --parameters
    local count = #self.children
    local mode = self.mode
    local gap = self:getGap()

    --colors
    local fg = self:getForeground()
    local bg = self:getBackground()
    
    --coordinates
    local x = self:getX()
    local y = self:getY()
    local w = self:getWidth()
    local h = self:getHeight()
    local right = x + w - 1
    local bottom = y + h - 1

    if self:getMode() == "vertical" then
        local aval_space = h - (count - 1) * gap --avalible space
        local obj_space = math.floor(aval_space / count) --space that each child occupies
        local extra_space = aval_space - count * obj_space --extra space (modulo)

        for i, child in ipairs(self.children) do
            local height = obj_space
            if extra_space > 0 then 
                height = height + 1
                extra_space = extra_space - 1
             end

            child:setX(x)
            child:setY(y)
            child:setWidth(w)
            child:setHeight(height)
            child:draw()
            y = y + height + gap
        end

    elseif self:getMode() == "horizontal" then
        local aval_space = w - (count - 1) * gap --avalible space
        local obj_space = math.floor(aval_space / count) --space that each child occupies
        local extra_space = aval_space - count * obj_space --extra space (modulo)

        for i, child in ipairs(self.children) do
            local width = obj_space
            if extra_space > 0 then
                width = width + 1 
                extra_space = extra_space - 1
            end

            child:setX(x)
            child:setY(y)
            child:setWidth(width)
            child:setHeight(h)
            child:draw()
            x = x + width + gap
        end

    else
        term.clear()
        print(string.format("Invalid mode for layout %s!", self.id)) 
        error()
    end
end

frame = setmetatable({}, baseElement)
frame.__index = frame

--object that holds a base, draws a frame around it and them draws the base
--you need to create the base by yourself and give it to the frame by setBase or by the constructor
function frame.new(id, base, fg, bg)
    local fg = fg or gpu.getForeground()
    local bg = bg or gpu.getBackground()

    local obj = setmetatable({}, frame)
    obj.id = id
    obj:setForeground(fg)
    obj:setBackground(bg)
    obj.base = base

    return obj
end

function frame:setBase(base) self.base = base end
function frame:getBase() return self.base end

function frame:draw()
    --base and colors
    local base = self:getBase()
    local fg = self:getForeground()
    local bg = self:getBackground()
    
    --coordinates
    local x = self:getX()
    local y = self:getY()
    local w = self:getWidth()
    local h = self:getHeight()
    local right = x + w - 1
    local bottom = y + h - 1

    --!top border is drawn like this to avoid flikering, if i end up making a screen buffer this is useless but whatever
    --top border
    fwrite(x, y, box_chars.topleft .. box_chars.hline, fg, bg)
    --title
    local titleSize = 0
    if(string.len(self.id) < w - 3) then
        local title = self.id
        titleSize = string.len(self.id)
        fwrite(x + 2, y, title, fg, bg)
    end
    --top border continue
    fwrite(x + titleSize + 2, y, string.rep(box_chars.hline, w - 3 - titleSize), fg, bg)
    fwrite(right, y, box_chars.topright, fg, bg)

    --bottom border
    fwrite(x, bottom, box_chars.botleft, fg, bg)
    fwrite(x + 1, bottom, string.rep(box_chars.hline, w - 2), fg, bg)
    fwrite(right, bottom, box_chars.botright, fg, bg)

    --vlines
    for i = y + 1, bottom - 1 do
        fwrite(x, i, box_chars.vline, fg, bg)
        fwrite(right, i, box_chars.vline, fg, bg)
    end

    --draw base
    if base then
        base:setX(x + 1)
        base:setY(y + 1)
        base:setWidth(w - 2)
        base:setHeight(h - 2)
        base:setForeground(fg)
        base:setBackground(bg)
        base:draw()
    end
end

label = setmetatable({}, baseElement)
label.__index = label

--should only be used in linear layout
function label.new(id, _text, centered, fg, bg)
    local obj = setmetatable({}, label)
    obj.id = id or nil
    obj.centered = centered or false
    obj._text = _text or ""
    obj.fg = fg or gpu.getForeground()
    obj.bg = bg or gpu.getBackground()
    obj.wrappedText = {}

    return obj
end

function label:setText(_text) self._text = _text end
function label:getText() return self._text end

--width needs to be set first
function label:getHeight()
    local width = self:getWidth()
    if not width then
        term.clear()
        print(string.format("Width wasnt set for label %s", self.id))
        error()
    end
    self.wrappedText = stru.tableWrap(self:getText(), width)
    self:setHeight(#(self.wrappedText))
    return self.h
end

function label:draw()
    --colors
    local fg = self:getForeground()
    local bg = self:getBackground()
    
    --coordinates
    local x = self:getX()
    local y = self:getY()
    local w = self:getWidth()

    local _text = self:getText()
    for i, line in ipairs(self.wrappedText) do
        local d = 0
        if self.centered then d = (w - string.len(line)) // 2 end
        fwrite(x + d, y, line, fg, bg)
        y = y + 1
    end
end

space = setmetatable({}, baseElement)
space.__index = space

function space.new(id, height)
    local obj = setmetatable({}, space)
    obj.id = id or nil
    obj.h = height or 1

    return obj
end

function space:draw()
    --the function doesnt do anything :))
end

progressBar = setmetatable({}, baseElement)
progressBar.__index = progressBar

function progressBar.new(id, min, max, fg, bg)
    local obj = setmetatable({}, progressBar)
    obj.id = id
    obj.fg = fg or gpu.getForeground()
    obj.bg = bg or 0x505050
    obj.min = min or 0
    obj.max = max or 100
    obj.value = 0

    return obj
end

function progressBar:setMin(min) self.min = min end
function progressBar:getMin() return self.min end
function progressBar:setMax(max) self.max = max end
function progressBar:getMax() return self.max end
function progressBar:setValue(value) self.value = value end
function progressBar:getValue() return self.value end
function progressBar:incrementValue(i) 
    local i = i or 1
    self.value = self.value + i
end

function progressBar:draw()
    --colors
    local fg = self:getForeground() --here fg is full block color
    local bg = self:getBackground() --and bg is empty block color

    --coordinates
    local x = self:getX()
    local y = self:getY()
    local w = self:getWidth()
    local h = self:getHeight()

    --bar parameters
    local min = self:getMin()
    local max = self:getMax()
    local value = self:getValue()

    local full = math.floor((value - min) / (max - min) * w)
    local empty = w - full

    for i = y, y + h - 1 do
        fwrite(x, i, string.rep(" ", full), _, fg)
        fwrite(x + full, i, string.rep(" ", empty), _, bg)
    end
end

return {
    fwrite = fwrite,
    baseElement = baseElement,
    containerElement = containerElement,
    linearLayout = linearLayout,
    splitLayout = splitLayout,
    frame = frame,
    label = label,
    space = space,
    progressBar = progressBar,
}