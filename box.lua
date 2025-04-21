local Workspace = cloneref(game:GetService("Workspace"))
local RunService = cloneref(game:GetService("RunService"))
local Players = cloneref(game:GetService("Players"))
local CoreGui = game:GetService("CoreGui")

local ESP = {
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
            Gradient = false, GradientRGB1 = Color3.fromRGB(119, 120, 255), GradientRGB2 = Color3.fromRGB(0, 0, 0),
            GradientFill = true, GradientFillRGB1 = Color3.fromRGB(119, 120, 255), GradientFillRGB2 = Color3.fromRGB(0, 0, 0),
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
        RunService = RunService
    }
}

local Functions = {}
do
    function Functions:Create(Class, Properties)
        local _Instance = typeof(Class) == 'string' and Instance.new(Class) or Class
        for Property, Value in pairs(Properties) do
            _Instance[Property] = Value
        end
        return _Instance
    end

    function Functions:FadeOutOnDist(element, distance)
        local transparency = math.max(0.1, 1 - (distance / ESP.MaxDistance))
        if element:IsA("TextLabel") then
            element.TextTransparency = 1 - transparency
        elseif element:IsA("ImageLabel") then
            element.ImageTransparency = 1 - transparency
        elseif element:IsA("UIStroke") then
            element.Transparency = 1 - transparency
        elseif element:IsA("Frame") then
            element.BackgroundTransparency = 1 - transparency
        elseif element:IsA("Highlight") then
            element.FillTransparency = 1 - transparency
            element.OutlineTransparency = 1 - transparency
        end
    end
end

-- Initialize ESP
local ScreenGui = Functions:Create("ScreenGui", {
    Parent = CoreGui,
    Name = "ESPHolder",
})

local lplayer = Players.LocalPlayer
local Cam = Workspace.CurrentCamera
local RotationAngle, Tick = -45, tick()

-- Add update delay to reduce detection
local _rand = Random.new()
local _lastUpdate = tick()
local _updateDelay = 0.03 -- 30ms delay between updates
local _jitterRange = 0.01 -- Add small random delay

local function DupeCheck(plr)
    if ScreenGui:FindFirstChild(plr.Name) then
        ScreenGui[plr.Name]:Destroy()
    end
end

