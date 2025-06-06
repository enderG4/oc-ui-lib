ui = require("ui_lib")
stru = require("stringutils")

lines = stru.tableWrap("test test test test", 6)

print(stru.tableToString(lines))