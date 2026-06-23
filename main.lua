-- ==============================================================================
-- 🚀 TELEPORT MANAGER v2.0 ULTRA PRO (LiteHub Edition)
-- Разработано специально для Delta. Полный кастомный функционал!
-- ==============================================================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

-- Состояние скрипта
local SavedLocations = {}
local TapToTeleportEnabled = false
local CurrentTheme = "Dark" -- "Dark" или "Light"
local ActiveDropdownPoint = nil

-- GPS переменные
local GPSPart = nil
local GPSConnection = nil

-- Очистка старой версии
if CoreGui:FindFirstChild("TeleportManagerPRO") then
    CoreGui.TeleportManagerPRO:Destroy()
end

-- Списки для обновления темы
local ThemeBackgrounds = {}
local ThemeHeaders = {}
local ThemeTexts = {}
local ThemeButtons = {}

-- ==============================================================================
-- 🎨 СИСТЕМА ТЕМ (ТЁМНАЯ / СВЕТЛАЯ)
-- ==============================================================================
local Themes = {
    Dark = {
        MainBg = Color3.fromRGB(25, 25, 25),
        HeaderBg = Color3.fromRGB(35, 35, 35),
        TabBg = Color3.fromRGB(30, 30, 30),
        ItemBg = Color3.fromRGB(45, 45, 45),
        Text = Color3.fromRGB(255, 255, 255),
        SubText = Color3.fromRGB(180, 180, 180)
    },
    Light = {
        MainBg = Color3.fromRGB(240, 240, 240),
        HeaderBg = Color3.fromRGB(210, 210, 210),
        TabBg = Color3.fromRGB(225, 225, 225),
        ItemBg = Color3.fromRGB(255, 255, 255),
        Text = Color3.fromRGB(30, 30, 30),
        SubText = Color3.fromRGB(80, 80, 80)
    }
}

local function UpdateThemeUI()
    local theme = Themes[CurrentTheme]
    for _, obj in pairs(ThemeBackgrounds) do if obj.ClassName == "Frame" or obj.ClassName == "ScrollingFrame" then obj.BackgroundColor3 = theme.MainBg end end
    for _, obj in pairs(ThemeHeaders) do obj.BackgroundColor3 = theme.HeaderBg end
    for _, obj in pairs(ThemeTexts) do obj.TextColor3 = theme.Text end
    for _, obj in pairs(ThemeButtons) do if obj:Attribute() ~= "CustomColor" then obj.BackgroundColor3 = theme.ItemBg end obj.TextColor3 = theme.Text end
end

-- ==============================================================================
-- 🖥️ ИНТЕРФЕЙС ГЛАВНОГО МЕНЮ
-- ==============================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TeleportManagerPRO"
ScreenGui.ResetOnSpawn = false
local success = pcall(function() ScreenGui.Parent = CoreGui end)
if not success then ScreenGui.Parent = Player:WaitForChild("PlayerGui") end

-- Летающая кнопка "TP"
local ToggleButton = Instance.new("TextButton", ScreenGui)
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Position = UDim2.new(0, 20, 0, 150)
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
ToggleButton.Text = "TP"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 20
ToggleButton.Active = true
ToggleButton.Draggable = true
Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(1, 0)

-- Главное окно
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 380, 0, 320)
MainFrame.Position = UDim2.new(0.5, -190, 0.5, -160)
MainFrame.BackgroundColor3 = Themes.Dark.MainBg
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
table.insert(ThemeBackgrounds, MainFrame)

-- Хедер
local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Themes.Dark.HeaderBg
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 10)
table.insert(ThemeHeaders, Header)

