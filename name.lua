local Players = cloneref(game:GetService("Players"))
local CoreGui = game:GetService("CoreGui")

local ESP = {
    Enabled = false,
    TeamCheck = true,
    MaxDistance = 200,
    FontSize = 11,
    Drawing = {
        Names = {
            Enabled = false,
            RGB = Color3.fromRGB(255, 255, 255),
        }
    }
}

local function CreateNameESP(plr)
    local ScreenGui = Instance.new("ScreenGui", CoreGui)
    local Name = Instance.new("TextLabel", ScreenGui)
    Name.BackgroundTransparency = 1
    Name.Size = UDim2.new(0, 100, 0, 20)
    Name.Font = Enum.Font.Code
    Name.TextSize = ESP.FontSize
    Name.TextStrokeTransparency = 0
    Name.TextColor3 = ESP.Drawing.Names.RGB
    Name.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    
    local function UpdateESP()
        local connection
        connection = game:GetService("RunService").RenderStepped:Connect(function()
            if not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then
                Name.Visible = false
                return
            end

            local pos, onScreen = workspace.CurrentCamera:WorldToScreenPoint(plr.Character.HumanoidRootPart.Position)
            local dist = (workspace.CurrentCamera.CFrame.Position - plr.Character.HumanoidRootPart.Position).Magnitude

            if onScreen and dist <= ESP.MaxDistance and ESP.Enabled and ESP.Drawing.Names.Enabled then
                Name.Position = UDim2.new(0, pos.X, 0, pos.Y - 40)
                Name.Text = plr.Name
                Name.Visible = true
                
                -- Fade with distance
                local transparency = math.max(0.1, 1 - (dist / ESP.MaxDistance))
                Name.TextTransparency = 1 - transparency
            else
                Name.Visible = false
            end
        end)

        plr.CharacterRemoving:Connect(function()
            Name.Visible = false
        end)

        Players.PlayerRemoving:Connect(function(player)
            if player == plr then
                connection:Disconnect()
                ScreenGui:Destroy()
            end
        end)
    end

    UpdateESP()
end

local function Init()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer then
            CreateNameESP(player)
        end
    end

    Players.PlayerAdded:Connect(function(player)
        if player ~= Players.LocalPlayer then
            CreateNameESP(player)
        end
    end)
end

Init()
return ESP
