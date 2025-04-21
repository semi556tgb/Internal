local Players = cloneref(game:GetService("Players"))
local CoreGui = game:GetService("CoreGui")
local RunService = cloneref(game:GetService("RunService"))

local ESP = {
    Enabled = false,
    TeamCheck = false,
    MaxDistance = 200,
    Drawing = {
        Names = {
            Enabled = false,
            RGB = Color3.fromRGB(255, 255, 255),
        }
    }
}

local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "NameESPHolder"

local function CreateNameESP(plr)
    if plr == Players.LocalPlayer then return end
    
    local nameLabel = Instance.new("TextLabel", ScreenGui)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Size = UDim2.new(0, 200, 0, 20)
    nameLabel.Font = Enum.Font.Code
    nameLabel.TextSize = 14
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextColor3 = ESP.Drawing.Names.RGB
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.Visible = false

    RunService.RenderStepped:Connect(function()
        if not ESP.Enabled or not ESP.Drawing.Names.Enabled then
            nameLabel.Visible = false
            return
        end

        if not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then
            nameLabel.Visible = false
            return
        end

        local pos, onScreen = workspace.CurrentCamera:WorldToScreenPoint(plr.Character.HumanoidRootPart.Position)
        local dist = (workspace.CurrentCamera.CFrame.Position - plr.Character.HumanoidRootPart.Position).Magnitude

        if onScreen and dist <= ESP.MaxDistance then
            nameLabel.Position = UDim2.new(0, pos.X, 0, pos.Y - 40)
            nameLabel.Text = string.format("%s [%d]", plr.Name, math.floor(dist))
            nameLabel.Visible = true

            -- Fade with distance
            local transparency = math.clamp(dist / ESP.MaxDistance, 0.1, 1)
            nameLabel.TextTransparency = transparency
            nameLabel.TextStrokeTransparency = transparency
        else
            nameLabel.Visible = false
        end
    end)

    plr.CharacterRemoving:Connect(function()
        nameLabel.Visible = false
    end)
end

-- Initialize
for _, plr in pairs(Players:GetPlayers()) do
    CreateNameESP(plr)
end

Players.PlayerAdded:Connect(CreateNameESP)

return ESP
