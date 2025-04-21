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

local function CreateChamsESP(plr)
    if plr == Players.LocalPlayer then return end
    
    local Highlight = Instance.new("Highlight")
    Highlight.FillTransparency = 1
    Highlight.OutlineTransparency = 0
    Highlight.OutlineColor = ESP.Drawing.Chams.OutlineRGB
    Highlight.DepthMode = ESP.Drawing.Chams.VisibleCheck and "Occluded" or "AlwaysOnTop"
    
    RunService.RenderStepped:Connect(function()
        if not plr.Character then 
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
        Highlight.FillColor = ESP.Drawing.Chams.FillRGB
        Highlight.OutlineColor = ESP.Drawing.Chams.OutlineRGB
        
        if ESP.Drawing.Chams.Thermal then
            local breathe_effect = math.atan(math.sin(tick() * 2)) * 2 / math.pi
            Highlight.FillTransparency = ESP.Drawing.Chams.Fill_Transparency * breathe_effect * 0.01
            Highlight.OutlineTransparency = ESP.Drawing.Chams.Outline_Transparency * breathe_effect * 0.01
        end
        
        Highlight.DepthMode = ESP.Drawing.Chams.VisibleCheck and "Occluded" or "AlwaysOnTop"
    end)

    plr.CharacterRemoving:Connect(function()
        Highlight.Enabled = false
    end)
end

for _, plr in ipairs(Players:GetPlayers()) do
    if plr ~= Players.LocalPlayer then
        CreateChamsESP(plr)
    end
end

Players.PlayerAdded:Connect(CreateChamsESP)

return ESP
