local event = require("event")

-- Handler function for the "interrupted" event
local function onInterrupt()
  error("user interuption", 0)
end

-- Add the listener
event.listen("interrupted", onInterrupt)

while true do
    os.sleep(0.1)
end