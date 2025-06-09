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

<<<<<<< HEAD
--- Represents a generic UI element.
--- @class baseElement
--- @field id string|nil The ID of the element
--- @field x number X position
--- @field y number Y position
--- @field w number Width
--- @field h number Height
--- @field fg number|nil Foreground color
--- @field bg number|nil Background color
--- @field TRE string|nil Touch return event name
baseElement = {id, x=1, y=1, w=1, h=1, fg, bg, TRE}
baseElement.__index = baseElement

--- Creates a new base UI element.
--- @param id string Element ID
--- @return baseElement
=======
--baseElement class - abstract, has basic fields
baseElement = {id, x=1, y=1, w=1, h=1, fg, bg, TRE}
baseElement.__index = baseElement

>>>>>>> 6b5f860f9e18993e80e3918816bd41f50a16b961
function baseElement.new(id)
    local obj = setmetatable({}, baseElement)
    obj.id = id
    return obj
end

<<<<<<< HEAD
--- Sets the X coordinate.
--- @param x number
function baseElement:setX(x)
    self.x = x
end
--- Sets the Y coordinate.
--- @param y number
function baseElement:setY(y) self.y = y end
--- Sets the Width.
--- @param w number
function baseElement:setWidth(w) self.w = w end
--- Sets the Height.
--- @param h number
function baseElement:setHeight(h) self.h = h end
--- Sets the Foreground (hex color).
--- @param fg number
function baseElement:setForeground(fg) self.fg = fg end
--- Sets the Background (hex color).
--- @param bg number
function baseElement:setBackground(bg) self.bg = bg end

--- Returns X
--- @return X
function baseElement:getX() return self.x end
--- Returns Y
--- @return Y
function baseElement:getY() return self.y end
--- Returns Width
--- @return Width
function baseElement:getWidth() return self.w end
--- Returns Height
--- @return Height
function baseElement:getHeight() return self.h end
--- Returns Foreground (hex color)
--- @return Foreground
function baseElement:getForeground() return self.fg end
--- Returns Background (hex color)
--- @return Background
function baseElement:getBackground() return self.bg end
--- Returns Id
--- @return Id
function baseElement:getId() return self.id end

--- Handles events + Touch Return Event logic
=======
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
>>>>>>> 6b5f860f9e18993e80e3918816bd41f50a16b961
function baseElement:handleEvent(...)
    local name, _, x, y = ...
    if name == "touch" and type(self.TRE) == "string" then
        event.push(self.TRE, self.id, x, y)
    end
end

<<<<<<< HEAD
--- Checks if x, y are in the box of the element
--- @param x number
--- @param y number
=======
>>>>>>> 6b5f860f9e18993e80e3918816bd41f50a16b961
function baseElement:collide(x, y)
    return x >= self.x and x <= self.x + self.w - 1 and
        y >= self.y and y <= self.y + self.h - 1
end
<<<<<<< HEAD
--- Sets the Touch Return Event
--- @param name string
=======

>>>>>>> 6b5f860f9e18993e80e3918816bd41f50a16b961
function baseElement:setTouchReturnEvent(name)
    if type(name) == "string" then
        self.TRE = name
    end
end

<<<<<<< HEAD
--- Gets the minimum height required to draw the object
--- @param w number Width constraint
--- @return number Height
=======
>>>>>>> 6b5f860f9e18993e80e3918816bd41f50a16b961
function baseElement:measureHeight(w)
    return self.h
end

<<<<<<< HEAD
--- A UI element that can contain children.
--- @class containerElement : baseElement
--- @field children List of child elements
containerElement = setmetatable({}, baseElement)
containerElement.__index = containerElement

--- Creates a new container UI element
--- @param id string
=======
--container element class - baseElement with childrens table
containerElement = setmetatable({}, baseElement)
containerElement.__index = containerElement

>>>>>>> 6b5f860f9e18993e80e3918816bd41f50a16b961
function containerElement.new(id)
    local obj = setmetatable({}, containerElement)
    obj.id = id
    obj.children = {}

    return obj
end

<<<<<<< HEAD
--- Adds a child to the container
--- @param table Child to add
=======
>>>>>>> 6b5f860f9e18993e80e3918816bd41f50a16b961
function containerElement:addChild(child)
    table.insert(self.children, child)
end

<<<<<<< HEAD
--- Removes a child from the container
--- @param table Child to remove
=======
>>>>>>> 6b5f860f9e18993e80e3918816bd41f50a16b961
function containerElement:removeChild(id)
    for i, child in ipairs(self.children) do
        if child.id == id then 
            table.remove(self.children, i) 
            break
        end
    end