local function ESP_Handler(plr)
    coroutine.wrap(DupeCheck)(plr)
    
    local Container = Functions:Create("Folder", {
        Parent = ScreenGui,
        Name = plr.Name
    })

    local Box = Functions:Create("Frame", {
        Parent = Container,
        Name = "Box",
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.75,
        BorderSizePixel = 0
    })

    local Gradient1 = Functions:Create("UIGradient", {
        Parent = Box, 
        Enabled = ESP.Drawing.Boxes.GradientFill, 
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, ESP.Drawing.Boxes.GradientFillRGB1), 
            ColorSequenceKeypoint.new(1, ESP.Drawing.Boxes.GradientFillRGB2)
        }
    })

    local Outline = Functions:Create("UIStroke", {
        Parent = Box, 
        Enabled = ESP.Drawing.Boxes.Gradient, 
        Transparency = 0, 
        Color = Color3.fromRGB(255, 255, 255), 
        LineJoinMode = Enum.LineJoinMode.Miter
    })

    local Gradient2 = Functions:Create("UIGradient", {
        Parent = Outline, 
        Enabled = ESP.Drawing.Boxes.Gradient, 
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, ESP.Drawing.Boxes.GradientRGB1), 
            ColorSequenceKeypoint.new(1, ESP.Drawing.Boxes.GradientRGB2)
        }
    })

    -- Corner pieces
    local CornerPieces = {
        LeftTop = Functions:Create("Frame", {Parent = Container, BackgroundColor3 = ESP.Drawing.Boxes.Corner.RGB}),
        LeftSide = Functions:Create("Frame", {Parent = Container, BackgroundColor3 = ESP.Drawing.Boxes.Corner.RGB}),
        RightTop = Functions:Create("Frame", {Parent = Container, BackgroundColor3 = ESP.Drawing.Boxes.Corner.RGB}),
        RightSide = Functions:Create("Frame", {Parent = Container, BackgroundColor3 = ESP.Drawing.Boxes.Corner.RGB}),
        BottomSide = Functions:Create("Frame", {Parent = Container, BackgroundColor3 = ESP.Drawing.Boxes.Corner.RGB}),
        BottomDown = Functions:Create("Frame", {Parent = Container, BackgroundColor3 = ESP.Drawing.Boxes.Corner.RGB}),
        BottomRightSide = Functions:Create("Frame", {Parent = Container, BackgroundColor3 = ESP.Drawing.Boxes.Corner.RGB}),
        BottomRightDown = Functions:Create("Frame", {Parent = Container, BackgroundColor3 = ESP.Drawing.Boxes.Corner.RGB})
    }

    local function UpdateESP()
        local Connection

        local function HideESP()
            if Container and Container.Parent then
                for _, element in ipairs(Container:GetChildren()) do
                    element.Visible = false
                end
            end
        end

        Connection = RunService.Heartbeat:Connect(function() -- Use Heartbeat instead of RenderStepped
            local _now = tick()
            if _now - _lastUpdate < _updateDelay + _rand:NextNumber(-_jitterRange, _jitterRange) then 
                return 
            end
            _lastUpdate = _now

            -- Cache character reference
            local _char = plr.Character
            if not _char then return end
            
            local _root = _char:FindFirstChild("HumanoidRootPart")
            if not _root then return end

            -- Use less detectable position calculation
            local _pos = _root.CFrame.Position
            local _cam = Cam.CFrame
            local _dist = (_cam.Position - _pos).Magnitude
            
            if _dist > ESP.MaxDistance then
                HideESP()
                return
            end

            local _screen, _onScreen = Cam.WorldToScreenPoint(Cam, _pos)

            if not _onScreen then
                HideESP()
                return
            end

            local shouldDrawBoxes = _onScreen and _dist <= ESP.MaxDistance and 
                (not ESP.TeamCheck or plr ~= lplayer and (not plr.Team or not lplayer.Team or plr.Team ~= lplayer.Team))

            -- Update visibility
            Box.Visible = shouldDrawBoxes and ESP.Drawing.Boxes.Full.Enabled
            for _, corner in pairs(CornerPieces) do
                corner.Visible = shouldDrawBoxes and ESP.Drawing.Boxes.Corner.Enabled
            end

            if shouldDrawBoxes then
                if ESP.FadeOut.OnDistance then
                    Functions:FadeOutOnDist(Box, _dist)
                    Functions:FadeOutOnDist(Outline, _dist)
                    for _, corner in pairs(CornerPieces) do
                        Functions:FadeOutOnDist(corner, _dist)
                    end
                end

                local Size = _root.Size.Y
                local scaleFactor = (Size * Cam.ViewportSize.Y) / (_screen.Z * 2)
                local w, h = 3 * scaleFactor, 4.5 * scaleFactor

                -- Update corner positions
                CornerPieces.LeftTop.Position = UDim2.new(0, _screen.X - w/2, 0, _screen.Y - h/2)
                CornerPieces.LeftTop.Size = UDim2.new(0, w/5, 0, 1)

                CornerPieces.LeftSide.Position = UDim2.new(0, _screen.X - w/2, 0, _screen.Y - h/2)
                CornerPieces.LeftSide.Size = UDim2.new(0, 1, 0, h/5)

                CornerPieces.BottomSide.Position = UDim2.new(0, _screen.X - w/2, 0, _screen.Y + h/2)
                CornerPieces.BottomSide.Size = UDim2.new(0, 1, 0, h/5)
                CornerPieces.BottomSide.AnchorPoint = Vector2.new(0, 5)

                CornerPieces.BottomDown.Position = UDim2.new(0, _screen.X - w/2, 0, _screen.Y + h/2)
                CornerPieces.BottomDown.Size = UDim2.new(0, w/5, 0, 1)
                CornerPieces.BottomDown.AnchorPoint = Vector2.new(0, 1)

                CornerPieces.RightTop.Position = UDim2.new(0, _screen.X + w/2, 0, _screen.Y - h/2)
                CornerPieces.RightTop.Size = UDim2.new(0, w/5, 0, 1)
                CornerPieces.RightTop.AnchorPoint = Vector2.new(1, 0)

                CornerPieces.RightSide.Position = UDim2.new(0, _screen.X + w/2 - 1, 0, _screen.Y - h/2)
                CornerPieces.RightSide.Size = UDim2.new(0, 1, 0, h/5)

                CornerPieces.BottomRightSide.Position = UDim2.new(0, _screen.X + w/2, 0, _screen.Y + h/2)
                CornerPieces.BottomRightSide.Size = UDim2.new(0, 1, 0, h/5)
                CornerPieces.BottomRightSide.AnchorPoint = Vector2.new(1, 1)

                CornerPieces.BottomRightDown.Position = UDim2.new(0, _screen.X + w/2, 0, _screen.Y + h/2)
                CornerPieces.BottomRightDown.Size = UDim2.new(0, w/5, 0, 1)
                CornerPieces.BottomRightDown.AnchorPoint = Vector2.new(1, 1)

                -- Update box
                Box.Position = UDim2.new(0, _screen.X - w/2, 0, _screen.Y - h/2)
                Box.Size = UDim2.new(0, w, 0, h)

                if ESP.Drawing.Boxes.Filled.Enabled then
                    Box.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    Box.BackgroundTransparency = ESP.Drawing.Boxes.GradientFill and ESP.Drawing.Boxes.Filled.Transparency or 1
                    Box.BorderSizePixel = 1
                else
                    Box.BackgroundTransparency = 1
                end

                -- Update gradients
                RotationAngle = RotationAngle + (tick() - Tick) * ESP.Drawing.Boxes.RotationSpeed * math.cos(math.pi/4 * tick() - math.pi/2)
                if ESP.Drawing.Boxes.Animate then
                    Gradient1.Rotation = RotationAngle
                    Gradient2.Rotation = RotationAngle
                else
                    Gradient1.Rotation = -45
                    Gradient2.Rotation = -45
                end
                Tick = tick()
            end
        end)

        Players.PlayerRemoving:Connect(function(player)
            if player == plr and Container and Container.Parent then
                Container:Destroy()
                if Connection then Connection:Disconnect() end
            end
        end)
    end
    
    coroutine.wrap(UpdateESP)()
