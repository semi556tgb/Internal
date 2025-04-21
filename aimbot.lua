local Aimbot = {
    Enabled = false,
    Active = false,
    Target = nil,
    Smoothness = 0.25
}

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

function Aimbot:GetClosestPlayer()
    local closest = nil
    local shortest = math.huge
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and 
           player.Character and 
           player.Character:FindFirstChild("HumanoidRootPart") then
            local pos = workspace.CurrentCamera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
            if dist < shortest then
                shortest = dist
                closest = player
            end
        end
    end
    return closest
end

RunService.RenderStepped:Connect(function()
    if not (Aimbot.Enabled and Aimbot.Active) then return end
    
    if Aimbot.Target and 
       Aimbot.Target.Character and 
       Aimbot.Target.Character:FindFirstChild("HumanoidRootPart") then
        local targetPos = Aimbot.Target.Character.HumanoidRootPart.Position
        local camPos = workspace.CurrentCamera.CFrame
        local newCF = camPos:Lerp(CFrame.new(camPos.Position, targetPos), Aimbot.Smoothness)
        workspace.CurrentCamera.CFrame = newCF
    end
end)

return Aimbot
