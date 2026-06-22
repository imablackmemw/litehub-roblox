-- ==============================================================================
-- 🚀 LITEXUTOR FLY v1.0 PRO
-- Кастомный мобильный Fly с UI, управлением скоростью и плавным полётом!
-- ==============================================================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Настройки полёта
local FlySpeed = 50
local IsFlying = false
local UpValue = 0
local DownValue = 0

local BG = nil -- BodyGyro (Поворот)
local BV = nil -- BodyVelocity (Движение)
local FlyConnection = nil

-- Защита от двойного запуска
if CoreGui:FindFirstChild("LitexutorFlyPRO") then
    CoreGui.LitexutorFlyPRO:Destroy()
end

-- ==============================================================================
-- 🎨 СОЗДАНИЕ ИНТЕРФЕЙСА (UI)
-- ==============================================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LitexutorFlyPRO"
ScreenGui.ResetOnSpawn = false
local success = pcall(function() ScreenGui.Parent = CoreGui end)
if not success then ScreenGui.Parent = Player:WaitForChild("PlayerGui") end

-- 1. ЛЕТАЮЩАЯ КНОПКА-КРУЖОК (Toggle Fly Menu)
local ToggleMenuBtn = Instance.new("TextButton")
local ToggleMenuCorner = Instance.new("UICorner")

ToggleMenuBtn.Name = "FlyMenuToggle"
ToggleMenuBtn.Parent = ScreenGui
ToggleMenuBtn.Size = UDim2.new(0, 60, 0, 60)
ToggleMenuBtn.Position = UDim2.new(0, 20, 0, 220)
ToggleMenuBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 200)
ToggleMenuBtn.Text = "FLY\nMENU"
ToggleMenuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleMenuBtn.Font = Enum.Font.GothamBold
ToggleMenuBtn.TextSize = 12
ToggleMenuBtn.Active = true
ToggleMenuBtn.Draggable = true

ToggleMenuCorner.CornerRadius = UDim.new(1, 0)
ToggleMenuCorner.Parent = ToggleMenuBtn

-- 2. ГЛАВНОЕ МЕНЮ (Fly GUI)
local MainFrame = Instance.new("Frame")
local MainCorner = Instance.new("UICorner")

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 300, 0, 220)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -110)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true

MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

-- ВЕРХНЯЯ ПАНЕЛЬ (Header)
local Header = Instance.new("Frame")
local HeaderCorner = Instance.new("UICorner")
local Title = Instance.new("TextLabel")
local CloseBtn = Instance.new("TextButton")

Header.Name = "Header"
Header.Parent = MainFrame
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(35, 35, 35)

HeaderCorner.CornerRadius = UDim.new(0, 10)
HeaderCorner.Parent = Header

local HeaderFix = Instance.new("Frame")
HeaderFix.Parent = Header
HeaderFix.Size = UDim2.new(1, 0, 0, 10)
HeaderFix.Position = UDim2.new(0, 0, 1, -10)
HeaderFix.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
HeaderFix.BorderSizePixel = 0

Title.Parent = Header
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Litexutor Fly PRO"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left

CloseBtn.Parent = Header
CloseBtn.Size = UDim2.new(0, 40, 0, 40)
CloseBtn.Position = UDim2.new(1, -40, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18

-- 3. КНОПКА ВКЛ/ВЫКЛ ПОЛЁТА
local ToggleFlyBtn = Instance.new("TextButton")
local ToggleFlyCorner = Instance.new("UICorner")

ToggleFlyBtn.Parent = MainFrame
ToggleFlyBtn.Size = UDim2.new(1, -40, 0, 45)
ToggleFlyBtn.Position = UDim2.new(0, 20, 0, 60)
ToggleFlyBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60) -- По умолчанию красный (ВЫКЛ)
ToggleFlyBtn.Text = "FLY: OFF"
ToggleFlyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleFlyBtn.Font = Enum.Font.GothamBold
ToggleFlyBtn.TextSize = 18

ToggleFlyCorner.CornerRadius = UDim.new(0, 8)
ToggleFlyCorner.Parent = ToggleFlyBtn

