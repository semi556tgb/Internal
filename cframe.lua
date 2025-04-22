local CFrameModule = {}

CFrameModule.Settings = {
    Enabled = false,
    Speed = 1,
    Height = 0
}

function CFrameModule:SetCFrame(character, newCF)
    if character and character:FindFirstChild("HumanoidRootPart") then
        character.HumanoidRootPart.CFrame = newCF
    end
end

function CFrameModule:Spin(character)
    if self.Settings.Enabled and character then
        local root = character:FindFirstChild("HumanoidRootPart")
        if root then
            local rotation = CFrame.Angles(0, math.rad(self.Settings.Speed * 10), 0)
            root.CFrame = root.CFrame * rotation
        end
    end
end

function CFrameModule:Float(character)
    if self.Settings.Enabled and character then
        local root = character:FindFirstChild("HumanoidRootPart")
        if root then
            root.CFrame = CFrame.new(root.Position) + Vector3.new(0, self.Settings.Height, 0)
        end
    end
end

return CFrameModule
