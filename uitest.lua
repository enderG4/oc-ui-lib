local component = require("component")
local gpu = component.gpu
local term = require("term")

local ui = require("ui_lib")

--main code
gpu.setResolution(50,18)
w, h = gpu.getResolution()
term.clear()

split1 = ui.splitLayout.new("split1", "vertical")
    split1:addChild(ui.frame.new("Reactor 1"))
    split1:addChild(ui.frame.new("Reactor 2"))
    split1:addChild(ui.frame.new("Reactor 3"))
split2 = splitLayout.new("split2", "vertical")
    split2:addChild(ui.frame.new("Reactor 4"))
    split2:addChild(ui.frame.new("Reactor 5"))
    split2:addChild(ui.frame.new("Reactor 6", _, 0xAA336A))

root = ui.splitLayout.new("root", "horizontal")
    root:addChild(split1)
    root:addChild(split2)
    root:setX(1)
    root:setY(1)
    root:setWidth(w)
    root:setHeight(h)

root:draw()

--os.sleep(20)