local HeaderFix = Instance.new("Frame", Header)
HeaderFix.Size = UDim2.new(1, 0, 0, 10)
HeaderFix.Position = UDim2.new(0, 0, 1, -10)
HeaderFix.BackgroundColor3 = Themes.Dark.HeaderBg
HeaderFix.BorderSizePixel = 0
table.insert(ThemeHeaders, HeaderFix)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Teleport Manager v2.0 PRO"
Title.TextColor3 = Themes.Dark.Text
Title.Font = Enum.Font.GothamBold
Title.TextSize = 15
Title.TextXAlignment = Enum.TextXAlignment.Left
table.insert(ThemeTexts, Title)

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 40, 0, 40)
CloseBtn.Position = UDim2.new(1, -40, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18

-- Панель вкладок
local TabBar = Instance.new("Frame", MainFrame)
TabBar.Size = UDim2.new(1, 0, 0, 35)
TabBar.Position = UDim2.new(0, 0, 0, 40)
TabBar.BackgroundColor3 = Themes.Dark.TabBg
TabBar.BorderSizePixel = 0

local TabListLayout = Instance.new("UIListLayout", TabBar)
TabListLayout.FillDirection = Enum.FillDirection.Horizontal

local Tab1Btn = Instance.new("TextButton", TabBar)
Tab1Btn.Size = UDim2.new(0.5, 0, 1, 0)
Tab1Btn.BackgroundTransparency = 1
Tab1Btn.Text = "Управление ТП"
Tab1Btn.Font = Enum.Font.GothamSemibold
Tab1Btn.TextSize = 13
table.insert(ThemeTexts, Tab1Btn)

local Tab2Btn = Instance.new("TextButton", TabBar)
Tab2Btn.Size = UDim2.new(0.5, 0, 1, 0)
Tab2Btn.BackgroundTransparency = 1
Tab2Btn.Text = "Настройки / GPS"
Tab2Btn.Font = Enum.Font.GothamSemibold
Tab2Btn.TextSize = 13
table.insert(ThemeTexts, Tab2Btn)

-- Контейнер контента
local ContentContainer = Instance.new("Frame", MainFrame)
ContentContainer.Size = UDim2.new(1, 0, 1, -75)
ContentContainer.Position = UDim2.new(0, 0, 0, 75)
ContentContainer.BackgroundTransparency = 1

-- Вкладка 1
local Tab1Frame = Instance.new("Frame", ContentContainer)
Tab1Frame.Size = UDim2.new(1, 0, 1, 0)
Tab1Frame.BackgroundTransparency = 1

local SaveTPBtn = Instance.new("TextButton", Tab1Frame)
SaveTPBtn.Size = UDim2.new(1, -20, 0, 35)
SaveTPBtn.Position = UDim2.new(0, 10, 0, 10)
SaveTPBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 80)
SaveTPBtn.Text = "➕ Сохранить текущую точку"
SaveTPBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SaveTPBtn.Font = Enum.Font.GothamBold
SaveTPBtn.TextSize = 13
SaveTPBtn:SetAttribute("CustomColor", true)
Instance.new("UICorner", SaveTPBtn).CornerRadius = UDim.new(0, 6)

local TPList = Instance.new("ScrollingFrame", Tab1Frame)
TPList.Size = UDim2.new(1, -20, 1, -60)
TPList.Position = UDim2.new(0, 10, 0, 55)
TPList.BackgroundTransparency = 1
TPList.ScrollBarThickness = 4
TPList.CanvasSize = UDim2.new(0, 0, 0, 0)
table.insert(ThemeBackgrounds, TPList)

local TPListLayout = Instance.new("UIListLayout", TPList)
TPListLayout.Padding = UDim.new(0, 6)

-- Вкладка 2
local Tab2Frame = Instance.new("Frame", ContentContainer)
Tab2Frame.Size = UDim2.new(1, 0, 1, 0)
Tab2Frame.BackgroundTransparency = 1
Tab2Frame.Visible = false

local Tab2Layout = Instance.new("UIListLayout", Tab2Frame)
Tab2Layout.Padding = UDim.new(0, 10)
Tab2Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

Instance.new("Frame", Tab2Frame).Size = UDim2.new(1,0,0,5) -- Отступ сверху

local TapToTPBtn = Instance.new("TextButton", Tab2Frame)
TapToTPBtn.Size = UDim2.new(0.95, 0, 0, 40)
TapToTPBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
TapToTPBtn.Text = "Tap to Teleport: ВЫКЛ"
TapToTPBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
TapToTPBtn.Font = Enum.Font.GothamBold
TapToTPBtn.TextSize = 13
TapToTPBtn:SetAttribute("CustomColor", true)
Instance.new("UICorner", TapToTPBtn).CornerRadius = UDim.new(0, 6)

local ThemeToggleBtn = Instance.new("TextButton", Tab2Frame)
ThemeToggleBtn.Size = UDim2.new(0.95, 0, 0, 40)
ThemeToggleBtn.Text = "Тема хаба: Тёмная"
ThemeToggleBtn.Font = Enum.Font.GothamBold
ThemeToggleBtn.TextSize = 13
Instance.new("UICorner", ThemeToggleBtn).CornerRadius = UDim.new(0, 6)
table.insert(ThemeButtons, ThemeToggleBtn)

