local Players = cloneref(game:GetService("Players"))
local RunService = cloneref(game:GetService("RunService"))

local Aimbot = {
    Enabled = false,
    Active = false,
    TargetPart = "HumanoidRootPart",
    Smoothness = 0.25,
    TeamCheck = true
}

local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local function GetClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and 
           player.Character and 
           player.Character:FindFirstChild(Aimbot.TargetPart) and
           player.Character:FindFirstChildOfClass("Humanoid") and
           player.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
            
            if Aimbot.TeamCheck and player.Team == LocalPlayer.Team then
                continue
            end

            local pos = player.Character[Aimbot.TargetPart].Position
            local dist = (Camera.CFrame.Position - pos).Magnitude
            
            if dist < shortestDistance then
                closestPlayer = player
                shortestDistance = dist
            end
        end
    end

    return closestPlayer
end

RunService.RenderStepped:Connect(function()
    if not (Aimbot.Enabled and Aimbot.Active) then return end

    local target = GetClosestPlayer()
    if not target or not target.Character then return end

    local targetPart = target.Character[Aimbot.TargetPart]
    local targetPos = targetPart.Position
    
    local currentCam = Camera.CFrame
    local targetCam = CFrame.new(currentCam.Position, targetPos)
    local smoothedCam = currentCam:Lerp(targetCam, Aimbot.Smoothness)
    
    if (currentCam.Position - LocalPlayer.Character.Head.Position).Magnitude > 1 then
        Camera.CFrame = smoothedCam
    end
end)

return Aimbot
