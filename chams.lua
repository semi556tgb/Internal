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
            Thermal = true,
            FillRGB = Color3.fromRGB(119, 120, 255),
            Fill_Transparency = 100,
            OutlineRGB = Color3.fromRGB(119, 120, 255),
            Outline_Transparency = 100,
            VisibleCheck = true,
        }
    }
}

-- Create container for highlights
local HighlightContainer = Instance.new("Folder")
HighlightContainer.Name = "ChamsESPContainer"
HighlightContainer.Parent = CoreGui

local function CreateChamsESP(plr)
    if plr == Players.LocalPlayer then return end
    
    -- Remove existing highlight if any
    if HighlightContainer:FindFirstChild(plr.Name) then
        HighlightContainer[plr.Name]:Destroy()
    end
    
    local Highlight = Instance.new("Highlight")
    Highlight.Name = plr.Name
    Highlight.Parent = HighlightContainer
    
    -- Initial setup
    Highlight.FillTransparency = ESP.Drawing.Chams.Fill_Transparency * 0.01
    Highlight.OutlineTransparency = ESP.Drawing.Chams.Outline_Transparency * 0.01
    Highlight.FillColor = ESP.Drawing.Chams.FillRGB
    Highlight.OutlineColor = ESP.Drawing.Chams.OutlineRGB
    Highlight.Enabled = false

    local connection = RunService.RenderStepped:Connect(function()
        if not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then 
            Highlight.Enabled = false
            return 
        end

        if not ESP.Enabled or not ESP.Drawing.Chams.Enabled then
            Highlight.Enabled = false
            return
        end

        local dist = (workspace.CurrentCamera.CFrame.Position - plr.Character:GetPivot().Position).Magnitude
        if dist > ESP.MaxDistance then
            Highlight.Enabled = false
            return
        end

        Highlight.Adornee = plr.Character
        Highlight.Enabled = true
        
        -- Update thermal effect
        if ESP.Drawing.Chams.Thermal then
            local breathe_effect = math.atan(math.sin(tick() * 2)) * 2 / math.pi
            Highlight.FillTransparency = 1 - (ESP.Drawing.Chams.Fill_Transparency * 0.01 * breathe_effect)
            Highlight.OutlineTransparency = 1 - (ESP.Drawing.Chams.Outline_Transparency * 0.01 * breathe_effect)
        end
        
        Highlight.DepthMode = ESP.Drawing.Chams.VisibleCheck and "Occluded" or "AlwaysOnTop"
    end)

    plr.CharacterRemoving:Connect(function()
        Highlight.Enabled = false
    end)

    Players.PlayerRemoving:Connect(function(player)
        if player == plr then
            connection:Disconnect()
            Highlight:Destroy()
        end
    end)
end

-- Clean up existing container if it exists
if CoreGui:FindFirstChild("ChamsESPContainer") then
    CoreGui:FindFirstChild("ChamsESPContainer"):Destroy()
end

-- Initialize for existing players
for _, plr in ipairs(Players:GetPlayers()) do
    if plr ~= Players.LocalPlayer then
        CreateChamsESP(plr)
    end
end

Players.PlayerAdded:Connect(CreateChamsESP)

return ESP
