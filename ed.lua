local Players = cloneref(game:GetService("Players"))
local CoreGui = game:GetService("CoreGui")
local RunService = cloneref(game:GetService("RunService"))

local ESP = {
    Enabled = false,
    TeamCheck = false,
    MaxDistance = 200,
    Drawing = {
        Chams = {
            Enabled = false,
            Color = Color3.fromRGB(119, 120, 255),
            Transparency = 0.5
        }
    }
}

-- Cache container
local HighlightContainer = Instance.new("Folder")
HighlightContainer.Name = "ChamsESPContainer"
HighlightContainer.Parent = CoreGui

-- Cache camera
local camera = workspace.CurrentCamera
local playerConnections = {}

local function CleanupPlayer(plr)
    if playerConnections[plr] then
        playerConnections[plr]:Disconnect()
        playerConnections[plr] = nil
    end
    
    if HighlightContainer:FindFirstChild(plr.Name) then
        HighlightContainer[plr.Name]:Destroy()
    end
end

local function CreateChamsESP(plr)
    if plr == Players.LocalPlayer then return end
    CleanupPlayer(plr)
    
    local highlight = Instance.new("Highlight")
    highlight.Name = plr.Name
    highlight.Parent = HighlightContainer
    highlight.FillColor = ESP.Drawing.Chams.Color
    highlight.OutlineColor = ESP.Drawing.Chams.Color
    highlight.FillTransparency = ESP.Drawing.Chams.Transparency
    highlight.OutlineTransparency = ESP.Drawing.Chams.Transparency
    highlight.Enabled = false
    
    local lastUpdate = 0
    local updateThreshold = 0.1 -- Update every 0.1 seconds

    playerConnections[plr] = RunService.Heartbeat:Connect(function()
        local now = tick()
        if now - lastUpdate < updateThreshold then return end
        lastUpdate = now
        
        local character = plr.Character
        if not character or not ESP.Enabled or not ESP.Drawing.Chams.Enabled then
            highlight.Enabled = false
            return
        end

        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then
            highlight.Enabled = false
            return
        end

        local distance = (camera.CFrame.Position - humanoidRootPart.Position).Magnitude
        if distance > ESP.MaxDistance then
            highlight.Enabled = false
            return
        end

        if highlight.Adornee ~= character then
            highlight.Adornee = character
        end
        
        highlight.Enabled = true
    end)

    plr.CharacterRemoving:Connect(function()
        highlight.Enabled = false
    end)
end

function ESP:UpdateColors(chamsColor)
    ESP.Drawing.Chams.Color = chamsColor
    
    -- Update existing highlights
    for _, highlight in pairs(HighlightContainer:GetChildren()) do
        if highlight:IsA("Highlight") then
            highlight.FillColor = chamsColor
            highlight.OutlineColor = chamsColor
        end
    end
end

-- Cleanup on script stop
local cleanupConnection
cleanupConnection = game:GetService("CoreGui").ChildRemoved:Connect(function(child)
    if child == HighlightContainer then
        for _, conn in pairs(playerConnections) do
            conn:Disconnect()
        end
        cleanupConnection:Disconnect()
    end
end)

-- Initialize
for _, plr in ipairs(Players:GetPlayers()) do
    if plr ~= Players.LocalPlayer then
        CreateChamsESP(plr)
    end
end

Players.PlayerAdded:Connect(CreateChamsESP)
Players.PlayerRemoving:Connect(CleanupPlayer)

return ESP
