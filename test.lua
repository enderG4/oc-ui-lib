event = require("event")
stru = require("stringutils")

event.push("test", "arg", "arg2")

while true do
    name, _, x, y = event.pull()
    if name == "interrupted" then break end
    print(name, x, y)
end