-- 4. ПАНЕЛЬ СКОРОСТИ
local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Parent = MainFrame
SpeedLabel.Size = UDim2.new(1, 0, 0, 20)
SpeedLabel.Position = UDim2.new(0, 0, 0, 120)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "Скорость полёта"
SpeedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
SpeedLabel.Font = Enum.Font.GothamSemibold
SpeedLabel.TextSize = 14

local MinusBtn = Instance.new("TextButton")
local SpeedBox = Instance.new("TextBox")
local PlusBtn = Instance.new("TextButton")

-- Кнопка Минус
MinusBtn.Parent = MainFrame
MinusBtn.Size = UDim2.new(0, 40, 0, 40)
MinusBtn.Position = UDim2.new(0, 40, 0, 150)
MinusBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
MinusBtn.Text = "-"
MinusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinusBtn.Font = Enum.Font.GothamBold
MinusBtn.TextSize = 20
Instance.new("UICorner").Parent = MinusBtn

-- Текстовое поле для ввода скорости
SpeedBox.Parent = MainFrame
SpeedBox.Size = UDim2.new(0, 100, 0, 40)
SpeedBox.Position = UDim2.new(0, 100, 0, 150)
SpeedBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SpeedBox.Text = tostring(FlySpeed)
SpeedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedBox.Font = Enum.Font.GothamBold
SpeedBox.TextSize = 18
SpeedBox.ClearTextOnFocus = false
Instance.new("UICorner").Parent = SpeedBox

-- Кнопка Плюс
PlusBtn.Parent = MainFrame
PlusBtn.Size = UDim2.new(0, 40, 0, 40)
PlusBtn.Position = UDim2.new(0, 220, 0, 150)
PlusBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
PlusBtn.Text = "+"
PlusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
PlusBtn.Font = Enum.Font.GothamBold
PlusBtn.TextSize = 20
Instance.new("UICorner").Parent = PlusBtn

-- 5. КНОПКИ ВЫСОТЫ НА ЭКРАНЕ (UP / DOWN)
-- Они висят отдельно от меню, чтобы было удобно нажимать пальцем во время игры
local UpBtn = Instance.new("TextButton")
local DownBtn = Instance.new("TextButton")

UpBtn.Parent = ScreenGui
UpBtn.Size = UDim2.new(0, 60, 0, 60)
UpBtn.Position = UDim2.new(1, -80, 0.5, -70)
UpBtn.BackgroundColor3 = Color3.fromRGB(60, 200, 100)
UpBtn.Text = "UP\n▲"
UpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
UpBtn.Font = Enum.Font.GothamBold
UpBtn.TextSize = 14
UpBtn.BackgroundTransparency = 0.3
Instance.new("UICorner", UpBtn).CornerRadius = UDim.new(1, 0)
UpBtn.Visible = false

DownBtn.Parent = ScreenGui
DownBtn.Size = UDim2.new(0, 60, 0, 60)
DownBtn.Position = UDim2.new(1, -80, 0.5, 10)
DownBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 60)
DownBtn.Text = "DOWN\n▼"
DownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
DownBtn.Font = Enum.Font.GothamBold
DownBtn.TextSize = 14
DownBtn.BackgroundTransparency = 0.3
Instance.new("UICorner", DownBtn).CornerRadius = UDim.new(1, 0)
DownBtn.Visible = false

-- ==============================================================================
-- ⚙️ ЛОГИКА ИНТЕРФЕЙСА
-- ==============================================================================

-- Открытие / Закрытие главного меню
ToggleMenuBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Крестик (сворачивает в кружок)
CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

-- Логика изменения скорости
local function UpdateSpeed(newSpeed)
    FlySpeed = newSpeed
    SpeedBox.Text = tostring(FlySpeed)
end

MinusBtn.MouseButton1Click:Connect(function()
    UpdateSpeed(math.max(0, FlySpeed - 10))
end)

PlusBtn.MouseButton1Click:Connect(function()
    UpdateSpeed(FlySpeed + 10)
end)

