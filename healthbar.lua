local Players = cloneref(game:GetService("Players"))
local CoreGui = game:GetService("CoreGui")
local RunService = cloneref(game:GetService("RunService"))

local ESP = {
    Enabled = false,
    TeamCheck = false,
    MaxDistance = 200,
    FadeOut = {
        OnDistance = true
    },
    Drawing = {
        Healthbar = {
            Enabled = false,
            HealthText = true,
            Lerp = false,
            HealthTextRGB = Color3.fromRGB(119, 120, 255),
            Width = 2.5,
            Gradient = true,
            GradientRGB1 = Color3.fromRGB(119, 120, 255), -- Changed to purple
            GradientRGB2 = Color3.fromRGB(60, 60, 125),   -- Darker purple
            GradientRGB3 = Color3.fromRGB(200, 200, 255)  -- Lighter purple
        }
    }
}

local function CreateHealthESP(plr)
    if plr == Players.LocalPlayer then return end
    
    local ScreenGui = Instance.new("ScreenGui", CoreGui)
    ScreenGui.Name = "HealthESPHolder"

    local Healthbar = Instance.new("Frame", ScreenGui)
    Healthbar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Healthbar.BackgroundTransparency = 0
    Healthbar.Visible = false

    local BehindHealthbar = Instance.new("Frame", ScreenGui)
    BehindHealthbar.ZIndex = -1
    BehindHealthbar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    BehindHealthbar.BackgroundTransparency = 0
    BehindHealthbar.Visible = false

    local HealthbarGradient = Instance.new("UIGradient", Healthbar)
    HealthbarGradient.Rotation = -90
    HealthbarGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, ESP.Drawing.Healthbar.GradientRGB1),
        ColorSequenceKeypoint.new(0.5, ESP.Drawing.Healthbar.GradientRGB2),
        ColorSequenceKeypoint.new(1, ESP.Drawing.Healthbar.GradientRGB3)
    }
    HealthbarGradient.Enabled = ESP.Drawing.Healthbar.Gradient

    local HealthText = Instance.new("TextLabel", ScreenGui)
    HealthText.BackgroundTransparency = 1
    HealthText.TextColor3 = ESP.Drawing.Healthbar.HealthTextRGB
    HealthText.Font = Enum.Font.Code
    HealthText.TextSize = 14
    HealthText.TextStrokeTransparency = 0
    HealthText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    HealthText.Visible = false

    RunService.RenderStepped:Connect(function()
        if not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") or not plr.Character:FindFirstChild("Humanoid") then
            Healthbar.Visible = false
            BehindHealthbar.Visible = false
            HealthText.Visible = false
            return
        end

        if not ESP.Enabled or not ESP.Drawing.Healthbar.Enabled then
            Healthbar.Visible = false
            BehindHealthbar.Visible = false
            HealthText.Visible = false
            return
        end

        local HRP = plr.Character.HumanoidRootPart
        local Humanoid = plr.Character.Humanoid
        local pos, onScreen = workspace.CurrentCamera:WorldToScreenPoint(HRP.Position)
        local dist = (workspace.CurrentCamera.CFrame.Position - HRP.Position).Magnitude

        if onScreen and dist <= ESP.MaxDistance then
            local health = Humanoid.Health / Humanoid.MaxHealth
            local Size = HRP.Size.Y
            local scaleFactor = (Size * workspace.CurrentCamera.ViewportSize.Y) / (pos.Z * 2)
            local w, h = 3 * scaleFactor, 4.5 * scaleFactor

            Healthbar.Position = UDim2.new(0, pos.X - w/2 - 6, 0, pos.Y - h/2 + h * (1-health))
            Healthbar.Size = UDim2.new(0, ESP.Drawing.Healthbar.Width, 0, h * health)
            Healthbar.Visible = true

            BehindHealthbar.Position = UDim2.new(0, pos.X - w/2 - 6, 0, pos.Y - h/2)
            BehindHealthbar.Size = UDim2.new(0, ESP.Drawing.Healthbar.Width, 0, h)
            BehindHealthbar.Visible = true

            if ESP.Drawing.Healthbar.HealthText then
                local healthPercentage = math.floor(health * 100)
                HealthText.Position = UDim2.new(0, pos.X - w/2 - 6, 0, pos.Y - h/2 + h * (1-health) + 3)
                HealthText.Text = tostring(healthPercentage)
                HealthText.Visible = Humanoid.Health < Humanoid.MaxHealth

                if ESP.Drawing.Healthbar.Lerp then
                    local color = health >= 0.75 and Color3.fromRGB(0, 255, 0) or 
                                health >= 0.5 and Color3.fromRGB(255, 255, 0) or 
                                health >= 0.25 and Color3.fromRGB(255, 170, 0) or 
                                Color3.fromRGB(255, 0, 0)
                    HealthText.TextColor3 = color
                else
                    HealthText.TextColor3 = ESP.Drawing.Healthbar.HealthTextRGB
                end
            end

            if ESP.FadeOut.OnDistance then
                local transparency = math.clamp(dist / ESP.MaxDistance, 0.1, 1)
                Healthbar.BackgroundTransparency = transparency
                BehindHealthbar.BackgroundTransparency = transparency
                HealthText.TextTransparency = transparency
                HealthText.TextStrokeTransparency = transparency
            end
        else
            Healthbar.Visible = false
            BehindHealthbar.Visible = false
            HealthText.Visible = false
        end
    end)
end

function ESP:UpdateColors(lowColor, highColor)
    ESP.Drawing.Healthbar.GradientRGB1 = lowColor
    ESP.Drawing.Healthbar.GradientRGB3 = highColor
    
    -- Update existing healthbars
    for _, bar in pairs(CoreGui:FindFirstChild("HealthESPHolder"):GetChildren()) do
        if bar:IsA("Frame") and bar:FindFirstChild("UIGradient") then
            local gradient = bar.UIGradient
            gradient.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, lowColor),
                ColorSequenceKeypoint.new(0.5, ESP.Drawing.Healthbar.GradientRGB2),
                ColorSequenceKeypoint.new(1, highColor)
            }
        end
    end
end

-- Initialize
for _, plr in pairs(Players:GetPlayers()) do
    CreateHealthESP(plr)
end

Players.PlayerAdded:Connect(CreateHealthESP)

return ESP
