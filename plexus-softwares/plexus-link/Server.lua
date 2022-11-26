if not fs.isDir("\\files/") then
    fs.makeDir("\\files/")
end
shell.run("clear")
rednet.open("left")
local id
local message
if fs.exists("\\blocked.txt") then
    local file = fs.open("\\blocked.txt", "r")
    local blocked = file.readAll()
else
    blocked = ""
end
local function log(text, importance)
    local prevColor = term.getTextColor()
    if importance == 1 then
        term.setTextColor(1)
        print(text)
    end
    if importance == 2 then
        term.setTextColor(2)
        print(text)
    end
    if importance == 3 then
        term.setTextColor(16384)
        print(text)
    end
    term.setTextColor(prevColor)
    return 1
end
local function block(id)
    blocked = blocked.."+"..id
    if fs.exists("\\blocked.txt") then
        fs.delete("\\blocked.txt")
    end
    local file = fs.open("\\blocked.txt", "w")
    file.write(blocked)
    file.close()
end
local function checkblock(id)
    if string.find(blocked, "+"..id) == nil then
        return 0
    else
        return 1
    end
end
local function gFile(id, file)
    if string.find(file, "\\") then
        log(id..": tryed read outside files/ | Blocked", 3)
        block(id)
    else
    if fs.exists("files/"..file) then
        local file = fs.open("files/"..file, "r")
        local content = file.readAll()
        rednet.send(id, content)
        log(id..":Got file", 1)
        file.close()
    end
    end
end
local function sFile(id, content, file)
    --new security system
    if string.find(file, "\\") then
        log(id..": send dangerous file Blocked", 3)
        block(id)
    else
        if fs.exists("files/"..file) then
            fs.delete("files/"..file)
        end
            local file = fs.open("files/"..file, "w")
            file.write(content)
            file.close()
            log(id..":Sended file", 1)
    end
end
local function RequestCheck(id, request)
    if type(request) == "string" or type(request) == "nil" or type(request) == "function" or type(request) == "number" then
        log(id..":not a table", 2)
        return 0
    else
        if not request[1] then
            log(id..":invalid request table", 2)
            return 0
        else
            if request[1] == "get" or request[1] == "send" then
                if type(request[2]) == "nil" or type(request[3]) == "nil" and request[1] == "send" then
                    log(id..":Wrong or not enoutgh parameter", 2)
                else
                    -- if everything right here are the checks
                    if request[1] == "get" then
                        gFile(id, request[2]) -- still gotta make geting algorythm
                        return 1
                    end
                    if request[1] == "send" then
                        sFile(id, request[2], request[3]) -- Still gotta make The saving algorythm
                        return 1
                    end
            end
            else
                log(id..":invalid request", 2)
            end
        end
    end
end
print("Plexus-Server-Alpha")
while true do
    local id, message = rednet.receive()
    if checkblock(id) == 1 then
    log(id..": tryed but is blocked", 3)
    else
    RequestCheck(id, message)
    end
end

