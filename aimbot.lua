local Aimbot = {}
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Enabled = false
local Active = false
local Smoothness = 0.25
local Target = nil

function Aimbot:Toggle(state)
    Enabled = state
end

function Aimbot:SetActive(state)
    Active = state
    if not state then
        Target = nil
    end
end

function Aimbot:SetSmoothness(value)
    Smoothness = value
end

function Aimbot:GetClosestPlayer()
    local closest = nil
    local shortest = math.huge
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
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
    if Enabled and Active then
        if not Target then
            Target = Aimbot:GetClosestPlayer()
        end
        
        if Target and Target.Character and Target.Character:FindFirstChild("HumanoidRootPart") then
            local targetPos = Target.Character.HumanoidRootPart.Position
            local camPos = workspace.CurrentCamera.CFrame
            local newCF = camPos:Lerp(CFrame.new(camPos.Position, targetPos), Smoothness)
            workspace.CurrentCamera.CFrame = newCF
        end
    else
        Target = nil
    end
end)

return Aimbot
