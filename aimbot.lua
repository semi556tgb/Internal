local Players = cloneref(game:GetService("Players"))
local RunService = cloneref(game:GetService("RunService"))
local UserInputService = game:GetService("UserInputService")

local Aimbot = {
    Enabled = false,
    Active = false, -- New property for when key is held
    TargetPart = "Head", -- Part to aim at
    FOV = 150, -- Field of view for target acquisition
    Smoothness = 0.5, -- Lower = faster
    TeamCheck = true,
    VisibilityCheck = true,

    Toggle = function(self)
        self.Active = not self.Active
        FOVCircle.Visible = self.Active and self.Enabled
    end
}

local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- FOV Circle (for debugging)
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.NumSides = 100
FOVCircle.Radius = Aimbot.FOV
FOVCircle.Filled = false
FOVCircle.Visible = false
FOVCircle.ZIndex = 999
FOVCircle.Transparency = 1
FOVCircle.Color = Color3.fromRGB(255, 255, 255)

-- Utility Functions
local function IsVisible(part)
    if not Aimbot.VisibilityCheck then return true end
    
    local origin = Camera.CFrame.Position
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {LocalPlayer.Character, part.Parent}
    params.FilterType = Enum.RaycastFilterType.Blacklist
    
    local direction = (part.Position - origin).Unit * 500
    local result = workspace:Raycast(origin, direction, params)
    
    return not result
end

local function GetClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = Aimbot.FOV

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and 
           player.Character and 
           player.Character:FindFirstChild(Aimbot.TargetPart) and
           player.Character:FindFirstChildOfClass("Humanoid") and
           player.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
            
            if Aimbot.TeamCheck and player.Team == LocalPlayer.Team then
                continue
            end

            local part = player.Character[Aimbot.TargetPart]
            local screenPos, onScreen = Camera:WorldToScreenPoint(part.Position)
            
            if not onScreen then continue end
            
            local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            local distance = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
            
            if distance < shortestDistance and IsVisible(part) then
                closestPlayer = player
                shortestDistance = distance
            end
        end
    end

    return closestPlayer
end

-- Main Aimbot Loop
RunService.RenderStepped:Connect(function()
    if not (Aimbot.Enabled and Aimbot.Active) then 
        FOVCircle.Visible = false
        return 
    end

    FOVCircle.Visible = true
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    local target = GetClosestPlayer()
    if not target then return end

    local targetPart = target.Character[Aimbot.TargetPart]
    local targetPos = Camera:WorldToViewportPoint(targetPart.Position)
    local mousePos = Vector2.new(Mouse.X, Mouse.Y)
    local aimPos = Vector2.new(targetPos.X, targetPos.Y)
    
    mousemoverel(
        (aimPos.X - mousePos.X) * Aimbot.Smoothness,
        (aimPos.Y - mousePos.Y) * Aimbot.Smoothness
    )
end)

return Aimbot