-- ==============================================================================
-- 🛸 УМНОЕ ОКНО GPS И ЛОГИКА НАВИГАЦИИ
-- ==============================================================================
local GPSInfoWindow = Instance.new("Frame", ScreenGui)
GPSInfoWindow.Size = UDim2.new(0, 200, 0, 90)
GPSInfoWindow.Position = UDim2.new(0.05, 0, 0.7, 0)
GPSInfoWindow.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
GPSInfoWindow.Visible = false
GPSInfoWindow.Active = true
GPSInfoWindow.Draggable = true
Instance.new("UICorner", GPSInfoWindow).CornerRadius = UDim.new(0, 8)

local GPSInfoTitle = Instance.new("TextLabel", GPSInfoWindow)
GPSInfoTitle.Size = UDim2.new(1, -30, 0, 25)
GPSInfoTitle.Position = UDim2.new(0, 10, 0, 5)
GPSInfoTitle.Text = "📡 Навигатор PRO"
GPSInfoTitle.TextColor3 = Color3.fromRGB(255, 130, 0)
GPSInfoTitle.Font = Enum.Font.GothamBold
GPSInfoTitle.TextSize = 13
GPSInfoTitle.TextXAlignment = Enum.TextXAlignment.Left
GPSInfoTitle.BackgroundTransparency = 1

local GPSClose = Instance.new("TextButton", GPSInfoWindow)
GPSClose.Size = UDim2.new(0, 20, 0, 20)
GPSClose.Position = UDim2.new(1, -25, 0, 5)
GPSClose.Text = "X"
GPSClose.TextColor3 = Color3.fromRGB(255, 100, 100)
GPSClose.Font = Enum.Font.GothamBold
GPSClose.BackgroundTransparency = 1

local GPSDistLabel = Instance.new("TextLabel", GPSInfoWindow)
GPSDistLabel.Size = UDim2.new(1, -20, 0, 25)
GPSDistLabel.Position = UDim2.new(0, 10, 0, 30)
GPSDistLabel.Text = "Дистанция: ---"
GPSDistLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
GPSDistLabel.Font = Enum.Font.GothamSemibold
GPSDistLabel.TextSize = 12
GPSDistLabel.TextXAlignment = Enum.TextXAlignment.Left
GPSDistLabel.BackgroundTransparency = 1

local GPSObstacleLabel = Instance.new("TextLabel", GPSInfoWindow)
GPSObstacleLabel.Size = UDim2.new(1, -20, 0, 25)
GPSObstacleLabel.Position = UDim2.new(0, 10, 0, 55)
GPSObstacleLabel.Text = "Путь: Сканирование..."
GPSObstacleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
GPSObstacleLabel.Font = Enum.Font.GothamSemibold
GPSObstacleLabel.TextSize = 12
GPSObstacleLabel.TextXAlignment = Enum.TextXAlignment.Left
GPSObstacleLabel.BackgroundTransparency = 1

-- Выпадающее меню операций (Контекстный Дропдаун)
local DropdownMenu = Instance.new("Frame", ScreenGui)
DropdownMenu.Size = UDim2.new(0, 140, 0, 130)
DropdownMenu.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
DropdownMenu.Visible = false
Instance.new("UICorner", DropdownMenu).CornerRadius = UDim.new(0, 6)
local DropLayout = Instance.new("UIListLayout", DropdownMenu)
DropLayout.Padding = UDim.new(0, 2)

local function CreateDropBtn(text, color, callback)
    local b = Instance.new("TextButton", DropdownMenu)
    b.Size = UDim2.new(1, 0, 0, 30)
    b.Text = text
    b.TextColor3 = color
    b.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    b.Font = Enum.Font.GothamSemibold
    b.TextSize = 12
    b.BorderSizePixel = 0
    b.MouseButton1Click:Connect(function()
        DropdownMenu.Visible = false
        callback()
    end)
end

-- ==============================================================================
-- ⚙️ ОПЕРАЦИОННАЯ ЛОГИКА И ИНТЕГРАЦИЯ С ФУНКЦИЯМИ
-- ==============================================================================

local function SafeTeleport(cframe)
    task.wait(0.1) -- Просил микро-паузу перед GO! Получай, для стабильности инжекта
    local char = Player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = cframe
    end
end

local function CleanGPS()
    if GPSPart then GPSPart:Destroy(); GPSPart = nil end
    if GPSConnection then GPSConnection:Disconnect(); GPSConnection = nil end
    GPSInfoWindow.Visible = false
end

GPSClose.MouseButton1Click:Connect(CleanGPS)