end

<<<<<<< HEAD
--- Finds a child in the container
--- @param table Child to findChild
--- @return child table child if found
=======
>>>>>>> 6b5f860f9e18993e80e3918816bd41f50a16b961
function containerElement:findChild(id)
    for i, child in ipairs(self.children) do
        if child.id == id then return child end
    end
end

<<<<<<< HEAD
--- Returns a table with all children
--- @return children table Children table
=======
>>>>>>> 6b5f860f9e18993e80e3918816bd41f50a16b961
function containerElement:getChildren()
    return self.children
end

<<<<<<< HEAD
--- Clears all children from the children table
=======
>>>>>>> 6b5f860f9e18993e80e3918816bd41f50a16b961
function containerElement:clearChildren()
    for i, child in ipairs(self.children) do
        self.children[i] = nil
    end
end

<<<<<<< HEAD
--- Propagates an event to its children
=======
>>>>>>> 6b5f860f9e18993e80e3918816bd41f50a16b961
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

<<<<<<< HEAD
--- Handles an event by calling propagateEvent, also checks for touch return event
=======
>>>>>>> 6b5f860f9e18993e80e3918816bd41f50a16b961
function containerElement:handleEvent(...)
    local name, _, x, y = ...
    if name == "touch" and type(self.TRE) == "string" then
        event.push(self.TRE, self.id, x, y)
    end
    self:propagateEvent(...)
end

<<<<<<< HEAD
--- Represents an UI linear layout (elements are drawn linearly next to eatchother)
--- @class linearLayout : containerElement
linearLayout = setmetatable({}, containerElement)
linearLayout.__index = linearLayout

--- Creates a new linear layout ui element
--- @param id string
--- @param gap number Gap between elements, default 0
--- @return linearLayout
=======
linearLayout = setmetatable({}, containerElement)
linearLayout.__index = linearLayout

--layout drawn without splitting children, only supports vertical layout bc why would you need a horizontal one
>>>>>>> 6b5f860f9e18993e80e3918816bd41f50a16b961
function linearLayout.new(id, gap)
    local gap = gap or 0
    local obj = containerElement.new(id)
    setmetatable(obj, linearLayout)

    obj.gap = gap

    return obj
end

<<<<<<< HEAD
--- Returns the gap
--- @return number
function linearLayout:getGap() return self.gap end
--- Sets the gap
--- @param gap number
function linearLayout:setGap(gap) self.gap = gap end 

--- Draws the linear layout element onto the screen, position and size have to be set before
=======
function linearLayout:getGap() return self.gap end
function linearLayout:setGap(gap) self.gap = gap end 

>>>>>>> 6b5f860f9e18993e80e3918816bd41f50a16b961
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

<<<<<<< HEAD
--- Gets the minimum height required to draw the object
--- @param w number Width constraint
--- @return number Height
=======
>>>>>>> 6b5f860f9e18993e80e3918816bd41f50a16b961
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

<<<<<<< HEAD
--- Represents an UI split layout (eatch element gets an equal amount of space)
--- @class splitLayout : containerElement
splitLayout = setmetatable({}, containerElement)
splitLayout.__index = splitLayout

--- Creates a new split layout UI element
--- @param id string
--- @param mode string Mode can be "vertical" or "horizontal"
--- @param gap number Gap between elements, default 0
--- @return splitLayout
=======
splitLayout = setmetatable({}, containerElement)
splitLayout.__index = splitLayout

--split layout, splits space equally to all children, mode is "vertical" or "horizontal"
>>>>>>> 6b5f860f9e18993e80e3918816bd41f50a16b961
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

<<<<<<< HEAD
--- Returns the gap
--- @return Gap
function splitLayout:getGap() return self.gap end
--- Sets the gap
--- @param gap number
function splitLayout:setGap(gap) self.gap = gap end
--- Returns the mode
--- @return Mode
function splitLayout:getMode() return self.mode end
--- Sets the Mode
--- @param mode string
function splitLayout:setMode(mode) self.mode = mode end

--- Draws the split layout element onto the screen, position and size have to be set before
=======
function splitLayout:getGap() return self.gap end
function splitLayout:setGap(gap) self.gap = gap end
function splitLayout:getMode() return self.mode end
function splitLayout:setMode(mode) self.mode = mode end

>>>>>>> 6b5f860f9e18993e80e3918816bd41f50a16b961
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

