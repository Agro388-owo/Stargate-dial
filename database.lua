-- ========================================================
-- DATABASE, LOGGING, & PARSER UTILITIES MODULE
-- ========================================================
local M = {}

M.ADDR_FILE = "stargate_addresses.txt"
M.LOG_FILE = "stargate_logs.txt"

function M.loadAddresses()
    if fs.exists(M.ADDR_FILE) then
        local f = fs.open(M.ADDR_FILE, "r")
        local data = f.readAll()
        f.close()
        return textutils.unserializeJSON(data) or {}
    end
    return {}
end

function M.logAction(message)
    local timestamp = os.date("%Y-%m-%d %H:%M:%S")
    local f = fs.open(M.LOG_FILE, "a")
    f.writeLine("[" .. timestamp .. "] " .. message)
    f.close()
end

function M.saveAddresses(addresses)
    local f = fs.open(M.ADDR_FILE, "w")
    f.write(textutils.serializeJSON(addresses))
    f.close()
end

function M.getAddressString(symbols)
    if not symbols or #symbols == 0 then return "NONE" end
    local str = "-"
    for _, s in ipairs(symbols) do str = str .. s .. "-" end
    return str
end

function M.parseInputString(inputStr)
    local symbols = {}
    for num in string.gmatch(inputStr, "(%d+)") do
        table.insert(symbols, tonumber(num))
    end
    if #symbols > 0 and symbols[#symbols] ~= 0 then
        table.insert(symbols, 0)
    end
    return symbols
end

return M
