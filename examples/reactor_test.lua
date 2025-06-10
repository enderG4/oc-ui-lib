component = require("component")
thread = require("thread")
event = require("event")
term = require("term")
ui = require("uilib")
gpu = component.gpu

--- Just connect up to 10 NuclearCraft reactors with oc cables to the computers 
--- and it will automatically add all of them to the UI  
--- Didnt use buttons and hSpacers in this example ill make another one for them


-- colors
local _frameColour = 0x00FFFF
local _textColour = 0xFFFFFF
local _barColours = {0x5703ff, 0x0396ff, 0xff0019, 0xff0062} -- every progressBar will take a random color from this table

-- functions
function getReactorTable()
    return {
        energyStored = 0,
        efficiency = 0,
        fuelTime = 0,
        fuelName = "",
        processTime = 1,
        isProcessing = false
    }
end

-- tables for threads to put data into
function setReactorInfo(_table, reactorHandle, delay)
    while true do
        _table.energyStored  = reactorHandle.getEnergyStored()
        _table.efficiency = reactorHandle.getEfficiency()
        _table.fuelTime = reactorHandle.getFissionFuelTime()
        _table.fuelName = reactorHandle.getFissionFuelName()
        _table.processTime = reactorHandle.getCurrentProcessTime()
        _table.isProcessing = reactorHandle.isProcessing()
        
        os.sleep(delay)
    end
end

-- for convinience
function mergeTables(t1, t2)
    local result = {}
    for _, v in pairs(t1) do table.insert(result, v) end
    for _, v in pairs(t2) do table.insert(result, v) end
    return result
end

-- also for convinience
local count = 1
function getReactorFrame(id, frameColour, textColour, progressBarColour)
    local id = id or string.format("Reactor %d", count)
    local colour = frameColour or gpu.getForeground()

    local _frame = ui.frame.new(id, ui.linearLayout.new(), colour)
    _frame:addChild(ui.space.new())
    _frame:addChild(ui.label.new("label", "Fuel:", textColour))
    _frame:addChild(ui.progressBar.new("progressBar", 0, 100, progressBarColour))

    count = count + 1
    return _frame
end

--reactor Handles
local CHECK_DELAY = 1
local DRAW_DELAY = 1

local proxyes = {}
for id, name in pairs(component.list("nc_fission_reactor")) do
    table.insert(proxyes, component.proxy(id))
end
if #proxyes > 10 then print_error("Max 10 Reactors") end

--UI setup
local split1 = ui.splitLayout.new("split1", "vertical")
local split2 = ui.splitLayout.new("split2", "vertical")

for i = 1, #proxyes // 2 do split1:addChild(getReactorFrame(_, _frameColour, _textColour, _barColours[math.random(#_barColours)])) end
for i = #proxyes // 2 + 1, #proxyes do split2:addChild(getReactorFrame(_, _frameColour, _textColour, _barColours[math.random(#_barColours)])) end

local frames = mergeTables(split1:getChildren(), split2:getChildren())
local threads = {}

--threads setup
for i, v in ipairs(frames) do
    v.reactorTable = getReactorTable()
    print("Creating thread: " .. i)
    table.insert(threads, thread.create(setReactorInfo, v.reactorTable, proxyes[i], CHECK_DELAY))
end

--UI drawing
local root = ui.splitLayout.new("root", "horizontal", 1)
    root:addChild(split1)
    root:addChild(split2)

local _screen = ui.screen.new(root)
_screen:init(57, 21)

term.clear()
print("Loading...")

--LOOP
while true do
    local name, id, x, y = event.pullMultiple(0.5)
    if name == "interrupted" then break
    elseif name ~= "key_up" and name ~= "key_down" then

        for i, v in ipairs(frames) do
            local pb = v:findChild("progressBar")
            local lb = v:findChild("label")

            local timeBuffer = v.reactorTable.fuelTime
            local processBuffer = v.reactorTable.processTime
            if timeBuffer == 0 then timeBuffer = 1 end
            local percent = processBuffer / timeBuffer * 100

            lb:setText(string.format("Fuel: %s  %.2f%%", v.reactorTable.fuelName, percent))
            pb:setValue(percent)
        end

        _screen:draw()
    end
end

--cleaning

_screen:clean()
for i, t in ipairs(threads) do t:kill() end