<<<<<<< HEAD
--- Abstract class to hold only one element
--- @class singleElementContainer : baseElement
--- @field base table Its base
=======
--abstract class to hold only one element
>>>>>>> 6b5f860f9e18993e80e3918816bd41f50a16b961
singleElementContainer = setmetatable({}, baseElement)
singleElementContainer.__index = singleElementContainer

singleElementContainer.base = nil

<<<<<<< HEAD
--- Sets the base of the container
--- @param base table Another element
=======
-- :P
>>>>>>> 6b5f860f9e18993e80e3918816bd41f50a16b961
function singleElementContainer:setBase(base) 
    if type(base) ~= "table" then return end
    if not self.id and type(base.id) == "string" then
        self.id = base.id
    end
    self.base = base
end
<<<<<<< HEAD

--- Removes the base of the container if it has one
function singleElementContainer:removeBase()
    self.base = nil
end

--- Returns the base of the container
--- @return base table
function singleElementContainer:getBase() return self.base end

--- Handles and event by sending it to the base
=======
function singleElementContainer:removeBase()
    self.base = nil
end
function singleElementContainer:getBase() return self.base end
>>>>>>> 6b5f860f9e18993e80e3918816bd41f50a16b961
function singleElementContainer:handleEvent(...)
    local _, _, x, y = ...
    if self.base then
        if self.base:collide(x, y) then self.base:handleEvent(...) end
    end
end
<<<<<<< HEAD

--- Checks if the base is a container (has a children table)
=======
>>>>>>> 6b5f860f9e18993e80e3918816bd41f50a16b961
function singleElementContainer:isBaseContainer()
    if not self.base then return false end
    if not self.base.children then return false end
    return true
end
<<<<<<< HEAD

--- Adds a child to the base if the base is a container, if not throws error
--- @param child table
=======
>>>>>>> 6b5f860f9e18993e80e3918816bd41f50a16b961
function singleElementContainer:addChild(child)
    if not self:isBaseContainer() then print_error(string.format("Container %s's base is not a container!", self.id)) end
    self.base:addChild(child)
end
<<<<<<< HEAD

--- Removes a child by id from the base if the base is a container, if not throws error
--- @param id string
=======
>>>>>>> 6b5f860f9e18993e80e3918816bd41f50a16b961
function singleElementContainer:removeChild(id)
    if not self:isBaseContainer() then print_error(string.format("Container %s's base is not a container!", self.id)) end
    self.base:removeChild(id)
end
<<<<<<< HEAD

--- Find a child by id from the base if the base is a container, if not throws error
--- @param id string
--- @return child
=======
>>>>>>> 6b5f860f9e18993e80e3918816bd41f50a16b961
function singleElementContainer:findChild(id)
    if not self:isBaseContainer() then print_error(string.format("Container %s's base is not a container!", self.id)) end
    return self.base:findChild(id)
end
<<<<<<< HEAD

--- Returns the children table if the base is a container, if not throws error
--- @return children table
=======
>>>>>>> 6b5f860f9e18993e80e3918816bd41f50a16b961
function singleElementContainer:getChildren()
    if not self:isBaseContainer() then print_error(string.format("Container %s's base is not a container!", self.id)) end
    return self.base:getChildren()
end
<<<<<<< HEAD

--- Clears the children table if the base is a container, if not throws error
=======
>>>>>>> 6b5f860f9e18993e80e3918816bd41f50a16b961
function singleElementContainer:clearChildren()
    if not self:isBaseContainer() then print_error(string.format("Container %s's base is not a container!", self.id)) end
    self.base:clearChildren()
end

<<<<<<< HEAD
--- Single element container to draw a nice frame around an object
--- @class frame : singleElementContainer
frame = setmetatable({}, singleElementContainer)
frame.__index = frame

--- Creates a new frame container, can directly take a based
--- @param id string
--- @param base table The base
--- @param fg number Foreground color (hex)
--- @param bg number Background color (hex)
--- @return frame
=======
--SEC doesnt get a measureHeight override but the classes that derive from it should have one
--not always tho for example frame also doent need one

frame = setmetatable({}, singleElementContainer)
frame.__index = frame

--object that holds a base, draws a frame around it and them draws the base
--you need to create the base by yourself and give it to the frame by setBase or by the constructor
>>>>>>> 6b5f860f9e18993e80e3918816bd41f50a16b961
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

<<<<<<< HEAD
--- Draws the frame onto the screen, position and size have to be set before
=======
>>>>>>> 6b5f860f9e18993e80e3918816bd41f50a16b961
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

<<<<<<< HEAD
--- UI element that draws text to the screen and wrapps its around the width
--- @class label : baseElement
label = setmetatable({}, baseElement)
label.__index = label

