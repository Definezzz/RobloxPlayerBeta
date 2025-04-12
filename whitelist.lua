local base64 = require("gamesense/base64")
local http = require('gamesense/http')

local whitelist = {"1742785323"}
local ffi = require("ffi")

local function getObfuscatedHWID()
    local type2 = ffi.typeof("void***")
    local interface = client.create_interface("filesystem_stdio.dll", "VBaseFileSystem011")
    local system10 = ffi.cast(type2, interface)
    local gethwid = ffi.cast("long(__thiscall*)(void*, const char*, const char*)", system10[0][13])
    local filecheck = "C:\\Windows\\Setup\\State\\State.ini"  -- Change this as necessary
    local hwid = gethwid(system10, filecheck, "olympia")
    return tostring(hwid)
end
print(getObfuscatedHWID())
print("this is ur hwid send it to the owner if u wanna be whitelisted.")
local hwid = getObfuscatedHWID()

-- Check if HWID is whitelisted
local isWhitelisted = false
for _, id in ipairs(whitelist) do
    if hwid == id then
        isWhitelisted = true
        break
    end
end
print("Checking if HWID Exist...")
if isWhitelisted then
    local link = "https://raw.githubusercontent.com/Definezzz/RobloxPlayerBeta/refs/heads/main/erased.lua"
    http.get(link, function(success, response)
        if not success then
            print('Failed to fetch source URL')
            return
        end
    
        local data = response.body
        local chunk, err = load(data)
    
        if chunk then
            chunk()
        else
            print('Failed to load chunk: ' .. err)
        end
    end)
else
    print("HWID isn't in our database.")
end
