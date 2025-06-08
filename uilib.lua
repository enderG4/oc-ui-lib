--- OpenComputers Minimal UI Library.  
--- Provides UI elements like buttons, labels, and layouts.  
--- @module oc-ui-lib
--- @author enderG4
--- @license MIT  

local component = require("component")
local gpu = component.gpu
local term = require("term")
local stru = require("stringutils")
local event = require("event")

--errors in oc are trash, you dont need error stack just specify the id where the error takes place
function print_error(_text)
    term.clear()
    print(_text)
    os.exit(1)
end

box_chars = {
    hline = "━",
    vline = "┃",
    topleft = "┏",
    topright = "┓",
    botleft = "┗",
    botright = "┛"
}

--wrtie directly to the screen without moveCursor
function fwrite(x, y, _text, fg, bg, TRE) --TRE = touch return event
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
baseElement = {id, x=1, y=1, w=1, h=1, fg, bg, TRE}
baseElement.__index = baseElement

function baseElement.new(id)
    local obj = setmetatable({}, baseElement)
    obj.id = id
    return obj
end

function baseElement:setX(x)
    self.x = x
end
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
function baseElement:getId() return self.id end

--doesnt do anything by default, needs to be overriden
function baseElement:handleEvent(...)
    local name, _, x, y = ...
    if name == "touch" and type(self.TRE) == "string" then
        event.push(self.TRE, self.id, x, y)
    end
end

function baseElement:collide(x, y)
    return x >= self.x and x <= self.x + self.w - 1 and
        y >= self.y and y <= self.y + self.h - 1
end

function baseElement:setTouchReturnEvent(name)
    if type(name) == "string" then
        self.TRE = name
    end
end

function baseElement:measureHeight(w)
    return self.h
end

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

function containerElement:propagateEvent(...)
    local name, _, x, y = ...
    if name == "touch" then
        for i, child in ipairs(self.children) do
            if child:collide(x, y) then 
                child:handleEvent(...) 
            end
        end
    end
end

function containerElement:handleEvent(...)
    local name, _, x, y = ...
    if name == "touch" and type(self.TRE) == "string" then
        event.push(self.TRE, self.id, x, y)
    end
    self:propagateEvent(...)
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
    local totalHeight = self:measureHeight(w)

    if totalHeight > h then 
        print_error(string.format("Not enough height in layout %s! Needed %d, got %d", self.id, totalHeight, h))
    end

    -- draw
    for _, child in ipairs(self.children) do
        child:setX(x)
        child:setY(y)
        child:setHeight(child:measureHeight(w))
        child:setWidth(w)
        child:draw()

        y = y + child:getHeight() + gap
    end
end

function linearLayout:measureHeight(w)
    local count = #self.children
    if count == 0 then return 0 end
    local totalHeight = (count - 1) * self.gap
    for i, child in ipairs(self.children) do
        totalHeight = totalHeight + child:measureHeight(w)
    end

    --print(totalHeight)
    return totalHeight
end

splitLayout = setmetatable({}, containerElement)
splitLayout.__index = splitLayout

--split layout, splits space equally to all children, mode is "vertical" or "horizontal"
function splitLayout.new(id, mode, gap)
    local gap = gap or 0
    local obj = containerElement.new(id)
    setmetatable(obj, splitLayout)

    if not mode then 
        print_error(string.format("Mode for %s wasnt specified!", id))
     end
    obj.mode = mode
    obj.gap = gap

    return obj
end

function splitLayout:getGap() return self.gap end
function splitLayout:setGap(gap) self.gap = gap end
function splitLayout:getMode() return self.mode end
function splitLayout:setMode(mode) self.mode = mode end

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
        print_error(string.format("Invalid mode for layout %s!", self.id))
    end
end

--abstract class to hold only one element
singleElementContainer = setmetatable({}, baseElement)
singleElementContainer.__index = singleElementContainer