--- Creates a new label
--- @param id string
--- @param _text string Text to be written
--- @param centered boolean If the text should be centered
--- @param fg number Foreground color (hex)
--- @param bg number Background color (hex)
--- @return label
=======
label = setmetatable({}, baseElement)
label.__index = label

--should only be used in linear layout
-- to do: add a textChanged flag so that i dont recalculate wrappedText everytime
>>>>>>> 6b5f860f9e18993e80e3918816bd41f50a16b961
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

<<<<<<< HEAD
--- Sets the text of the label
--- @param _text string
=======
>>>>>>> 6b5f860f9e18993e80e3918816bd41f50a16b961
function label:setText(_text) 
    self._text = _text 
    self.textChanged = true
end
<<<<<<< HEAD

--- Returs the text of the label
--- @return string
function label:getText() return self._text end

=======
function label:getText() return self._text end

--width needs to be set first
>>>>>>> 6b5f860f9e18993e80e3918816bd41f50a16b961
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

<<<<<<< HEAD
--- Gets the minimum height required to draw the text wrapped into the width
--- @param w number Width
--- @return number
=======
>>>>>>> 6b5f860f9e18993e80e3918816bd41f50a16b961
function label:measureHeight(w)
    if self.textChanged then
        self.wrappedText = stru.tableWrap(self._text, w) --recalculate wrappedText bc maybe the text changes since last time
        self.textChanged = false
    end
    return #self.wrappedText
end

<<<<<<< HEAD
--- Draws the width, measureHeight has to be called before to create wrappedText
=======
>>>>>>> 6b5f860f9e18993e80e3918816bd41f50a16b961
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

<<<<<<< HEAD
--- UI element that just adds an empty space, doesnt draw it just skips the license
--- @class space : baseElement
space = setmetatable({}, baseElement)
space.__index = space

--- Creates a new space
--- @param id string 
--- @param height number Height, how many lines to skip
--- @return space
=======
space = setmetatable({}, baseElement)
space.__index = space

>>>>>>> 6b5f860f9e18993e80e3918816bd41f50a16b961
function space.new(id, height)
    local obj = setmetatable({}, space)
    obj.id = id or nil
    obj.h = height or 1

    return obj
end

<<<<<<< HEAD
--- Draws the space, doesnt actually do anything :)
=======
>>>>>>> 6b5f860f9e18993e80e3918816bd41f50a16b961
function space:draw()
    --the function doesnt do anything :))
end

<<<<<<< HEAD
--- UI element that draws a working progress bar, the value has to be set manually
--- @class progressBar : baseElement
--- @field min number Minimum value
--- @field max number Maximum value
--- @field value number The value the bar is at
progressBar = setmetatable({}, baseElement)
progressBar.__index = progressBar

--- Creates a new progress bar
--- @param id string
--- @param min number Minimum value
--- @param max number Maximum value
--- @param fg number Foreground color (hex)
--- @param bg number Background color (hex), by default 0x505050
--- @return progressBar
=======
progressBar = setmetatable({}, baseElement)
progressBar.__index = progressBar

>>>>>>> 6b5f860f9e18993e80e3918816bd41f50a16b961
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

<<<<<<< HEAD
--- Sets the minimum
--- @param min number Minimum value
function progressBar:setMin(min) self.min = min end

--- Returns the minimum
--- @return number
function progressBar:getMin() return self.min end

--- Sets the maximum
--- @param min number Maximum value
function progressBar:setMax(max) self.max = max end

--- Returns the maximum
--- @return number
function progressBar:getMax() return self.max end

--- Sets the value, throws error if value is out of bounds (may not a good idea whatever)
--- @param min number The value the progress bar is at
=======
function progressBar:setMin(min) self.min = min end
function progressBar:getMin() return self.min end
function progressBar:setMax(max) self.max = max end
function progressBar:getMax() return self.max end
>>>>>>> 6b5f860f9e18993e80e3918816bd41f50a16b961
function progressBar:setValue(value) 
    if value >= self.min and value <= self.max then
        self.value = value 
    else
        print_error(string.format("Value at progress bar %s is out of bounds", self.id))
    end
end
<<<<<<< HEAD

--- Returns the value
--- @return number
function progressBar:getValue() return self.value end

--- Increments the value by i, not recommended
--- @param i number how much to increment
=======
function progressBar:getValue() return self.value end
>>>>>>> 6b5f860f9e18993e80e3918816bd41f50a16b961
function progressBar:incrementValue(i) 
    local i = i or 1
    self:setValue(self.value + i)
end

