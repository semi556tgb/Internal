local Players = cloneref(game:GetService("Players"))
local CoreGui = game:GetService("CoreGui")
local RunService = cloneref(game:GetService("RunService"))

-- Load Dendro ESP
local DendroESP = loadstring(game:HttpGet("YOUR_RAW_DENDRO_ESP_URL"))()

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
    
    -- Create Dendro ESP for character
    local chamsESP = DendroESP:AddCharacter(plr.Character, "Highlight")
    
    -- Configure chams settings
    chamsESP.FillOpacity = ESP.Drawing.Chams.Fill_Transparency * 0.01
    chamsESP.Opacity = ESP.Drawing.Chams.Outline_Transparency * 0.01
    chamsESP.PositiveColor = ESP.Drawing.Chams.FillRGB
    chamsESP.NegativeColor = ESP.Drawing.Chams.OutlineRGB
    
    -- Update chams visibility
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
end

-- Initialize
for _, plr in ipairs(Players:GetPlayers()) do
    if plr ~= Players.LocalPlayer then
        CreateChamsESP(plr)
    end
end

Players.PlayerAdded:Connect(CreateChamsESP)

return ESP
