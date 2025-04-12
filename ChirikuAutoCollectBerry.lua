--[[ 
    Auto Collect Berry | By: Chiriku Roblox
    - Tự động nhặt Berry + store
    - Auto vào đội Marines
    - Smart Hop + ESP + Bay mượt
    - Chạy ngay khi execute
]]

getgenv().Team = "Marines"
getgenv().BerrySpeed = 350
getgenv().AutoCollectBerry = true

local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local rs = game:GetService("ReplicatedStorage")
local tpService = game:GetService("TeleportService")
local httpService = game:GetService("HttpService")
local BerryRemote = rs:WaitForChild("Remotes"):FindFirstChild("CommF_")

local function Notify(t, msg)
    game.StarterGui:SetCore("SendNotification", {
        Title = t,
        Text = msg,
        Duration = 5
    })
end

Notify("Auto Collect Berry", "By: Chiriku Roblox")

-- Auto Join Team
spawn(function()
    repeat wait() until lp
    if lp.Team == nil or lp.Team.Name ~= getgenv().Team then
        pcall(function()
            BerryRemote:InvokeServer("SetTeam", getgenv().Team)
        end)
    end
end)

-- Anti AFK
pcall(function()
    local vu = game:GetService("VirtualUser")
    lp.Idled:Connect(function()
        vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
        wait(1)
        vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
    end)
end)

-- Bay đến vị trí
function To(pos)
    local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local dist = (hrp.Position - pos).Magnitude
    local travelTime = dist / getgenv().BerrySpeed
    local start = tick()
    while tick() - start < travelTime and (hrp.Position - pos).Magnitude > 10 do
        hrp.CFrame = hrp.CFrame:Lerp(CFrame.new(pos), 0.2)
        task.wait()
    end
end

-- ESP Berry
function CreateESP(part)
    if part:FindFirstChild("ESP") then return end
    local bill = Instance.new("BillboardGui", part)
    bill.Name = "ESP"
    bill.AlwaysOnTop = true
    bill.Size = UDim2.new(0, 100, 0, 40)
    bill.StudsOffset = Vector3.new(0, 2, 0)

    local label = Instance.new("TextLabel", bill)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 0)
    label.TextStrokeTransparency = 0
    label.Font = Enum.Font.SourceSansBold
    label.TextScaled = true

    spawn(function()
        while part and part.Parent and label do
            local dist = math.floor((lp.Character.HumanoidRootPart.Position - part.Position).Magnitude)
            label.Text = "Berry ["..dist.."m]"
            task.wait(0.2)
        end
    end)
end

-- Store Berry
function StoreBerry()
    pcall(function()
        BerryRemote:InvokeServer("CollectBerry")
    end)
end

-- Smart Hop
local UsedServers = {}
function SmartHop()
    pcall(function()
        local servers = httpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?limit=100&sortOrder=Desc")).data
        for _, v in pairs(servers) do
            if v.playing < v.maxPlayers and v.id ~= game.JobId and not table.find(UsedServers, v.id) then
                table.insert(UsedServers, v.id)
                tpService:TeleportToPlaceInstance(game.PlaceId, v.id)
                break
            end
        end
    end)
end

-- Auto Collect Loop
spawn(function()
    while task.wait(1) do
        if getgenv().AutoCollectBerry then
            local berry = nil
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and obj.Name == "Berry" and obj:FindFirstChildWhichIsA("TouchTransmitter") then
                    berry = obj
                    if not obj:FindFirstChild("ESP") then
                        CreateESP(obj)
                    end
                    break
                end
            end

            if berry then
                To(berry.Position)
                wait(0.3)
                StoreBerry()
            else
                SmartHop()
                break
            end
        end
    end
end)