<<<<<<< HEAD
--- Draws the progress bar onto the screen
=======
>>>>>>> 6b5f860f9e18993e80e3918816bd41f50a16b961
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

<<<<<<< HEAD
--- Container that takes an element and adds horizontal space You need to specify a root object
--- @field spacing number The space to add
hSpacer = setmetatable({}, singleElementContainer)
hSpacer.__index = hSpacer

--- Creates a new hSpacer with the base
--- @field id string
--- @field spacing number Spacing to add
--- @field base table Element to add space to
=======
hSpacer = setmetatable({}, singleElementContainer)
hSpacer.__index = hSpacer

--class that adds horizontal space to an object
>>>>>>> 6b5f860f9e18993e80e3918816bd41f50a16b961
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

<<<<<<< HEAD
--- Sets the spacing
--- @param value number Spacing
function hSpacer:setSpacing(value) self.spacing = value end

--- Returns the spacing
--- @returns number
function hSpacer:getSpacing() return self.spacing end

--- Draws the base with horizontal space
=======
function hSpacer:setSpacing(value) self.spacing = value end
function hSpacer:getSpacing() return self.spacing end

>>>>>>> 6b5f860f9e18993e80e3918816bd41f50a16b961
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

<<<<<<< HEAD
--- Gets the minimum height required to draw the text wrapped into the width
--- @param w number Width
--- @return number
=======
>>>>>>> 6b5f860f9e18993e80e3918816bd41f50a16b961
function hSpacer:measureHeight(w)
    return self.base:measureHeight(w)
end

<<<<<<< HEAD
--- Button UI element, if pressed will send the Touch Return Event in the event queue (tbe not in the constructor)
--- @class button : label
button = setmetatable({}, label)
button.__index = button

--- Creates a new button, _event = TRE
--- @param id string
--- @param h number Height
--- @param _text string Text of the button
--- @param centered boolean If the text should be centered
--- @param _event string The touch return event, if you press the button this event will be pushed into the event queue
--- @param textColor number Color of the text (hex value)
--- @param buttonColor number Color of the button (hex value)
=======
button = setmetatable({}, label)
button.__index = button

--when you press the button a touch return event that you specify will be pushed into the queue
>>>>>>> 6b5f860f9e18993e80e3918816bd41f50a16b961
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

<<<<<<< HEAD
--- Gets the minimum height required to draw the text wrapped into the width
--- @param w number Width
--- @return number
=======
>>>>>>> 6b5f860f9e18993e80e3918816bd41f50a16b961
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

<<<<<<< HEAD
--- Draws the button
=======
>>>>>>> 6b5f860f9e18993e80e3918816bd41f50a16b961
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

<<<<<<< HEAD
--- A wrapper class to simplify the root drawing process
--- @class screen
--- @field root table The root of the screen
--- @field touchHandler function Workaround for the stupid OpenComputers event system
screen = {
    root = nil,
    touchHandler = nil,
}
screen.__index = screen

--- Creates a new screen, you need to specify a root
--- @param root table The root element
--- @return screen
function screen.new(root)
    local obj = {root = nil}
    setmetatable(obj, screen)
    obj.root = root

    return obj
end

--- This function returns another function that is the handle for the "touch" event
function screen:functionWrapper()
    local this = self
    return function(...)
        this.root:handleEvent(...)
    end
end

--- Initiates the screen, sets position and size for the root element and set the "touch" event listener
function screen:init()
    if not self.root then print_error("You need to specify a root object") end

=======
local local_root = nil

function rootEventWrapper(...)
    root:handleEvent(...)
end

function screenInit(root)
    if not root then print_error("You need to specify a root object") end

    local_root = root
>>>>>>> 6b5f860f9e18993e80e3918816bd41f50a16b961
    local w, h = gpu.getResolution()
    root:setX(1)
    root:setY(1)
    root:setWidth(w)
    root:setHeight(h)

<<<<<<< HEAD
    self.touchHandler = self:functionWrapper()
    event.listen("touch", self.touchHandler)
end

--- Calls term.clear() and removes the listener
function screen:clean()
    term.clear()
    event.ignore("touch", self.touchHandler)
    self.rootEventWrapper = function() return false end
end 

--- Draws the root element onto the screen
function screen:draw()
    self.root:draw()
end

--- LIB ---
=======
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

>>>>>>> 6b5f860f9e18993e80e3918816bd41f50a16b961
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
<<<<<<< HEAD
    screen = screen,
}
=======
    screenInit = screenInit,
    screenClean = screenClean,
    screenDraw = screenDraw,
}
>>>>>>> 6b5f860f9e18993e80e3918816bd41f50a16b961
