-- ==============================================================================
-- 🚀 TELEPORT MANAGER v1.0 PRO
-- Разработано специально для Delta. Полностью кастомный UI, без внешних либ!
-- ==============================================================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

-- Переменные состояния
local SavedLocations = {}
local TapToTeleportEnabled = false
local GPSPart = nil -- Деталь для отображения GPS
local GPSConnection = nil -- Соединение для обновления дистанции

-- Защита от двойного запуска (удаляем старый UI, если есть)
if CoreGui:FindFirstChild("TeleportManagerPRO") then
    CoreGui.TeleportManagerPRO:Destroy()
end

-- ==============================================================================
-- 🎨 СОЗДАНИЕ ГЛАВНОГО ИНТЕРФЕЙСА (UI)
-- ==============================================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TeleportManagerPRO"
ScreenGui.ResetOnSpawn = false
-- Пытаемся закинуть в CoreGui, чтобы античиты игры не спалили (стандарт для читов)
local success = pcall(function() ScreenGui.Parent = CoreGui end)
if not success then ScreenGui.Parent = Player:WaitForChild("PlayerGui") end

-- 1. ЛЕТАЮЩАЯ КНОПКА (Toggle)
local ToggleButton = Instance.new("TextButton")
local ToggleCorner = Instance.new("UICorner")

ToggleButton.Name = "TP_Toggle"
ToggleButton.Parent = ScreenGui
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Position = UDim2.new(0, 20, 0, 150)
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 100, 0) -- Ярко-рыжий цвет!
ToggleButton.Text = "TP"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 20
ToggleButton.Active = true
ToggleButton.Draggable = true -- Делаем перетаскиваемой для мобилок

ToggleCorner.CornerRadius = UDim.new(1, 0) -- Полностью круглая
ToggleCorner.Parent = ToggleButton

-- 2. ГЛАВНОЕ МЕНЮ (Скрыто по умолчанию)
local MainFrame = Instance.new("Frame")
local MainCorner = Instance.new("UICorner")

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 400, 0, 300)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true -- Меню тоже можно таскать!

MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

-- 3. ВЕРХНЯЯ ПАНЕЛЬ (Header)
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

-- Квадратная заглушка, чтобы нижние углы хедера не скруглялись
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
Title.Text = "Teleport Manager v1.0 PRO"
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

-- 4. ВКЛАДКИ (Tabs)
local TabBar = Instance.new("Frame")
local TabListLayout = Instance.new("UIListLayout")
local Tab1Btn = Instance.new("TextButton")
local Tab2Btn = Instance.new("TextButton")

TabBar.Name = "TabBar"
TabBar.Parent = MainFrame
TabBar.Size = UDim2.new(1, 0, 0, 35)
TabBar.Position = UDim2.new(0, 0, 0, 40)
TabBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TabBar.BorderSizePixel = 0

TabListLayout.Parent = TabBar
TabListLayout.FillDirection = Enum.FillDirection.Horizontal
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder

local function createTabButton(name, text)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(0.5, 0, 1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 14
    btn.BorderSizePixel = 0
    return btn
end

Tab1Btn = createTabButton("Tab1Btn", "Управление ТП")
Tab2Btn = createTabButton("Tab2Btn", "Настройки / GPS")
Tab1Btn.Parent = TabBar
Tab2Btn.Parent = TabBar

-- 5. КОНТЕЙНЕРЫ ДЛЯ КОНТЕНТА
local ContentContainer = Instance.new("Frame")
ContentContainer.Name = "Content"
ContentContainer.Parent = MainFrame
ContentContainer.Size = UDim2.new(1, 0, 1, -75)
ContentContainer.Position = UDim2.new(0, 0, 0, 75)
ContentContainer.BackgroundTransparency = 1

-- Вкладка 1: Управление ТП
local Tab1Frame = Instance.new("Frame")
Tab1Frame.Parent = ContentContainer
Tab1Frame.Size = UDim2.new(1, 0, 1, 0)
Tab1Frame.BackgroundTransparency = 1

local SaveTPBtn = Instance.new("TextButton")
local SaveTPCorner = Instance.new("UICorner")
SaveTPBtn.Parent = Tab1Frame
SaveTPBtn.Size = UDim2.new(1, -20, 0, 35)
SaveTPBtn.Position = UDim2.new(0, 10, 0, 10)
SaveTPBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 80)
SaveTPBtn.Text = "➕ Сохранить текущую точку"
SaveTPBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SaveTPBtn.Font = Enum.Font.GothamBold
SaveTPBtn.TextSize = 14
SaveTPCorner.CornerRadius = UDim.new(0, 6)
SaveTPCorner.Parent = SaveTPBtn

