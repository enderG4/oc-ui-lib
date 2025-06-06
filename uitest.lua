local component = require("component")
local gpu = component.gpu
local term = require("term")

package.loaded["ui_lib"] = nil -- for debug !!!
local ui = require("ui_lib")

--main code
gpu.setResolution(50,18)
w, h = gpu.getResolution()
term.clear()

split1 = ui.splitLayout.new("split1", "vertical")
    reactor1 = ui.linearLayout.new("R1")    
    reactor_frame = ui.frame.new("Reactor 1", reactor1)
        reactor1:addChild(ui.space.new())
        reactor1:addChild(ui.label.new(_, "Reactor 1 has no problems so far", true, 0x505050))
    split1:addChild(reactor_frame)
    split1:addChild(ui.frame.new("Reactor 2"))
    split1:addChild(ui.frame.new("Reactor 3", _, 0xbf8d04))
split2 = splitLayout.new("split2", "vertical")
    reactor4 = ui.linearLayout.new("R4")
    pb_r4 = ui.progressBar.new(_, 0, 100)
        reactor4:addChild(ui.label.new(_, "Progress bar:"))
        reactor4:addChild(pb_r4)
    split2:addChild(ui.frame.new("Reactor 4", reactor4))
    split2:addChild(ui.frame.new("Reactor 5"))
    split2:addChild(ui.frame.new("Reactor 6", _, 0xAA336A))

root = ui.splitLayout.new("root", "horizontal")
    root:addChild(split1)
    root:addChild(split2)
    root:setX(1)
    root:setY(1)
    root:setWidth(w)
    root:setHeight(h)

for v = 0, 10 do
    root:draw()
    os.sleep(0.2)
    pb_r4:incrementValue(10)
end

--os.sleep(20)




