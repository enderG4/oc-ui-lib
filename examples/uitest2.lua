local component = require("component")
local gpu = component.gpu
local term = require("term")
local event = require("event")

local ui = require("uilib")

gpu.setResolution(57,18)
w, h = gpu.getResolution()

term.clear()

ui.baseElement()