-- Список точек (ScrollingFrame)
local TPList = Instance.new("ScrollingFrame")
local TPListLayout = Instance.new("UIListLayout")
TPList.Parent = Tab1Frame
TPList.Size = UDim2.new(1, -20, 1, -60)
TPList.Position = UDim2.new(0, 10, 0, 55)
TPList.BackgroundTransparency = 1
TPList.ScrollBarThickness = 5
TPList.CanvasSize = UDim2.new(0, 0, 0, 0) -- Будет обновляться динамически

TPListLayout.Parent = TPList
TPListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TPListLayout.Padding = UDim.new(0, 5)

-- Вкладка 2: Настройки
local Tab2Frame = Instance.new("Frame")
Tab2Frame.Parent = ContentContainer
Tab2Frame.Size = UDim2.new(1, 0, 1, 0)
Tab2Frame.BackgroundTransparency = 1
Tab2Frame.Visible = false -- Скрыта по умолчанию

local TapToTPBtn = Instance.new("TextButton")
local TapToTPCorner = Instance.new("UICorner")
TapToTPBtn.Parent = Tab2Frame
TapToTPBtn.Size = UDim2.new(1, -20, 0, 40)
TapToTPBtn.Position = UDim2.new(0, 10, 0, 10)
TapToTPBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
TapToTPBtn.Text = "Tap to Teleport: ВЫКЛ"
TapToTPBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
TapToTPBtn.Font = Enum.Font.GothamBold
TapToTPBtn.TextSize = 14
TapToTPCorner.CornerRadius = UDim.new(0, 6)
TapToTPCorner.Parent = TapToTPBtn

-- ==============================================================================
-- ⚙️ ЛОГИКА СКРИПТА
-- ==============================================================================

-- Функция безопасного телепорта
local function SafeTeleport(cframe)
    local char = Player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = cframe
    end
end

-- Логика вкладок
local function switchTab(tab)
    if tab == 1 then
        Tab1Frame.Visible = true
        Tab2Frame.Visible = false
        Tab1Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        Tab2Btn.TextColor3 = Color3.fromRGB(150, 150, 150)
    else
        Tab1Frame.Visible = false
        Tab2Frame.Visible = true
        Tab1Btn.TextColor3 = Color3.fromRGB(150, 150, 150)
        Tab2Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end

Tab1Btn.MouseButton1Click:Connect(function() switchTab(1) end)
Tab2Btn.MouseButton1Click:Connect(function() switchTab(2) end)
switchTab(1) -- Инициализация

-- Открытие/Закрытие меню на летучую кнопку
ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Закрытие на крестик
CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

-- Создание GPS метки
local function setGPS(cframe, name)
    -- Удаляем старый GPS, если есть
    if GPSPart then GPSPart:Destroy() end
    if GPSConnection then GPSConnection:Disconnect() end

    -- Создаем невидимый парт для метки
    GPSPart = Instance.new("Part")
    GPSPart.Anchored = true
    GPSPart.CanCollide = false
    GPSPart.Transparency = 1
    GPSPart.CFrame = cframe
    GPSPart.Parent = workspace

    local bgui = Instance.new("BillboardGui")
    bgui.Parent = GPSPart
    bgui.AlwaysOnTop = true
    bgui.Size = UDim2.new(0, 200, 0, 50)
    bgui.StudsOffset = Vector3.new(0, 3, 0)

    local txt = Instance.new("TextLabel")
    txt.Parent = bgui
    txt.Size = UDim2.new(1, 0, 1, 0)
    txt.BackgroundTransparency = 1
    txt.TextColor3 = Color3.fromRGB(255, 100, 0) -- Наш фирменный рыжий!
    txt.TextStrokeTransparency = 0 -- Обводка для читаемости
    txt.Font = Enum.Font.GothamBold
    txt.TextSize = 16

    -- Цикл обновления дистанции
    GPSConnection = RunService.RenderStepped:Connect(function()
        local char = Player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local dist = (char.HumanoidRootPart.Position - GPSPart.Position).Magnitude
            txt.Text = name .. "\n" .. math.floor(dist) .. " studs"
        end
    end)
