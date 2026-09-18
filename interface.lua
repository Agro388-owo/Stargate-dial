-- ========================================================
-- PERIPHERAL & INTERFACE DISPLAY ENGINE MODULE
-- ========================================================
local db = require("database")
local M = {}

M.sg = peripheral.find("advanced_crystal_interface") 
    or peripheral.find("crystal_interface") 
    or peripheral.find("basic_interface") 
    or peripheral.find("stargate_interface")

M.monitor = peripheral.find("monitor")

if not M.sg then
    error("Error: Stargate Interface missing! Check your wired modems.")
end

function M.updateMonitor(forcedStatus)
    if not M.monitor then return end
    M.monitor.clear()
    M.monitor.setTextScale(1)
    
    M.monitor.setCursorPos(1, 1)
    M.monitor.write("===============================")
    M.monitor.setCursorPos(1, 2)
    M.monitor.write("      SGC CONTROL PANEL        ")
    M.monitor.setCursorPos(1, 3)
    M.monitor.write("===============================")
    
    local currentAddress = "NONE"
    if M.sg.getRecentAddress then
        local gateAddressData = M.sg.getRecentAddress()
        if gateAddressData and #gateAddressData > 0 then
            currentAddress = db.getAddressString(gateAddressData)
        end
    end
    
    M.monitor.setCursorPos(1, 5)
    M.monitor.write("Target Addr: " .. currentAddress)
    
    M.monitor.setCursorPos(1, 7)
    M.monitor.write("System Status:")
    M.monitor.setCursorPos(1, 8)
    
    if forcedStatus then
        M.monitor.write("> " .. forcedStatus)
    elseif M.sg.isStargateConnected and M.sg.isStargateConnected() then
        M.monitor.write("> WORMHOLE ESTABLISHED")
    elseif currentAddress ~= "NONE" then
        M.monitor.write("> INCOMING CONNECTION DETECTED")
    else
        M.monitor.write("> SYSTEM READY")
    end
    
    M.monitor.setCursorPos(1, 10)
    local irisState = "NOT INSTALLED"
    
    if M.sg.hasIris and M.sg.hasIris() then
        if M.sg.getIrisStatus then
            irisState = tostring(M.sg.getIrisStatus()):upper()
        elseif M.sg.isIrisClosed then
            local success, closed = pcall(M.sg.isIrisClosed)
            if success then irisState = closed and "CLOSED" or "OPEN" end
        else
            irisState = "OPEN / INSTALLED"
        end
    else
        if M.sg.getIrisStatus and tostring(M.sg.getIrisStatus()) ~= "N/A" and tostring(M.sg.getIrisStatus()) ~= "NONE" then
            irisState = tostring(M.sg.getIrisStatus()):upper()
        elseif M.sg.isIrisClosed then
            local success, closed = pcall(M.sg.isIrisClosed)
            if success then irisState = closed and "CLOSED" or "OPEN" end
        end
    end
    M.monitor.write("Iris State: " .. irisState)
end

function M.dialAddress(addressName, symbols)
    term.clear()
    term.setCursorPos(1, 1)
    print("Initiating sequence for: " .. addressName)
    print("Full Address Sequence: " .. db.getAddressString(symbols))
    db.logAction("DIAL STARTED: " .. addressName .. " (" .. db.getAddressString(symbols) .. ")")
    
    for i, symbol in ipairs(symbols) do
        local statusMsg = "Dialing Chevron " .. i .. "/" .. #symbols .. " -> [" .. symbol .. "]"
        print(statusMsg)
        M.updateMonitor(statusMsg)
        
        local baselineChevrons = 0
        if M.sg.getChevronsEngaged then baselineChevrons = M.sg.getChevronsEngaged() end
        
        local success, err = M.sg.engageSymbol(symbol, false)
        if not success then
            local failMsg = "Failed at chevron " .. i .. ": " .. tostring(err)
            print(failMsg)
            db.logAction(failMsg)
            M.updateMonitor("DIAL ERROR: CHEVRON " .. i)
            sleep(2)
            return false
        end
        
        if M.sg.getChevronsEngaged then
            local currentChevrons = M.sg.getChevronsEngaged()
            while currentChevrons <= baselineChevrons do
                sleep(0.1)
                currentChevrons = M.sg.getChevronsEngaged()
                if M.sg.getGateStatus and M.sg.getGateStatus() == "IDLE" and currentChevrons == 0 then
                    print("Dial aborted by system framework.")
                    return false
                end
            end
            print("Chevron " .. i .. " Encoded successfully!")
        else
            sleep(1.5)
        end
    end
    
    print("Establishing event horizon...")
    M.updateMonitor("ESTABLISHING WORMHOLE...")
    sleep(1.5)
    
    if M.sg.isStargateConnected and M.sg.isStargateConnected() then
        print("Wormhole established successfully!")
        db.logAction("CONNECTION SUCCESSFUL: " .. addressName)
        M.updateMonitor("WORMHOLE ESTABLISHED")
    else
        print("Gate failed to open. Check power / address values.")
        db.logAction("CONNECTION FAILED (Invalid combo or dead node grid)")
        M.updateMonitor("CONNECTION FAILED")
    end
    sleep(2)
end

return M
