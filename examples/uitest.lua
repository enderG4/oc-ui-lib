local component = require("component")
local gpu = component.gpu
local term = require("term")
local sides = require("sides")

package.loaded["uilib"] = nil
local ui = require("uilib")
local event = require("event")

--main code
gpu.setResolution(57,18)
local w, h = gpu.getResolution()

--gpu.setForeground(0x000000)
--gpu.setBackground(0xFFFFFF)

--term.clear()

local split1 = ui.splitLayout.new("split1", "vertical")
    reactor1 = ui.linearLayout.new("R1")    
    reactor_frame = ui.frame.new("Reactor 1", reactor1)
        reactor1:addChild(ui.space.new())
        reactor1:addChild(ui.label.new(_, "Reactor 1 has no problems so far", true, 0x505050))
    split1:addChild(reactor_frame)
    split1:addChild(ui.frame.new("Reactor 2"))
    split1:addChild(ui.frame.new("Reactor 3", _, 0xbf8d04))
local split2 = ui.splitLayout.new("split2", "vertical")
    reactor4 = ui.linearLayout.new("R4")
    pb_r4 = ui.progressBar.new(_, 0, 100, 0x04bf52)
        reactor4:addChild(ui.space.new())
        reactor4:addChild(ui.label.new(_, "Progress bar:"))
        reactor4:addChild(pb_r4)
    split2:addChild(ui.frame.new("Reactor 4", reactor4))
    split2:addChild(ui.frame.new("Reactor 5"))
    split2:addChild(ui.frame.new("Reactor 6", _, 0xAA336A))

local root = ui.splitLayout.new("root", "horizontal", 1)
    root:addChild(split1)
    root:addChild(split2)
    root:setX(1)
    root:setY(1)
    root:setWidth(w)
    root:setHeight(h)

local _screen = ui.screen.new(root)
_screen:init()

reactor4:setTouchReturnEvent("reactor_event")

term.clear()

while true do
    local name = event.pull(0.5)
    if name == "interrupted" then break end 
    if name == "reactor_event" then print("Reactor event detected!") end
    --if name == "touch" then print("wtf wtf") end

    _screen:draw()
end

_screen:clean()

--os.sleep(20)




