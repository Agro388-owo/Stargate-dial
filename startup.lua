-- ========================================================
-- SGC NETWORK AUTO-INITIALIZER & PERSISTENT DEPLOYER
-- ========================================================
local GITHUB_BASE = "https://githubusercontent.com"
local REQUIRED_FILES = { "database.lua", "interface.lua", "stargate.lua" }

print("=======================================")
print("     SGC BOOT INITIALIZATION SEED      ")
print("=======================================")

-- Verification Loop: Inspects block memory layout paths
local missingFiles = false
for _, filename in ipairs(REQUIRED_FILES) do
    if not fs.exists(filename) then
        print("Missing deployment signature: " .. filename)
        missingFiles = true
    end
end

-- Automated Fetch Module: Intercepts network loops if files are wiped
if missingFiles then
    print("\nConnecting to [Agro388-owo/Stargate-dial] repo...")
    if not http then
        error("CRITICAL ERROR: HTTP Network requests disabled on this server! Check server config.")
    end

    for _, filename in ipairs(REQUIRED_FILES) do
        local targetUrl = GITHUB_BASE .. filename
        print("Fetching node stream -> " .. filename)
        
        local response = http.get(targetUrl)
        if response then
            local file = fs.open(filename, "w")
            file.write(response.readAll())
            file.close()
            response.close()
            print("Successfully compiled: " .. filename)
        else
            error("WGET FAIL: Could not pull raw node bytes for " .. filename .. "\nVerify your GitHub branch/paths.")
        end
    end
    print("\nAll modular framework segments compiled safely.")
    sleep(1)
end

-- Execution Handshake: Automatically fires up your dialing array console dashboard
print("\nLaunching master dialing terminal matrix...")
sleep(0.5)

if fs.exists("stargate.lua") then
    shell.run("stargate.lua")
else
    print("Execution failure: stargate.lua main directory loop target vanished.")
end