singleElementContainer.base = nil

-- :P
function singleElementContainer:setBase(base) 
    if type(base) ~= "table" then return end
    if not self.id and type(base.id) == "string" then
        self.id = base.id
    end
    self.base = base
end
function singleElementContainer:removeBase()
    self.base = nil
end
function singleElementContainer:getBase() return self.base end
function singleElementContainer:handleEvent(...)
    local _, _, x, y = ...
    if self.base then
        if self.base:collide(x, y) then self.base:handleEvent(...) end
    end
end
function singleElementContainer:isBaseContainer()
    if not self.base then return false end
    if not self.base.children then return false end
    return true
end
function singleElementContainer:addChild(child)
    if not self:isBaseContainer() then print_error(string.format("Container %s's base is not a container!", self.id)) end
    self.base:addChild(child)
end
function singleElementContainer:removeChild(id)
    if not self:isBaseContainer() then print_error(string.format("Container %s's base is not a container!", self.id)) end
    self.base:removeChild(id)
end
function singleElementContainer:findChild(id)
    if not self:isBaseContainer() then print_error(string.format("Container %s's base is not a container!", self.id)) end
    return self.base:findChild(id)
end
function singleElementContainer:getChildren()
    if not self:isBaseContainer() then print_error(string.format("Container %s's base is not a container!", self.id)) end
    return self.base:getChildren()
end
function singleElementContainer:clearChildren()
    if not self:isBaseContainer() then print_error(string.format("Container %s's base is not a container!", self.id)) end
    self.base:clearChildren()
end

--SEC doesnt get a measureHeight override but the classes that derive from it should have one
--not always tho for example frame also doent need one

frame = setmetatable({}, singleElementContainer)
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
    obj:setBase(base)

    return obj
end

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
    if(type(self.id) == "string" and string.len(self.id) < w - 3) then
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
-- to do: add a textChanged flag so that i dont recalculate wrappedText everytime
function label.new(id, _text, centered, fg, bg)
    local obj = setmetatable({}, label)
    obj.id = id or nil
    obj.centered = centered or false
    obj._text = _text or ""
    obj.fg = fg or gpu.getForeground()
    obj.bg = bg or gpu.getBackground()
    obj.wrappedText = {}
    obj.textChanged = false
    if #obj._text ~= 0 then obj.textChanged = true end

    return obj
end

function label:setText(_text) 
    self._text = _text 
    self.textChanged = true
end
function label:getText() return self._text end

