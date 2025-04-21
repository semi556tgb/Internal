local Players = cloneref(game:GetService("Players"))
local RunService = cloneref(game:GetService("RunService"))
local UserInputService = game:GetService("UserInputService")

local Aimbot = {
    Enabled = false,
    Active = false, -- Will be true while key is held
    TargetPart = "Head", -- Part to aim at
    FOV = 150, -- Field of view for target acquisition
    Smoothness = 0.25, -- Lower = faster camera movement
    TeamCheck = true,
    VisibilityCheck = true,
    Prediction = 0.165, -- Prediction multiplier for movement

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

-- Main Camlock Loop
RunService.RenderStepped:Connect(function()
    if not (Aimbot.Enabled and Aimbot.Active) then 
        FOVCircle.Visible = Aimbot.Enabled
        return 
    end

    local target = GetClosestPlayer()
    if not target then return end

    local targetPart = target.Character[Aimbot.TargetPart]
    
    -- Calculate target position with prediction
    local targetPos = targetPart.Position
    local targetVel = targetPart.Velocity
    local prediction = targetVel * Aimbot.Prediction
    local finalPosition = targetPos + prediction

    -- Calculate camera angles
    local cameraCFrame = Camera.CFrame
    local cameraPosition = cameraCFrame.Position
    local targetVector = (finalPosition - cameraPosition).Unit
    
    -- Smooth interpolation
    local currentCam = Camera.CFrame
    local targetCam = CFrame.new(cameraPosition, finalPosition)
    local smoothedCam = currentCam:Lerp(targetCam, Aimbot.Smoothness)
    
    -- Update camera if player is not in first person
    if (cameraPosition - Players.LocalPlayer.Character.Head.Position).Magnitude > 1 then
        Camera.CFrame = smoothedCam
    end
end)

return Aimbot