local function SetupSmartGPS(cframe, name)
    CleanGPS()

    GPSPart = Instance.new("Part")
    GPSPart.Anchored = true
    GPSPart.CanCollide = false
    GPSPart.Transparency = 1
    GPSPart.CFrame = cframe
    GPSPart.Parent = workspace

    local bgui = Instance.new("BillboardGui", GPSPart)
    bgui.AlwaysOnTop = true
    bgui.Size = UDim2.new(0, 160, 0, 40)
    bgui.StudsOffset = Vector3.new(0, 3, 0)

    local txt = Instance.new("TextLabel", bgui)
    txt.Size = UDim2.new(1, 0, 1, 0)
    txt.BackgroundTransparency = 1
    txt.TextColor3 = Color3.fromRGB(255, 100, 0)
    txt.TextStrokeTransparency = 0
    txt.Font = Enum.Font.GothamBold
    txt.TextSize = 14

    GPSInfoWindow.Visible = true

    GPSConnection = RunService.RenderStepped:Connect(function()
        local char = Player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local p1 = char.HumanoidRootPart.Position
            local p2 = GPSPart.Position
            local dist = (p1 - p2).Magnitude
            
            txt.Text = "📍 " .. name .. "\n" .. math.floor(dist) .. " studs"
            GPSDistLabel.Text = "Дистанция: " .. math.floor(dist) .. " studs"

            -- Поиск препятствий лучами (Raycast)
            local dir = p2 - p1
            local rayParams = RaycastParams.new()
            rayParams.FilterType = Enum.RaycastFilterType.Exclude
            rayParams.FilterDescendantsInstances = {char, GPSPart}
            
            local res = workspace:Raycast(p1, dir, rayParams)
            if res and res.Instance and not res.Instance:IsDescendantOf(char) then
                GPSObstacleLabel.Text = "⛔ Путь: Блокирован [" .. string.sub(res.Instance.Name, 1, 10) .. "]"
                GPSObstacleLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            else
                GPSObstacleLabel.Text = "✅ Путь: Чисто"
                GPSObstacleLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            end
        end
    end)
end

-- Логика переключения вкладок
local function switchTab(id)
    if id == 1 then
        Tab1Frame.Visible = true; Tab2Frame.Visible = false
        Tab1Btn.TextColor3 = Color3.fromRGB(255, 100, 0)
        Tab2Btn.TextColor3 = Themes[CurrentTheme].SubText
    else
        Tab1Frame.Visible = false; Tab2Frame.Visible = true
        Tab1Btn.TextColor3 = Themes[CurrentTheme].SubText
        Tab2Btn.TextColor3 = Color3.fromRGB(255, 100, 0)
    end
end
Tab1Btn.MouseButton1Click:Connect(function() switchTab(1) end)
Tab2Btn.MouseButton1Click:Connect(function() switchTab(2) end)
switchTab(1)

-- Смена тем
ThemeToggleBtn.MouseButton1Click:Connect(function()
    CurrentTheme = (CurrentTheme == "Dark") and "Light" or "Dark"
    ThemeToggleBtn.Text = "Тема хаба: " .. (CurrentTheme == "Dark" and "Тёмная" or "Светлая")
    UpdateThemeUI()
    switchTab(Tab1Frame.Visible and 1 or 2)
end)