--width needs to be set first
--this shouldnt be use anymore because i added measureHeight logic
--function label:getHeight()
--    local width = self:getWidth()
--    if not width then
--        string.format("Width wasnt set for label %s", self.id)
--    end
--    self.wrappedText = stru.tableWrap(self:getText(), width)
--    self:setHeight(#(self.wrappedText))
--    return self.h
--end

function label:measureHeight(w)
    if self.textChanged then
        self.wrappedText = stru.tableWrap(self._text, w) --recalculate wrappedText bc maybe the text changes since last time
        self.textChanged = false
    end
    return #self.wrappedText
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
        local paddedText = string.rep(" ", d) .. line .. string.rep(" ", w - (#line + d))
        fwrite(x, y, paddedText, fg, bg)
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
function progressBar:setValue(value) 
    if value >= self.min and value <= self.max then
        self.value = value 
    else
        print_error(string.format("Value at progress bar %s is out of bounds", self.id))
    end
end
function progressBar:getValue() return self.value end
function progressBar:incrementValue(i) 
    local i = i or 1
    self:setValue(self.value + i)
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

hSpacer = setmetatable({}, singleElementContainer)
hSpacer.__index = hSpacer

--class that adds horizontal space to an object
function hSpacer.new(id, spacing, base)
    local fg = fg or gpu.getForeground()
    local bg = bg or gpu.getBackground()

    local obj = setmetatable({}, hSpacer)
    obj.id = id or ""
    obj.spacing = spacing or 0

    obj:setForeground(fg)
    obj:setBackground(bg)
    obj:setBase(base)

    return obj
end

function hSpacer:setSpacing(value) self.spacing = value end
function hSpacer:getSpacing() return self.spacing end

function hSpacer:draw()
    --base and colors
    local base = self:getBase()
    local spacing = self:getSpacing()
    local fg = self:getForeground()
    local bg = self:getBackground()
    
    --coordinates
    local x = self:getX()
    local y = self:getY()
    local w = self:getWidth()
    local h = self:getHeight()
    local right = x + w - 1
    local bottom = y + h - 1

    --draw base
    if base then
        base:setX(x + spacing)
        base:setY(y)
        base:setWidth(w - spacing * 2)
        base:setHeight(h)
        base:setForeground(fg)
        base:setBackground(bg)
        base:draw()
    end
end

function hSpacer:measureHeight(w)
    return self.base:measureHeight(w)
end

button = setmetatable({}, label)
button.__index = button

--when you press the button a touch return event that you specify will be pushed into the queue
function button.new(id, h, _text, centered, _event, textColor, buttonColor)
    if centered == nil then centered = true end

    local obj = label.new(id, _text, centered, textColor, buttonColor)
    setmetatable(obj, button)
    obj:setHeight(h)

    --they are swapped on purpose
    obj.fg = textColor or gpu.getBackground()
    obj.bg = buttonColor or gpu.getForeground()

    obj:setTouchReturnEvent(_event)

    return obj
end

function button:measureHeight(w)
    local h = self.h
    if self.textChanged then
        self.wrappedText = stru.tableWrap(self._text, w) --recalculate wrappedText bc maybe the text changes since last time
        self.textChanged = false
    end
    if not h then h = #self.wrappedText
    elseif #self.wrappedText > h then print_error(string.format("Specified height for button %s is too small for the given text", self.id)) end
    return h
end

function button:draw()
    --colors
    local fg = self:getForeground()
    local bg = self:getBackground()
    
    --coordinates
    local x = self:getX()
    local y = self:getY()
    local w = self:getWidth()
    local h = self:getHeight()
    local botEmpty = (h - #self.wrappedText) // 2
    local topEmpty = h - #self.wrappedText - botEmpty

    for i = y, y + topEmpty - 1 do fwrite(x, i, string.rep(" ", w), fg, bg) end

    y = y + topEmpty
    for i, line in ipairs(self.wrappedText) do
        local d = 0
        if self.centered then d = (w - string.len(line)) // 2 end
        local paddedText = string.rep(" ", d) .. line .. string.rep(" ", w - (#line + d))
        fwrite(x, y, paddedText, fg, bg)
        y = y + 1
    end

    for i = y, y + botEmpty - 1 do fwrite(x, i, string.rep(" ", w), fg, bg) end
end

local local_root = nil

function rootEventWrapper(...)
    root:handleEvent(...)
end

function screenInit(root)
    if not root then print_error("You need to specify a root object") end

    local_root = root
    local w, h = gpu.getResolution()
    root:setX(1)
    root:setY(1)
    root:setWidth(w)
    root:setHeight(h)

    event.listen("touch", rootEventWrapper)
end

function screenClean()
    term.clear()
    event.ignore("touch", rootEventWrapper)
    rootEventWrapper = function() return false end
end

function screenDraw()
    root:draw()
end

return {
    fwrite = fwrite,
    baseElement = baseElement,
    containerElement = containerElement,
    linearLayout = linearLayout,
    splitLayout = splitLayout,
    singleElementContainer = singleElementContainer,
    frame = frame,
    label = label,
    space = space,
    progressBar = progressBar,
    hSpacer = hSpacer,
    button = button,
    screenInit = screenInit,
    screenClean = screenClean,
    screenDraw = screenDraw,
}
