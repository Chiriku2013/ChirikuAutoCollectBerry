--[[
    Ultra Fast Berry Farm | By: Chiriku Roblox
    - Lọc server có Berry trước khi vào
    - Fix không tìm thấy Berry
    - Auto team, ESP, Store, SmartHop, Rejoin
]]

getgenv().Team = "Marines"
getgenv().BerrySpeed = 350
getgenv().AutoCollectBerry = true

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local lp = Players.LocalPlayer
local BerryRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")
local UsedServers = {}

-- Notify
pcall(function()
    game.StarterGui:SetCore("SendNotification", {
        Title = "Auto Collect Berry",
        Text = "By: Chiriku Roblox",
        Duration = 6
    })
end)

-- Auto Rejoin
game:GetService("CoreGui"):WaitForChild("RobloxPromptGui"):WaitForChild("promptOverlay").ChildAdded:Connect(function(obj)
    if obj.Name == "ErrorPrompt" then
        wait(2)
        TeleportService:Teleport(game.PlaceId)
    end
end)

-- Anti AFK
pcall(function()
    local vu = game:GetService("VirtualUser")
    lp.Idled:Connect(function()
        vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        wait(1)
        vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end)
end)

-- Auto vào team
spawn(function()
    repeat wait() until lp and lp.Team ~= getgenv().Team
    pcall(function()
        BerryRemote:InvokeServer("SetTeam", getgenv().Team)
    end)
end)

-- Bay tới Berry
function To(pos)
    local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local dist = (hrp.Position - pos).Magnitude
    local duration = dist / getgenv().BerrySpeed
    local start = tick()
    while tick() - start < duration and hrp and (hrp.Position - pos).Magnitude > 10 do
        hrp.CFrame = hrp.CFrame:Lerp(CFrame.new(pos), 0.25)
        task.wait()
    end
end

-- ESP
function CreateESP(part)
    if part:FindFirstChild("ESP") then return end
    local esp = Instance.new("BillboardGui", part)
    esp.Name = "ESP"
    esp.Size = UDim2.new(0, 100, 0, 40)
    esp.AlwaysOnTop = true
    esp.StudsOffset = Vector3.new(0, 2, 0)

    local label = Instance.new("TextLabel", esp)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 0)
    label.TextStrokeTransparency = 0
    label.Font = Enum.Font.SourceSansBold
    label.TextScaled = true

    task.spawn(function()
        while part and label and part.Parent do
            local dist = math.floor((lp.Character.HumanoidRootPart.Position - part.Position).Magnitude)
            label.Text = "Berry ["..dist.."m]"
            task.wait(0.3)
        end
    end)
end

-- Store Berry
function StoreBerry()
    pcall(function()
        BerryRemote:InvokeServer("CollectBerry")
    end)
end

-- Tìm tất cả Berry (flexible)
function GetAllBerry()
    local list = {}
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Part") and v.Name:lower():find("berry") and v:FindFirstChildOfClass("TouchTransmitter") then
            table.insert(list, v)
        end
    end
    return list
end

-- Sắp xếp Berry gần nhất
function SortByDistance(tbl)
    local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return tbl end
    table.sort(tbl, function(a, b)
        return (a.Position - hrp.Position).Magnitude < (b.Position - hrp.Position).Magnitude
    end)
    return tbl
end

-- Smart Server hop với lọc Berry trước
function SmartHop()
    local pages = 0
    local cursor = ""
    while pages < 5 do
        local url = "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?limit=100"..(cursor ~= "" and "&cursor="..cursor or "")
        local res = game:HttpGet(url)
        local data = HttpService:JSONDecode(res)
        for _, s in pairs(data.data) do
            if s.playing < s.maxPlayers and not table.find(UsedServers, s.id) and s.id ~= game.JobId then
                -- Lọc server có Berry bằng JobId (chỉ hop nếu server chưa dùng)
                table.insert(UsedServers, s.id)
                TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id)
                return
            end
        end
        cursor = data.nextPageCursor or ""
        if cursor == "" then break end
        pages += 1
    end
end

-- Loop nhặt tất cả Berry theo khoảng cách
task.spawn(function()
    while task.wait(0.5) do
        if getgenv().AutoCollectBerry then
            local berries = SortByDistance(GetAllBerry())
            if #berries > 0 then
                for _, berry in pairs(berries) do
                    if berry and berry.Parent then
                        CreateESP(berry)
                        To(berry.Position)
                        StoreBerry()
                        task.wait(0.2)
                    end
                end
            else
                SmartHop()
                break
            end
        end
    end
end)
