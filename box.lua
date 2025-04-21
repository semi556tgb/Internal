local Box = {
    Enabled = false,
    TeamCheck = false,
    MaxDistance = 200,
    FadeOut = {
        OnDistance = true,
        OnDeath = false,
        OnLeave = false,
    },
    Drawing = {
        Boxes = {
            Animate = true,
            RotationSpeed = 300,
            Gradient = false,
            GradientRGB1 = Color3.fromRGB(119, 120, 255),
            GradientRGB2 = Color3.fromRGB(0, 0, 0),
            GradientFill = true,
            GradientFillRGB1 = Color3.fromRGB(119, 120, 255),
            GradientFillRGB2 = Color3.fromRGB(0, 0, 0),
            Filled = {
                Enabled = true,
                Transparency = 0.75,
                RGB = Color3.fromRGB(0, 0, 0),
            },
            Full = {
                Enabled = false,
                RGB = Color3.fromRGB(255, 255, 255),
            },
            Corner = {
                Enabled = false,
                RGB = Color3.fromRGB(255, 255, 255),
            },
        }
    },
    Connections = {
        RunService = cloneref(game:GetService("RunService"))
    },
    Fonts = {}
}

function Box.Init()
    local RunService = Box.Connections.RunService
    local Players = cloneref(game:GetService("Players"))
    local CoreGui = game:GetService("CoreGui")
    local Workspace = cloneref(game:GetService("Workspace"))
    local lplayer = Players.LocalPlayer
    local Cam = Workspace.CurrentCamera
    local RotationAngle, Tick = -45, tick()

    -- Load functions from GitHub
    local success, Functions = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/semi556tgb/Internal/refs/heads/main/box.lua"))()
    end)

    if not success then
        warn("Failed to load ESP functions from GitHub:", Functions)
        return false
    end

    -- Initialize ESP with loaded functions
    local ScreenGui = Functions:Create("ScreenGui", {
        Parent = CoreGui,
        Name = "ESPHolder",
    })

    local ESP_Handler = {}
    ESP_Handler.__index = ESP_Handler

    function ESP_Handler.new(player)
        local self = setmetatable({}, ESP_Handler)
        self.Player = player
        self.Character = player.Character
        self.Lines = {
            Top = Functions:Create("Line", {Visible = false, Thickness = 1, Transparency = 1}),
            Bottom = Functions:Create("Line", {Visible = false, Thickness = 1, Transparency = 1}),
            Left = Functions:Create("Line", {Visible = false, Thickness = 1, Transparency = 1}),
            Right = Functions:Create("Line", {Visible = false, Thickness = 1, Transparency = 1})
        }
        self.Connections = {}
        
        self:Setup()
        return self
    end

    function ESP_Handler:Setup()
        self.Connections.CharacterAdded = self.Player.CharacterAdded:Connect(function(char)
            self.Character = char
        end)
        
        self.Connections.Update = RunService.RenderStepped:Connect(function()
            self:Update()
        end)
    end

    function ESP_Handler:Update()
        if not Box.Enabled then
            self:Hide()
            return
        end

        if not self.Character or not Functions:IsAlive(self.Character) then
            self:Hide()
            return
        end

        local rootPart = self.Character:FindFirstChild("HumanoidRootPart")
        if not rootPart then
            self:Hide()
            return
        end

        local distance = Functions:GetDistanceFromCharacter(rootPart.Position)
        if distance > Box.MaxDistance then
            self:Hide()
            return
        end

        if Box.TeamCheck and self.Player.Team == Players.LocalPlayer.Team then
            self:Hide()
            return
        end

        local boxCFrame = rootPart.CFrame
        local size = self.Character:GetExtentsSize()
        
        local corners = {
            Vector3.new(-size.X/2, size.Y/2, 0),
            Vector3.new(size.X/2, size.Y/2, 0),
            Vector3.new(-size.X/2, -size.Y/2, 0),
            Vector3.new(size.X/2, -size.Y/2, 0)
        }

        local points = {}
        for _, corner in ipairs(corners) do
            local worldPoint = boxCFrame * corner
            local screenPoint, onScreen = Workspace.CurrentCamera:WorldToScreenPoint(worldPoint)
            if not onScreen then
                self:Hide()
                return
            end
            table.insert(points, Vector2.new(screenPoint.X, screenPoint.Y))
        end

        -- Update lines
        self.Lines.Top.From = points[1]
        self.Lines.Top.To = points[2]
        self.Lines.Bottom.From = points[3]
        self.Lines.Bottom.To = points[4]
        self.Lines.Left.From = points[1]
        self.Lines.Left.To = points[3]
        self.Lines.Right.From = points[2]
        self.Lines.Right.To = points[4]

        -- Apply settings
        for _, line in pairs(self.Lines) do
            line.Visible = true
            if Box.Drawing.Boxes.Gradient then
                line.Color = Box.Drawing.Boxes.GradientRGB1:Lerp(
                    Box.Drawing.Boxes.GradientRGB2,
                    math.sin(tick() * Box.Drawing.Boxes.RotationSpeed / 1000) * 0.5 + 0.5
                )
            else
                line.Color = Box.Drawing.Boxes.Full.RGB
            end
        end
    end

    function ESP_Handler:Hide()
        for _, line in pairs(self.Lines) do
            line.Visible = false
        end
    end

    function ESP_Handler:Destroy()
        for _, connection in pairs(self.Connections) do
            connection:Disconnect()
        end
        for _, line in pairs(self.Lines) do
            line:Remove()
        end
    end

    -- Initialize ESP for all players
    local espHandlers = {}
    
    local function onPlayerAdded(player)
        if player ~= Players.LocalPlayer then
            espHandlers[player] = ESP_Handler.new(player)
        end
    end

    local function onPlayerRemoving(player)
        if espHandlers[player] then
            espHandlers[player]:Destroy()
            espHandlers[player] = nil
        end
    end

    for _, player in ipairs(Players:GetPlayers()) do
        onPlayerAdded(player)
    end

    Players.PlayerAdded:Connect(onPlayerAdded)
    Players.PlayerRemoving:Connect(onPlayerRemoving)
end

return Box
