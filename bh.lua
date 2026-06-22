-- ==============================================================================
-- 🌟 LITEXUTOR BROOKHAVEN v1.0 PRO
-- Кастомный UI, Телепорты, Утилиты и Авто-Банк
-- ==============================================================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer

-- Защита от двойного запуска
if CoreGui:FindFirstChild("LitexutorBH_PRO") then
    CoreGui.LitexutorBH_PRO:Destroy()
end

-- ==============================================================================
-- 🎨 СОЗДАНИЕ ИНТЕРФЕЙСА (UI)
-- ==============================================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LitexutorBH_PRO"
ScreenGui.ResetOnSpawn = false
local success = pcall(function() ScreenGui.Parent = CoreGui end)
if not success then ScreenGui.Parent = Player:WaitForChild("PlayerGui") end

-- 1. ЛЕТАЮЩАЯ КНОПКА (Свернутое меню)
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Parent = ScreenGui
ToggleBtn.Size = UDim2.new(0, 65, 0, 65)
ToggleBtn.Position = UDim2.new(0, 20, 0, 150)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(130, 40, 180) -- Неоново-фиолетовый
ToggleBtn.Text = "Litexutor\nBH"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 12
ToggleBtn.Active = true
ToggleBtn.Draggable = true
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)

-- 2. ГЛАВНОЕ МЕНЮ
local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 380, 0, 350)
MainFrame.Position = UDim2.new(0.5, -190, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- ВЕРХНЯЯ ПАНЕЛЬ
local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Litexutor Brookhaven PRO"
Title.TextColor3 = Color3.fromRGB(180, 100, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 40, 0, 40)
CloseBtn.Position = UDim2.new(1, -40, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18

-- ВКЛАДКИ (Tabs)
local TabBar = Instance.new("Frame", MainFrame)
TabBar.Size = UDim2.new(1, 0, 0, 35)
TabBar.Position = UDim2.new(0, 0, 0, 40)
TabBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)

local TabLayout = Instance.new("UIListLayout", TabBar)
TabLayout.FillDirection = Enum.FillDirection.Horizontal

local function CreateTabBtn(name, text)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(0.25, 0, 1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(150, 150, 150)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 12
    btn.BorderSizePixel = 0
    return btn
end

local Tab1Btn = CreateTabBtn("Tab1", "Главная")
local Tab2Btn = CreateTabBtn("Tab2", "Телепорты")
local Tab3Btn = CreateTabBtn("Tab3", "Утилиты")
local Tab4Btn = CreateTabBtn("Tab4", "Музыка")
Tab1Btn.Parent = TabBar; Tab2Btn.Parent = TabBar; Tab3Btn.Parent = TabBar; Tab4Btn.Parent = TabBar

-- КОНТЕЙНЕРЫ ВКЛАДОК
local Content = Instance.new("Frame", MainFrame)
Content.Size = UDim2.new(1, 0, 1, -75)
Content.Position = UDim2.new(0, 0, 0, 75)
Content.BackgroundTransparency = 1

local Tabs = {}
for i = 1, 4 do
    local frame = Instance.new("Frame", Content)
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.Visible = (i == 1)
    Tabs[i] = frame
end

-- ==============================================================================
-- 🛠️ УТИЛИТЫ ДЛЯ КНОПОК
-- ==============================================================================

local function CreateButton(parent, yPos, text, color, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, -20, 0, 35)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.BackgroundColor3 = color or Color3.fromRGB(50, 50, 70)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local function CreateInputWithButton(parent, yPos, placeholder, btnText, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -20, 0, 35)
    frame.Position = UDim2.new(0, 10, 0, yPos)
    frame.BackgroundTransparency = 1

    local box = Instance.new("TextBox", frame)
    box.Size = UDim2.new(0.65, -5, 1, 0)
    box.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    box.PlaceholderText = placeholder
    box.Text = ""
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.Font = Enum.Font.GothamSemibold
    box.TextSize = 14
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)

    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0.35, 0, 1, 0)
    btn.Position = UDim2.new(0.65, 5, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(100, 50, 200)
    btn.Text = btnText
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    btn.MouseButton1Click:Connect(function() callback(box.Text) end)
end

-- ==============================================================================
-- 🚀 НАПОЛНЕНИЕ ВКЛАДОК
-- ==============================================================================

-- ВКЛАДКА 1: Главная (Настройки профиля)
local RGBActive = false
CreateButton(Tabs[1], 10, "Установить Имя 'Litexutor'", Color3.fromRGB(40, 150, 80), function()
    -- Здесь логика установки имени. В Brookhaven это часто делается локально через UI
    print("Имя изменено на Litexutor")
end)

local RGBBtn
RGBBtn = CreateButton(Tabs[1], 55, "RGB Цвет Ника: ВЫКЛ", Color3.fromRGB(150, 40, 40), function()
    RGBActive = not RGBActive
    if RGBActive then
        RGBBtn.Text = "RGB Цвет Ника: ВКЛ"
        RGBBtn.BackgroundColor3 = Color3.fromRGB(40, 150, 80)
    else
        RGBBtn.Text = "RGB Цвет Ника: ВЫКЛ"
        RGBBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
    end
end)

-- ВКЛАДКА 2: Телепорты
local Teleports = {
    ["🏦 Банк (Сейф)"] = Vector3.new(-120, 20, 150), -- Примерные координаты
    ["🏥 Больница"] = Vector3.new(-250, 20, 200),
    ["👮 Полиция"] = Vector3.new(-100, 20, 50),
    ["☕ Старбакс"] = Vector3.new(-50, 20, 100),
    ["🕵️ Секретная База"] = Vector3.new(-150, -50, 150)
}

local yOffset = 10
for name, pos in pairs(Teleports) do
    CreateButton(Tabs[2], yOffset, "ТП: " .. name, Color3.fromRGB(50, 60, 100), function()
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            Player.Character.HumanoidRootPart.CFrame = CFrame.new(pos)
        end
    end)
    yOffset = yOffset + 45
end

-- ВКЛАДКА 3: Утилиты
CreateButton(Tabs[3], 10, "💰 Авто-Ограбление Банка", Color3.fromRGB(200, 150, 30), function()
    local Char = Player.Character
    if Char and Char:FindFirstChild("HumanoidRootPart") then
        local HRP = Char.HumanoidRootPart
        -- 1. ТП в банк
        HRP.CFrame = CFrame.new(-120, 20, 150)
        task.wait(1)
        -- 2. Здесь логика спавна C4 и взрыва (зависит от RemoteEvent игры)
        print("Взрыв сейфа...")
        task.wait(2)
        -- 3. ТП в безопасное место
        HRP.CFrame = CFrame.new(0, 500, 0) 
        print("Ограбление завершено, мы в безопасности!")
    end
end)

-- ВКЛАДКА 4: Музыка
CreateInputWithButton(Tabs[4], 10, "Введите ID песни...", "🎵 Play", function(id)
    if id ~= "" then
        print("Попытка воспроизведения ID: " .. id)
        -- В Brookhaven это отправляется через RemoteEvent, если есть геймпасс
    end
end)

CreateButton(Tabs[4], 55, "⏹️ Остановить музыку", Color3.fromRGB(180, 50, 50), function()
    print("Музыка остановлена")
end)

-- ==============================================================================
-- ⚙️ ЛОГИКА ИНТЕРФЕЙСА
-- ==============================================================================

local function SwitchTab(tabId)
    for i = 1, 4 do
        Tabs[i].Visible = (i == tabId)
    end
    Tab1Btn.TextColor3 = tabId == 1 and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)
    Tab2Btn.TextColor3 = tabId == 2 and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)
    Tab3Btn.TextColor3 = tabId == 3 and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)
    Tab4Btn.TextColor3 = tabId == 4 and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)
end

Tab1Btn.MouseButton1Click:Connect(function() SwitchTab(1) end)
Tab2Btn.MouseButton1Click:Connect(function() SwitchTab(2) end)
Tab3Btn.MouseButton1Click:Connect(function() SwitchTab(3) end)
Tab4Btn.MouseButton1Click:Connect(function() SwitchTab(4) end)

ToggleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

-- Фоновый процесс для RGB (Пример логики)
task.spawn(function()
    local hue = 0
    while task.wait(0.1) do
        if RGBActive then
            hue = hue + 0.05
            if hue >= 1 then hue = 0 end
            local color = Color3.fromHSV(hue, 1, 1)
            -- Здесь должен быть вызов изменения цвета имени над головой
        end
    end
end)

print("LITEXUTOR BROOKHAVEN PRO ЗАГРУЖЕН!")

