local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local Box = {
    Enabled = false,
    Drawing = {
        Boxes = {
            Full = {
                Enabled = false,
                RGB = Color3.fromRGB(255, 255, 255)
            },
            Corner = {
                Enabled = false,
                RGB = Color3.fromRGB(255, 255, 255)
            }
        }
    }
}

local espFolder = Instance.new("Folder")
espFolder.Name = "ESPHolder"
espFolder.Parent = CoreGui

local function createBox(player)
    -- Create ESP elements for a player
    local boxGui = Instance.new("ScreenGui", espFolder)
    boxGui.Name = player.Name
    
    -- Create box elements
    local fullBox = Instance.new("Frame", boxGui)
    fullBox.BackgroundTransparency = 1
    fullBox.BorderSizePixel = 1
    fullBox.BorderColor3 = Box.Drawing.Boxes.Full.RGB
    
    -- Create corner boxes
    local corners = {}
    for i = 1,8 do
        corners[i] = Instance.new("Frame", boxGui)
        corners[i].BackgroundColor3 = Box.Drawing.Boxes.Corner.RGB
        corners[i].BorderSizePixel = 0
        corners[i].Size = UDim2.new(0, 1, 0, 5)
    end
    
    -- Update loop
    RunService.RenderStepped:Connect(function()
        if not Box.Enabled then
            boxGui.Enabled = false
            return
        end
        
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            local cam = Workspace.CurrentCamera
            local pos, onScreen = cam:WorldToViewportPoint(hrp.Position)
            
            if onScreen then
                boxGui.Enabled = true
                
                -- Update box positions and sizes
                local size = Vector2.new(40, 60)
                fullBox.Position = UDim2.new(0, pos.X - size.X/2, 0, pos.Y - size.Y/2)
                fullBox.Size = UDim2.new(0, size.X, 0, size.Y)
                fullBox.Visible = Box.Drawing.Boxes.Full.Enabled
                
                -- Update corner positions
                if Box.Drawing.Boxes.Corner.Enabled then
                    -- Update corner positions here
                end
            else
                boxGui.Enabled = false
            end
        else
            boxGui.Enabled = false
        end
    end)
end

function Box.Init()
    -- Set up ESP for existing players
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer then
            createBox(player)
        end
    end
    
    -- Handle new players
    Players.PlayerAdded:Connect(createBox)
    
    -- Clean up when players leave
    Players.PlayerRemoving:Connect(function(player)
        local boxGui = espFolder:FindFirstChild(player.Name)
        if boxGui then boxGui:Destroy() end
    end)
end

return Box
