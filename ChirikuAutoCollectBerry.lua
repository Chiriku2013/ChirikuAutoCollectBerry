--[[
	Auto Collect Berry | By: Chiriku Roblox
	Script hỗ trợ: Nhặt Berry + ESP + Smart Hop + Auto Team + Store + Auto Rejoin
	Hỗ trợ Sea 1, 2, 3 - Tối ưu mobile & executor Delta/Solara
]]

-- Cấu hình
getgenv().Team = "Marines" -- Auto vào team
local BerryNameList = {
	"Berry",
	"Blue Icicle Berry",
	"Green Toad Berry",
	"Orange Berry",
	"Pink Pig Berry",
	"Purple Jelly Berry",
	"Red Cherry Berry",
	"White Cloud Berry",
	"Yellow Star Berry"
}

-- Notify mở đầu
pcall(function()
	game.StarterGui:SetCore("SendNotification", {
		Title = "Auto Collect Berry",
		Text = "By: Chiriku Roblox",
		Duration = 5
	})
end)

-- Anti AFK
pcall(function()
	local vu = game:GetService("VirtualUser")
	game:GetService("Players").LocalPlayer.Idled:Connect(function()
		vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
		wait(1)
		vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
	end)
end)

-- Auto team
spawn(function()
	repeat wait()
		pcall(function()
			if game.Players.LocalPlayer.Team == nil then
				for _,v in pairs(game:GetService("Teams"):GetChildren()) do
					if v.Name == getgenv().Team then
						game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("SetTeam", v.Name)
					end
				end
			end
		end)
	until game.Players.LocalPlayer.Team ~= nil
end)

-- ESP Berry
local function createESP(part)
	if part:FindFirstChild("ESPLabel") then return end
	local billboard = Instance.new("BillboardGui", part)
	billboard.Name = "ESPLabel"
	billboard.Size = UDim2.new(0, 100, 0, 20)
	billboard.AlwaysOnTop = true
	billboard.Adornee = part

	local text = Instance.new("TextLabel", billboard)
	text.Size = UDim2.new(1, 0, 1, 0)
	text.BackgroundTransparency = 1
	text.TextColor3 = Color3.new(1, 1, 0)
	text.TextStrokeTransparency = 0
	text.TextScaled = true
	text.Text = "[Berry] "..math.floor((part.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude).."m"
end

-- Tìm Berry
function findBerry()
	for _,v in pairs(workspace:GetDescendants()) do
		if v:IsA("BasePart") and table.find(BerryNameList, v.Name) then
			if v:FindFirstChild("TouchInterest") then
				createESP(v)
				return v
			end
		end
	end
	return nil
end

-- Bay mượt
function goTo(pos)
	local plr = game.Players.LocalPlayer
	local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local bodyVel = Instance.new("BodyVelocity", hrp)
	bodyVel.MaxForce = Vector3.new(1e9, 1e9, 1e9)
	bodyVel.Velocity = Vector3.zero

	while (hrp.Position - pos).Magnitude > 5 do
		bodyVel.Velocity = (pos - hrp.Position).Unit * 350
		wait()
	end

	bodyVel:Destroy()
end

-- Smart Hop
local HopList = {}
local function HopServer()
	if not game:GetService("Players").LocalPlayer:FindFirstChild("Teleporting") then
		local Http = game:GetService("HttpService")
		local Servers = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=2&limit=100"))
		for i,v in pairs(Servers.data) do
			if type(v) == "table" and v.playing < v.maxPlayers and v.id ~= game.JobId and not table.find(HopList, v.id) then
				table.insert(HopList, v.id)
				game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, v.id, game.Players.LocalPlayer)
				wait(3)
			end
		end
	end
end

-- Store Berry
local function storeBerry()
	local backpack = game:GetService("Players").LocalPlayer.Backpack
	for i,v in pairs(backpack:GetChildren()) do
		if v:IsA("Tool") and table.find(BerryNameList, v.Name) then
			fireclickdetector(workspace:FindFirstChild("ItemStorage").ClickDetector)
			wait(1)
		end
	end
end

-- Auto rejoin nếu bị kick
game:GetService("CoreGui").RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(child)
	if child.Name == "ErrorPrompt" then
		game:GetService("TeleportService"):Teleport(game.PlaceId)
	end
end)

-- Loop chính
while true do
	pcall(function()
		local berry = findBerry()
		if berry then
			goTo(berry.Position + Vector3.new(0, 3, 0))
			wait(0.5)
			storeBerry()
		else
			HopServer()
		end
	end)
	wait(1)
end