end

-- Initialize ESP for existing players
if ScreenGui:FindFirstChild("ESPHolder") then
    ScreenGui:FindFirstChild("ESPHolder"):Destroy()
end

for _, v in pairs(Players:GetPlayers()) do
    if v ~= lplayer then
        pcall(function()
            coroutine.wrap(ESP_Handler)(v)
        end)
    end
end

-- Handle new players
Players.PlayerAdded:Connect(function(v)
    if v ~= lplayer then
        pcall(function()
            coroutine.wrap(ESP_Handler)(v)
        end)
    end
end)

function ESP:UpdateColors(boxColor, fillColor)
    ESP.Drawing.Boxes.Full.RGB = boxColor
    ESP.Drawing.Boxes.Corner.RGB = boxColor
    ESP.Drawing.Boxes.Filled.RGB = fillColor
    
    -- Update existing boxes
    for _, container in pairs(ScreenGui:GetChildren()) do
        if container:IsA("Folder") then
            -- Update box fill
            local box = container:FindFirstChild("Box")
            if box then
                box.BackgroundColor3 = fillColor
            end
            
            -- Update box outline
            local outline = box and box:FindFirstChildOfClass("UIStroke")
            if outline then
                outline.Color = boxColor
            end
            
            -- Update corner pieces
            for _, corner in pairs(container:GetChildren()) do
                if corner:IsA("Frame") and corner.Name ~= "Box" then
                    corner.BackgroundColor3 = boxColor
                end
            end
        end
    end
end

return ESP
