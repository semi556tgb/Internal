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
            Color = Color3.fromRGB(119, 120, 255), -- Purple color
        }
    }
}

local function CreateChamsESP(plr)
    if plr == Players.LocalPlayer then return end
    
    if not plr.Character then return end
    
    -- Create Vertex ESP with purple color
    local chamsESP = DendroESP:AddCharacter(plr.Character, "Vertex")
    chamsESP.PositiveColor = ESP.Drawing.Chams.Color
    chamsESP.NegativeColor = ESP.Drawing.Chams.Color
    chamsESP.NeutralColor = ESP.Drawing.Chams.Color
    
    -- Update visibility
    RunService.RenderStepped:Connect(function()
        if not ESP.Enabled or not ESP.Drawing.Chams.Enabled then
            chamsESP.Enabled = false
            return
        end
        chamsESP.Enabled = true
    end)
    
    plr.CharacterRemoving:Connect(function()
        chamsESP:Destroy()
    end)

    plr.CharacterAdded:Connect(function(char)
        chamsESP = DendroESP:AddCharacter(char, "Vertex")
        chamsESP.PositiveColor = ESP.Drawing.Chams.Color
        chamsESP.NegativeColor = ESP.Drawing.Chams.Color
        chamsESP.NeutralColor = ESP.Drawing.Chams.Color
    end)
end

-- Initialize for existing players
for _, plr in ipairs(Players:GetPlayers()) do
    if plr ~= Players.LocalPlayer then
        CreateChamsESP(plr)
    end
end

Players.PlayerAdded:Connect(CreateChamsESP)

return ESP