-- Ввод скорости вручную (TextBox)
SpeedBox.FocusLost:Connect(function()
    local inputNum = tonumber(SpeedBox.Text)
    if inputNum then
        UpdateSpeed(inputNum)
    else
        UpdateSpeed(FlySpeed) -- Возвращаем старое, если ввели буквы
    end
end)

-- ==============================================================================
-- 🚁 ЛОГИКА ПОЛЁТА (ENGINE)
-- ==============================================================================

local function StartFly()
    local Char = Player.Character
    if not Char or not Char:FindFirstChild("HumanoidRootPart") or not Char:FindFirstChild("Humanoid") then return end
    
    local HRP = Char.HumanoidRootPart
    
    -- Очищаем старые муверы на всякий случай
    if BG then BG:Destroy() end
    if BV then BV:Destroy() end
    
    -- Создаем гироскоп для поворота
    BG = Instance.new("BodyGyro")
    BG.P = 90000
    BG.MaxTorque = Vector3.new(900000, 900000, 900000)
    BG.CFrame = HRP.CFrame
    BG.Parent = HRP
    
    -- Создаем велосити для движения
    BV = Instance.new("BodyVelocity")
    BV.Velocity = Vector3.new(0, 0, 0)
    BV.MaxForce = Vector3.new(900000, 900000, 900000)
    BV.Parent = HRP
    
    -- Запускаем цикл полёта
    FlyConnection = RunService.RenderStepped:Connect(function()
        if Char:FindFirstChild("Humanoid") and Char.Humanoid.Health > 0 then
            -- Поворачиваем персонажа туда, куда смотрит камера
            BG.CFrame = Camera.CFrame
            
            -- Вычисляем направление джойстика
            local MoveDir = Char.Humanoid.MoveDirection
            
            -- Вычисляем вертикальную скорость (кнопки UP/DOWN)
            local VerticalVelocity = Vector3.new(0, (UpValue + DownValue) * FlySpeed, 0)
            
            -- Итоговое движение = (Движение джойстика * Скорость) + Вертикальное движение
            BV.Velocity = (MoveDir * FlySpeed) + VerticalVelocity
        else
            -- Если умер, выключаем Fly
            ToggleFlyBtn.MouseButton1Click:Fire()
        end
    end)
    
    -- Отключаем падение персонажа
    Char.Humanoid.PlatformStand = true
end

local function StopFly()
    local Char = Player.Character
    if FlyConnection then FlyConnection:Disconnect() end
    if BG then BG:Destroy() end
    if BV then BV:Destroy() end
    
    if Char and Char:FindFirstChild("Humanoid") then
        Char.Humanoid.PlatformStand = false
    end
end

-- Кнопка ВКЛ/ВЫКЛ Fly
ToggleFlyBtn.MouseButton1Click:Connect(function()
    IsFlying = not IsFlying
    if IsFlying then
        ToggleFlyBtn.Text = "FLY: ON"
        ToggleFlyBtn.BackgroundColor3 = Color3.fromRGB(60, 200, 60)
        UpBtn.Visible = true
        DownBtn.Visible = true
        StartFly()
    else
        ToggleFlyBtn.Text = "FLY: OFF"
        ToggleFlyBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
        UpBtn.Visible = false
        DownBtn.Visible = false
        StopFly()
    end
end)

-- Логика кнопок высоты (Зажал - летишь, отпустил - остановился)
UpBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        UpValue = 1
        UpBtn.BackgroundTransparency = 0
    end
end)
UpBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        UpValue = 0
        UpBtn.BackgroundTransparency = 0.3
    end
end)

DownBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        DownValue = -1
        DownBtn.BackgroundTransparency = 0
    end
end)
DownBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        DownValue = 0
        DownBtn.BackgroundTransparency = 0.3
    end
end)

-- Защита при ресете/смерти: сброс состояния
Player.CharacterAdded:Connect(function()
    if IsFlying then
        IsFlying = false
        ToggleFlyBtn.Text = "FLY: OFF"
        ToggleFlyBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
        UpBtn.Visible = false
        DownBtn.Visible = false
        if FlyConnection then FlyConnection:Disconnect() end
    end
end)

print("LITEXUTOR FLY PRO ЗАГРУЖЕН!")