end

-- Добавление новой точки ТП
SaveTPBtn.MouseButton1Click:Connect(function()
    local char = Player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local posCFrame = char.HumanoidRootPart.CFrame
        local id = #SavedLocations + 1
        local pointName = "Точка №" .. id
        
        table.insert(SavedLocations, {Name = pointName, CFrame = posCFrame})
        
        -- Создаем плашку для точки
        local ItemFrame = Instance.new("Frame")
        ItemFrame.Size = UDim2.new(1, 0, 0, 40)
        ItemFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        local ItemCorner = Instance.new("UICorner")
        ItemCorner.CornerRadius = UDim.new(0, 6)
        ItemCorner.Parent = ItemFrame
        ItemFrame.Parent = TPList

        local ItemName = Instance.new("TextLabel")
        ItemName.Parent = ItemFrame
        ItemName.Size = UDim2.new(0.5, 0, 1, 0)
        ItemName.Position = UDim2.new(0, 10, 0, 0)
        ItemName.BackgroundTransparency = 1
        ItemName.Text = pointName
        ItemName.TextColor3 = Color3.fromRGB(255, 255, 255)
        ItemName.Font = Enum.Font.GothamBold
        ItemName.TextSize = 14
        ItemName.TextXAlignment = Enum.TextXAlignment.Left

        local GoBtn = Instance.new("TextButton")
        GoBtn.Parent = ItemFrame
        GoBtn.Size = UDim2.new(0, 60, 0, 30)
        GoBtn.Position = UDim2.new(1, -140, 0, 5)
        GoBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
        GoBtn.Text = "GO"
        GoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        GoBtn.Font = Enum.Font.GothamBold
        Instance.new("UICorner").Parent = GoBtn

        local GPSBtn = Instance.new("TextButton")
        GPSBtn.Parent = ItemFrame
        GPSBtn.Size = UDim2.new(0, 60, 0, 30)
        GPSBtn.Position = UDim2.new(1, -70, 0, 5)
        GPSBtn.BackgroundColor3 = Color3.fromRGB(200, 150, 40)
        GPSBtn.Text = "GPS"
        GPSBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        GPSBtn.Font = Enum.Font.GothamBold
        Instance.new("UICorner").Parent = GPSBtn

        -- Логика кнопок элемента
        GoBtn.MouseButton1Click:Connect(function()
            SafeTeleport(posCFrame)
        end)

        GPSBtn.MouseButton1Click:Connect(function()
            setGPS(posCFrame, pointName)
        end)

        -- Обновляем скролл
        TPList.CanvasSize = UDim2.new(0, 0, 0, TPListLayout.AbsoluteContentSize.Y + 10)
    end
end)

-- Логика Tap to Teleport
TapToTPBtn.MouseButton1Click:Connect(function()
    TapToTeleportEnabled = not TapToTeleportEnabled
    if TapToTeleportEnabled then
        TapToTPBtn.Text = "Tap to Teleport: ВКЛ"
        TapToTPBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
    else
        TapToTPBtn.Text = "Tap to Teleport: ВЫКЛ"
        TapToTPBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end)

Mouse.Button1Down:Connect(function()
    if TapToTeleportEnabled and Mouse.Target then
        -- Телепорт на место клика + 3 студа вверх
        local targetPos = Mouse.Hit.Position + Vector3.new(0, 3, 0)
        SafeTeleport(CFrame.new(targetPos))
    end
end)

print("Teleport Manager PRO загружен! Удачной игры!")