-- Рендеринг элементов списка сохраненных точек
local function RebuildTPList()
    for _, child in pairs(TPList:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    for idx, item in ipairs(SavedLocations) do
        local ItemFrame = Instance.new("Frame", TPList)
        ItemFrame.Size = UDim2.new(1, -5, 0, 42)
        ItemFrame.BackgroundColor3 = Themes[CurrentTheme].ItemBg
        Instance.new("UICorner", ItemFrame).CornerRadius = UDim.new(0, 6)
        table.insert(ThemeButtons, ItemFrame)

        local ItemName = Instance.new("TextLabel", ItemFrame)
        ItemName.Size = UDim2.new(0.55, 0, 1, 0)
        ItemName.Position = UDim2.new(0, 10, 0, 0)
        ItemName.BackgroundTransparency = 1
        ItemName.Text = item.Name
        ItemName.TextColor3 = Themes[CurrentTheme].Text
        ItemName.Font = Enum.Font.GothamBold
        ItemName.TextSize = 13
        ItemName.TextXAlignment = Enum.TextXAlignment.Left
        table.insert(ThemeTexts, ItemName)

        local GoBtn = Instance.new("TextButton", ItemFrame)
        GoBtn.Size = UDim2.new(0, 50, 0, 32)
        GoBtn.Position = UDim2.new(1, -95, 0, 5)
        GoBtn.BackgroundColor3 = Color3.fromRGB(50, 120, 220)
        GoBtn.Text = "GO"
        GoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        GoBtn.Font = Enum.Font.GothamBold
        GoBtn.TextSize = 12
        GoBtn:SetAttribute("CustomColor", true)
        Instance.new("UICorner", GoBtn).CornerRadius = UDim.new(0, 5)

        local OptBtn = Instance.new("TextButton", ItemFrame)
        OptBtn.Size = UDim2.new(0, 35, 0, 32)
        OptBtn.Position = UDim2.new(1, -40, 0, 5)
        OptBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
        OptBtn.Text = "v"
        OptBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        OptBtn.Font = Enum.Font.GothamBold
        OptBtn.TextSize = 14
        OptBtn:SetAttribute("CustomColor", true)
        Instance.new("UICorner", OptBtn).CornerRadius = UDim.new(0, 5)

        GoBtn.MouseButton1Click:Connect(function()
            SafeTeleport(item.CFrame)
        end)

        -- Кнопка Дропдауна "v"
        OptBtn.MouseButton1Click:Connect(function()
            ActiveDropdownPoint = {Idx = idx, Item = item, Frame = ItemFrame, Label = ItemName}
            DropdownMenu.Position = UDim2.new(0, OptBtn.AbsolutePosition.X - 105, 0, OptBtn.AbsolutePosition.Y + 35)
            DropdownMenu.Visible = not DropdownMenu.Visible
        end)
    end
    TPList.CanvasSize = UDim2.new(0, 0, 0, TPListLayout.AbsoluteContentSize.Y + 10)
end

-- Конфигурация кнопок Дропдаун-меню ("v")
CreateDropBtn("📡 Включить GPS", Color3.fromRGB(255, 160, 50), function()
    if ActiveDropdownPoint then
        SetupSmartGPS(ActiveDropdownPoint.Item.CFrame, ActiveDropdownPoint.Item.Name)
    end
end)

CreateDropBtn("❌ Выключить GPS", Color3.fromRGB(255, 100, 100), function()
    CleanGPS()
end)

CreateDropBtn("✏️ Переименовать", Color3.fromRGB(100, 200, 255), function()
    if ActiveDropdownPoint then
        local lbl = ActiveDropdownPoint.Label
        lbl.Visible = false
        
        local editBox = Instance.new("TextBox", lbl.Parent)
        editBox.Size = lbl.Size
        editBox.Position = lbl.Position
        editBox.Text = lbl.Text
        editBox.Font = lbl.Font
        editBox.TextSize = lbl.TextSize
        editBox.TextColor3 = lbl.TextColor3
        editBox.BackgroundTransparency = 1
        editBox.TextXAlignment = Enum.TextXAlignment.Left
        editBox:CaptureFocus()
        
        editBox.FocusLost:Connect(function(enter)
            if enter and editBox.Text ~= "" then
                SavedLocations[ActiveDropdownPoint.Idx].Name = editBox.Text
            end
            editBox:Destroy()
            RebuildTPList()
        end)
    end
end)

CreateDropBtn("🗑️ Удалить точку", Color3.fromRGB(255, 70, 70), function()
    if ActiveDropdownPoint then
        table.remove(SavedLocations, ActiveDropdownPoint.Idx)
        ActiveDropdownPoint = nil
        RebuildTPList()
    end
end)

-- Создание новой локации
SaveTPBtn.MouseButton1Click:Connect(function()
    local char = Player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local posCFrame = char.HumanoidRootPart.CFrame
        local id = #SavedLocations + 1
        table.insert(SavedLocations, {Name = "Точка №" .. id, CFrame = posCFrame})
        RebuildTPList()
    end
end)

-- Логика скрытия хаба
ToggleButton.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

-- Tap To Teleport
TapToTPBtn.MouseButton1Click:Connect(function()
    TapToTeleportEnabled = not TapToTeleportEnabled
    TapToTPBtn.Text = "Tap to Teleport: " .. (TapToTeleportEnabled and "ВКЛ" or "ВЫКЛ")
    TapToTPBtn.TextColor3 = TapToTeleportEnabled and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
end)

Mouse.Button1Down:Connect(function()
    if TapToTeleportEnabled and Mouse.Target and not UserInputService:GetFocusedTextBox() then
        local targetPos = Mouse.Hit.Position + Vector3.new(0, 3, 0)
        SafeTeleport(CFrame.new(local TabBar = Instance.new("Frame")
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

