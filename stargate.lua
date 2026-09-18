-- ========================================================
-- SGC FRONTEND CONTROL PANEL & EXECUTABLE LOOP
-- ========================================================
local db = require("database")
local ui = require("interface")

local addresses = db.loadAddresses()
ui.updateMonitor(nil)

while true do
    term.clear()
    term.setCursorPos(1, 1)
    print("=== STARGATE SGC SYSTEM ===")
    print("1. Dial Saved Address")
    print("2. Manual Dial Input (Format: -26-6-14-31-11-29-)")
    print("3. Save New Address to Memory")
    print("4. Close Wormhole (Disconnect)")
    print("5. Check Present Gate Address")
    print("6. [IRIS] Open Iris Shield")
    print("7. [IRIS] Close Iris Shield")
    print("8. Exit Program")
    write("\nSelect option: ")
    
    local timerID = os.startTimer(1)
    local event, param
    local userInputMode = true
    
    while userInputMode do
        event, param = os.pullEvent()
        if event == "timer" and param == timerID then
            ui.updateMonitor(nil) 
            timerID = os.startTimer(1)
        elseif event == "char" then
            local choice = param
            print(choice)
            
            if choice == "1" then
                term.clear()
                term.setCursorPos(1,1)
                print("=== SAVED ADDRESSES ===")
                local list = {}
                local idx = 1
                for name, _ in pairs(addresses) do
                    print(idx .. ". " .. name)
                    list[idx] = name
                    idx = idx + 1
                end
                
                if idx == 1 then
                    print("No addresses saved in memory.")
                    sleep(2)
                else
                    write("\nEnter address number: ")
                    local num = tonumber(read())
                    if num and list[num] then
                        local name = list[num]
                        ui.dialAddress(name, addresses[name])
                    else
                        print("Invalid selection.")
                        sleep(1.5)
                    end
                end
                userInputMode = false
                
            elseif choice == "2" then
                write("\nEnter address (e.g. -26-6-14-31-11-29-): ")
                local input = read()
                local symbols = db.parseInputString(input)
                if #symbols <= 1 then
                    print("Invalid input format detected.")
                    sleep(1.5)
                else
                    ui.dialAddress("Manual Input", symbols)
                end
                userInputMode = false
                
            elseif choice == "3" then
                write("\nEnter destination name: ")
                local name = read()
                write("Enter address (e.g. -26-6-14-31-11-29-): ")
                local input = read()
                local symbols = db.parseInputString(input)
                if #symbols <= 1 then
                    print("Invalid sequence. Address not saved.")
                else
                    addresses[name] = symbols
                    db.saveAddresses(addresses)
                    print("Address stored with auto Point-of-Origin (0) added!")
                end
                sleep(2)
                userInputMode = false
                
            elseif choice == "4" then
                if ui.sg.disconnectStargate then ui.sg.disconnectStargate()
                elseif ui.sg.disconnect then ui.sg.disconnect() end
                print("Closing the gate...")
                db.logAction("GATE CLOSED BY USER")
                ui.updateMonitor("GATE DISCONNECTED")
                sleep(2)
                userInputMode = false
                
            elseif choice == "5" then
                term.clear()
                term.setCursorPos(1, 1)
                print("=== PRESENT GATE ADDRESS ===")
                local localAddr = nil
                if ui.sg.getOwnAddress then localAddr = ui.sg.getOwnAddress()
                elseif ui.sg.getHomeAddress then localAddr = ui.sg.getHomeAddress()
                elseif ui.sg.getStargateAddress then localAddr = ui.sg.getStargateAddress() end
                
                if localAddr and #localAddr > 0 then
                    local formatted = db.getAddressString(localAddr)
                    print("\nYour Current Gate Address:\n" .. formatted)
                    db.logAction("CHECKED OWN ADDRESS: " .. formatted)
                    ui.updateMonitor("VIEWING LOCAL ADDR")
                else
                    print("\nCould not retrieve local address directly.")
                end
                print("\nPress Enter to return to menu...")
                read()
                userInputMode = false
                
            elseif choice == "6" then
                if ui.sg.openIris then
                    ui.sg.openIris()
                    print("Opening Iris Shield...")
                    ui.updateMonitor("OPENING IRIS...")
                end
                sleep(2)
                userInputMode = false
                
            elseif choice == "7" then
                if ui.sg.closeIris then
                    ui.sg.closeIris()
                    print("Closing Iris Shield...")
                    ui.updateMonitor("CLOSING IRIS...")
                end
                sleep(2)
                userInputMode = false
                
            elseif choice == "8" then
                return 
            end
        end
    end
    ui.updateMonitor(nil)
end
