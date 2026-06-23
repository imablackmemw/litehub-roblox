-- ==============================================================================
-- 🚀 LITEHUB FLY PACK PRO (MOBILE CAMERA-DIR EDITION)
-- ==============================================================================
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local NameID = "LiteHub_FlyPackPRO"

if CoreGui:FindFirstChild(NameID) then CoreGui[NameID]:Destroy() end

local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = NameID

-- ==============================================================================
-- 🎛️ МИКРО-МЕНЮ (ДЛЯ УГЛА ЭКРАНА)
-- ==============================================================================
local MiniMenu = Instance.new("Frame", ScreenGui)
MiniMenu.Size = UDim2.new(0, 140, 0, 95)
MiniMenu.Position = UDim2.new(0, 15, 0, 100) -- Левый верхний угол
MiniMenu.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MiniMenu.Active = true
MiniMenu.Draggable = true
Instance.new("UICorner", MiniMenu).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel", MiniMenu)
Title.Size = UDim2.new(1, 0, 0, 25)
Title.Text = "✈️ Fly Manager"
Title.TextColor3 = Color3.fromRGB(200, 200, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 12
Title.BackgroundTransparency = 1

local FlyToggleBtn = Instance.new("TextButton", MiniMenu)
FlyToggleBtn.Size = UDim2.new(0.9, 0, 0, 28)
FlyToggleBtn.Position = UDim2.new(0.05, 0, 0, 25)
FlyToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
FlyToggleBtn.Text = "Fly: ВЫКЛ"
FlyToggleBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
FlyToggleBtn.Font = Enum.Font.GothamBold
FlyToggleBtn.TextSize = 12
Instance.new("UICorner", FlyToggleBtn).CornerRadius = UDim.new(0, 5)

local SpeedBtn = Instance.new("TextButton", MiniMenu)
SpeedBtn.Size = UDim2.new(0.9, 0, 0, 28)
SpeedBtn.Position = UDim2.new(0.05, 0, 0, 58)
SpeedBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
SpeedBtn.Text = "Speed: 50"
SpeedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedBtn.Font = Enum.Font.GothamBold
SpeedBtn.TextSize = 12
Instance.new("UICorner", SpeedBtn).CornerRadius = UDim.new(0, 5)

-- ==============================================================================
-- 🔼🔽 КНОПКИ UP И DOWN (СПРАВА ВОЗЛЕ ПРЫЖКА)
-- ==============================================================================
local function CreateDirButton(text, yPos)
    local btn = Instance.new("TextButton", ScreenGui)
    btn.Size = UDim2.new(0, 55, 0, 55)
    btn.Position = UDim2.new(1, -85, 1, yPos) -- Справа внизу
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    btn.BackgroundTransparency = 0.3
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 18
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
    return btn
end

local UpBtn = CreateDirButton("UP", -230)
local DownBtn = CreateDirButton("DOWN", -160)

UpBtn.Visible = false
DownBtn.Visible = false

-- ==============================================================================
-- ⚙️ ЛОГИКА ПОЛЕТА И NOCLIP
-- ==============================================================================
local isFlying = false
local flySpeed = 50
local upPressed = false
local downPressed = false
local bodyGyro, bodyVel

-- Смена скорости
local speeds = {30, 50, 100, 150}
local speedIdx = 2
SpeedBtn.MouseButton1Click:Connect(function()
    speedIdx = speedIdx + 1
    if speedIdx > #speeds then speedIdx = 1 end
    flySpeed = speeds[speedIdx]
    SpeedBtn.Text = "Speed: " .. flySpeed
end)

-- Обработка кнопок UP / DOWN
local function bindBtn(btn, isUp)
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if isUp then upPressed = true else downPressed = true end
            btn.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
        end
    end)
    btn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if isUp then upPressed = false else downPressed = false end
            btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        end
    end)
    btn.MouseLeave:Connect(function()
        if isUp then upPressed = false else downPressed = false end
        btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    end)
end
bindBtn(UpBtn, true)
bindBtn(DownBtn, false)

-- ВКЛ/ВЫКЛ Полета
FlyToggleBtn.MouseButton1Click:Connect(function()
    isFlying = not isFlying
    local char = Player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    if isFlying then
        FlyToggleBtn.Text = "Fly: ВКЛ"
        FlyToggleBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
        UpBtn.Visible = true
        DownBtn.Visible = true

        char.Humanoid.PlatformStand = true
        
        bodyGyro = Instance.new("BodyGyro", char.HumanoidRootPart)
        bodyGyro.P = 9e4
        bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        bodyGyro.CFrame = char.HumanoidRootPart.CFrame

        bodyVel = Instance.new("BodyVelocity", char.HumanoidRootPart)
        bodyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bodyVel.Velocity = Vector3.zero
    else
        FlyToggleBtn.Text = "Fly: ВЫКЛ"
        FlyToggleBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
        UpBtn.Visible = false
        DownBtn.Visible = false

        char.Humanoid.PlatformStand = false
        if bodyGyro then bodyGyro:Destroy() end
        if bodyVel then bodyVel:Destroy() end
    end
end)

-- Движок полета (куда смотрим + джойстик)
RunService.RenderStepped:Connect(function()
    if isFlying and Player.Character and bodyGyro and bodyVel then
        local cam = workspace.CurrentCamera
        local humanoid = Player.Character:FindFirstChild("Humanoid")
        
        -- Поворачиваем перса туда, куда смотрит камера
        bodyGyro.CFrame = cam.CFrame
        
        local moveDir = Vector3.zero
        if humanoid and humanoid.MoveDirection.Magnitude > 0 then
            -- Высчитываем направление мобильного джойстика относительно камеры
            local camXZ = (cam.CFrame.LookVector * Vector3.new(1, 0, 1)).Unit
            local dotFwd = camXZ:Dot(humanoid.MoveDirection)
            local dotRight = cam.CFrame.RightVector:Dot(humanoid.MoveDirection)
            
            -- Теперь летим реально туда, куда направлена камера (включая небо и землю)
            moveDir = (cam.CFrame.LookVector * dotFwd) + (cam.CFrame.RightVector * dotRight)
        end

        -- Добавляем кнопки UP и DOWN
        if upPressed then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if downPressed then moveDir = moveDir + Vector3.new(0, -1, 0) end

        -- Применяем скорость
        if moveDir.Magnitude > 0 then
            bodyVel.Velocity = moveDir.Unit * flySpeed
        else
            bodyVel.Velocity = Vector3.zero
        end
    end
end)

-- Движок Noclip (работает только в полете)
RunService.Stepped:Connect(function()
    if isFlying and Player.Character then
        for _, v in pairs(Player.Character:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    end
end)

print("LiteHub Fly Pack PRO Загружен!")
