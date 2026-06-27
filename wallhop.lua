-- Инициализация сервисов
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Создаем GUI (Кнопку)
local ScreenGui = Instance.new("ScreenGui")
local ToggleButton = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")

ScreenGui.Parent = game:CoreGui -- Прячем в CoreGui, чтобы админы игры не спалили через обычный UI
ScreenGui.Name = "WallhopCheat"

-- Настройка внешнего вида кнопки
ToggleButton.Parent = ScreenGui
ToggleButton.Size = UDim2.new(0, 80, 0, 40)
ToggleButton.Position = UDim2.new(0.1, 0, 0.5, 0) -- Начальная позиция
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 75, 75) -- Красный (OFF)
ToggleButton.Text = "OFF"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 18
ToggleButton.Active = true

UICorner.Parent = ToggleButton
UICorner.CornerRadius = UDim.new(0, 8)

-- ПЕРЕМЕННЫЕ
local wallhopEnabled = false
local isJumping = false

-- 1. ЛОГИКА ПЕРЕТАСКИВАНИЯ КНОПКИ (Drag)
local dragging, dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    ToggleButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

ToggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = ToggleButton.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

ToggleButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- 2. ПЕРЕКЛЮЧЕНИЕ КНОПКИ (ON/OFF)
ToggleButton.MouseButton1Click:Connect(function()
    wallhopEnabled = not wallhopEnabled
    if wallhopEnabled then
        ToggleButton.BackgroundColor3 = Color3.fromRGB(75, 255, 75) -- Зеленый
        ToggleButton.Text = "ON"
    else
        ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 75, 75) -- Красный
        ToggleButton.Text = "OFF"
    end
end)

-- 3. СЛЕЖКА ЗА НАЖАТИЕМ ПРОБЕЛА (Прыжка)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Space then
        isJumping = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Space then
        isJumping = false
    end
end)

-- 4. САМ АВТО-ВОЛЛХОП (Каждый кадр)
RunService.Stepped:Connect(function()
    if not wallhopEnabled or not isJumping then return end
    
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    
    if humanoid and rootPart then
        -- Проверяем, есть ли стена перед персонажем (Raycast)
        local raycastParams = RaycastParams.new()
        raycastParams.FilterDescendantsInstances = {character}
        raycastParams.FilterType = Enum.RaycastFilterType.Exclude
        
        -- Стреляем лучом вперед по направлению взгляда персонажа на 2.5 ступени
        local rayDirection = rootPart.CFrame.LookVector * 2.5
        local raycastResult = game:Workspace:Raycast(rootPart.Position, rayDirection, raycastParams)
        
        -- Если уперлись в стену — спамим прыжок!
        if raycastResult then
            humanoid.ChangeState(humanoid, Enum.HumanoidStateType.Jumping)
        end
    end
end)
