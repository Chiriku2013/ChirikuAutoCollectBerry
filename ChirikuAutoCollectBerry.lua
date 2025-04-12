--[[ 
    Auto Collect Berry | Chạy ngay khi execute
    By Chiriku Roblox | ESP + Smart Hop + Bay thẳng + Auto Team Marines + Store Berry
    Hỗ trợ Delta, Solara | Mobile | All Sea
]]

-- Cấu hình mặc định
getgenv().AutoCollectBerry = true
getgenv().BerrySpeed = 350
getgenv().Team = "Marines" -- Auto vào đội Marines

local HopDelay = 0
local ServerHistory = {}
local ply = game.Players.LocalPlayer

-- Auto vào Team Marines
repeat wait() until ply.Team
if getgenv().Team and ply.Team.Name ~= getgenv().Team then
    for _, team in pairs(game:GetService("Teams"):GetChildren()) do
        if team.Name == getgenv().Team then
            game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("SetTeam", getgenv().Team)
        end
    end
end

-- Anti AFK
pcall(function()
    local vu = game:GetService("VirtualUser")
    ply.Idled:Connect(function()
        vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
        wait(1)
        vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
    end)
end)

-- Auto Rejoin
pcall(function()
    game.CoreGui.RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(c)
        if c.Name == "ErrorPrompt" then
            wait(1)
            game:GetService("TeleportService"):Teleport(game.PlaceId)
        end
    end)
end)

-- Bay thẳng
function To(Pos)
    local hrp = ply.Character and ply.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local dist = (hrp.Position - Pos).Magnitude
    local time = dist / getgenv().BerrySpeed
    local start = tick()
    while tick() - start < time do
        if not ply.Character or not hrp then return end
        hrp.Velocity = Vector3.zero
        hrp.CFrame = CFrame.new(hrp.Position, Pos) * CFrame.new(0, 0, -getgenv().BerrySpeed * (wait() and 1))
    end
end

-- ESP
function CreateESP(obj)
    if obj:FindFirstChild("ESP") then return end
    local Billboard = Instance.new("BillboardGui", obj)
    Billboard.Name = "ESP"
    Billboard.Size = UDim2.new(0, 100, 0, 40)
    Billboard.AlwaysOnTop = true
    Billboard.StudsOffset = Vector3.new(0, 2, 0)

    local Text = Instance.new("TextLabel", Billboard)
    Text.Size = UDim2.new(1, 0, 1, 0)
    Text.BackgroundTransparency = 1
    Text.TextColor3 = Color3.fromRGB(255, 255, 0)
    Text.TextStrokeTransparency = 0
    Text.Font = Enum.Font.SourceSansBold
    Text.TextScaled = true

    spawn(function()
        while obj and Billboard and Text and Billboard.Parent do
            local dist = math.floor((ply.Character.HumanoidRootPart.Position - obj.Position).Magnitude)
            Text.Text = "Berry ["..dist.."m]"
            wait(0.2)
        end
    end)
end

-- Smart Server Hop
function Hop()
    local HttpService = game:GetService("HttpService")
    local TeleportService = game:GetService("TeleportService")
    local PlaceId = game.PlaceId

    local req = syn and syn.request or http and http.request or http_request or request
    local data = HttpService:JSONDecode(req({
        Url = "https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?sortOrder=Desc&limit=100"
    }).Body)

    for _, v in pairs(data.data) do
        if v.id ~= game.JobId and not table.find(ServerHistory, v.id) then
            table.insert(ServerHistory, v.id)
            TeleportService:TeleportToPlaceInstance(PlaceId, v.id)
            break
        end
    end
end

-- Store Berry
function StoreBerry()
    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("CollectBerry")
end

-- Auto Collect
spawn(function()
    while wait(1) do
        if getgenv().AutoCollectBerry then
            local found = false
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") and v.Name == "Berry" and v:FindFirstChildWhichIsA("TouchTransmitter") then
                    found = true
                    if not v:FindFirstChild("ESP") then
                        CreateESP(v)
                    end
                    To(v.Position)
                    StoreBerry()
                    wait(0.2)
                end
            end
            if not found then
                warn("Không thấy Berry. Hop ngay...")
                wait(HopDelay)
                Hop()
            end
        end
    end
end)

-- Notify
game.StarterGui:SetCore("SendNotification", {
    Title = "Auto Collect Berry",
    Text = "By: Chiriku Roblox",
    Duration = 6
})
