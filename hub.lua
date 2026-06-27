local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

-- ==========================================
-- БАЗА ДАННЫХ ТВОИХ ЧИТОВ
-- ==========================================
local cheats = {
    {name = "Teleport Manager", url = "https://raw.githubusercontent.com/imablackmemw/litehub-roblox/refs/heads/main/main.lua", targetGui = "TeleportGui"}, -- Замени "TeleportGui" на реальное имя GUI, если знаешь
    {name = "FlyHack", url = "https://raw.githubusercontent.com/imablackmemw/litehub-roblox/refs/heads/main/fly.lua", targetGui = "FlyGui"},
    {name = "Autoclicker", url = "https://raw.githubusercontent.com/imablackmemw/litehub-roblox/refs/heads/main/autoclick.lua", targetGui = "AdvancedAutoclicker"},
    {name = "Auto Wallhop", url = "https://raw.githubusercontent.com/imablackmemw/litehub-roblox/refs/heads/main/wallhop.lua", targetGui = "WallhopCheat"}
}

-- Создаем главную GUI
local HubGui = Instance.new("ScreenGui")
HubGui.Name = "LiteHub_Master"
HubGui.Parent = CoreGui
HubGui.ResetOnSpawn = false

-- ==========================================
-- ФУНКЦИЯ ПЕРЕТАСКИВАНИЯ (DRAG)
-- ==========================================
local function makeDraggable(obj)
    local dragging, dragInput, dragStart, startPos
    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true dragStart = input.Position startPos = obj.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    obj.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- ==========================================
-- СВОРАЧИВАЕМЫЙ КРУЖОК (МИНИ-ХАБ)
-- ==========================================
local MiniCircle = Instance.new("ImageButton")
MiniCircle.Size = UDim2.new(0, 50, 0, 50)
MiniCircle.Position = UDim2.new(0.05, 0, 0.1, 0)
MiniCircle.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MiniCircle.Image = "rbxassetid://10867478505" -- Иконка хакера/кода (можно поменять)
MiniCircle.Visible = false
MiniCircle.Parent = HubGui
makeDraggable(MiniCircle)

local CircleCorner = Instance.new("UICorner")
CircleCorner.CornerRadius = UDim.new(1, 0) -- Делает идеальный круг
CircleCorner.Parent = MiniCircle

local CircleStroke = Instance.new("UIStroke")
CircleStroke.Color = Color3.fromRGB(0, 255, 128)
CircleStroke.Thickness = 2
CircleStroke.Parent = MiniCircle

-- ==========================================
-- ГЛАВНОЕ ОКНО ХАБА
-- ==========================================
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 400, 0, 300)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Visible = false
MainFrame.ClipsDescendants = true
MainFrame.Parent = HubGui
makeDraggable(MainFrame)

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

-- Шапка хаба
local Topbar = Instance.new("Frame")
Topbar.Size = UDim2.new(1, 0, 0, 40)
Topbar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Topbar.Parent = MainFrame
local TopbarCorner = Instance.new("UICorner") TopbarCorner.CornerRadius = UDim.new(0, 10) TopbarCorner.Parent = Topbar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 200, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "⚡ LITE HUB | Panel"
Title.TextColor3 = Color3.fromRGB(0, 255, 128)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Topbar

-- Кнопка "Свернуть" (-)
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 40, 0, 40)
MinimizeBtn.Position = UDim2.new(1, -80, 0, 0)
MinimizeBtn.BackgroundTransparency = 1
MinimizeBtn.Text = "–"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 24
MinimizeBtn.Parent = Topbar

-- Кнопка "Убить Хаб" (X)
local CloseHubBtn = Instance.new("TextButton")
CloseHubBtn.Size = UDim2.new(0, 40, 0, 40)
CloseHubBtn.Position = UDim2.new(1, -40, 0, 0)
CloseHubBtn.BackgroundTransparency = 1
CloseHubBtn.Text = "✕"
CloseHubBtn.TextColor3 = Color3.fromRGB(255, 75, 75)
CloseHubBtn.Font = Enum.Font.GothamBold
CloseHubBtn.TextSize = 20
CloseHubBtn.Parent = Topbar

-- Скролл-список для читов
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -20, 1, -50)
Scroll.Position = UDim2.new(0, 10, 0, 45)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 4
Scroll.Parent = MainFrame

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 8)
Layout.Parent = Scroll

-- ==========================================
-- ЛОГИКА ГЕНЕРАЦИИ СПИСКА ЧИТОВ
-- ==========================================
for i, cheat in pairs(cheats) do
    local Item = Instance.new("Frame")
    Item.Size = UDim2.new(1, -10, 0, 45)
    Item.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Item.Parent = Scroll
    local ItemCorner = Instance.new("UICorner") ItemCorner.CornerRadius = UDim.new(0, 6) ItemCorner.Parent = Item

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0, 150, 1, 0)
    Label.Position = UDim2.new(0, 15, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = cheat.name
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Item

    -- Кнопка Запуска
    local LoadBtn = Instance.new("TextButton")
    LoadBtn.Size = UDim2.new(0, 80, 0, 30)
    LoadBtn.Position = UDim2.new(1, -130, 0, 7)
    LoadBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    LoadBtn.Text = "Load"
    LoadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    LoadBtn.Font = Enum.Font.GothamBold
    LoadBtn.Parent = Item
    local LCorner = Instance.new("UICorner") LCorner.CornerRadius = UDim.new(0, 6) LCorner.Parent = LoadBtn

    -- Кнопка Убийства (X)
    local KillBtn = Instance.new("TextButton")
    KillBtn.Size = UDim2.new(0, 30, 0, 30)
    KillBtn.Position = UDim2.new(1, -40, 0, 7)
    KillBtn.BackgroundColor3 = Color3.fromRGB(255, 75, 75)
    KillBtn.Text = "✕"
    KillBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    KillBtn.Font = Enum.Font.GothamBold
    KillBtn.Parent = Item
    local KCorner = Instance.new("UICorner") KCorner.CornerRadius = UDim.new(0, 6) KCorner.Parent = KillBtn

    -- Действие при нажатии "Load"
    LoadBtn.MouseButton1Click:Connect(function()
        LoadBtn.Text = "..."
        LoadBtn.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
        task.spawn(function()
            -- Загружаем скрипт по ссылке
            local success, err = pcall(function()
                loadstring(game:HttpGet(cheat.url))()
            end)
            task.wait(0.5)
            if success then
                LoadBtn.Text = "Loaded!"
                LoadBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 80)
            else
                LoadBtn.Text = "Error"
                LoadBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                print("LITEHUB ERROR:", err)
            end
            task.wait(2)
            LoadBtn.Text = "Load"
            LoadBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        end)
    end)

    -- Действие при нажатии "Убить" (X)
    KillBtn.MouseButton1Click:Connect(function()
        -- Ищем интерфейс чита в CoreGui и уничтожаем его
        local target = CoreGui:FindFirstChild(cheat.targetGui)
        if target then
            target:Destroy()
        end
        
        -- Экстренный сброс (Полезно для Fly, чтобы персонаж упал на землю)
        local char = Players.LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            for _, v in pairs(char.HumanoidRootPart:GetChildren()) do
                if v:IsA("BodyVelocity") or v:IsA("BodyGyro") then v:Destroy() end
            end
        end
    end)
end

-- Авто-подгонка скролла
Scroll.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 10)

-- ==========================================
-- ЭКРАН ЗАГРУЗКИ (LOADING SCREEN)
-- ==========================================
local LoadingFrame = Instance.new("Frame")
LoadingFrame.Size = UDim2.new(0, 400, 0, 300)
LoadingFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
LoadingFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
LoadingFrame.Parent = HubGui

local LoadCorner = Instance.new("UICorner")
LoadCorner.CornerRadius = UDim.new(0, 10)
LoadCorner.Parent = LoadingFrame

local LoadText = Instance.new("TextLabel")
LoadText.Size = UDim2.new(1, 0, 1, 0)
LoadText.BackgroundTransparency = 1
LoadText.Text = "Injecting LiteHub..."
LoadText.TextColor3 = Color3.fromRGB(0, 255, 128)
LoadText.Font = Enum.Font.GothamBold
LoadText.TextSize = 22
LoadText.Parent = LoadingFrame

-- Анимация загрузки
task.spawn(function()
    task.wait(0.5)
    LoadText.Text = "Loading Scripts..."
    task.wait(0.5)
    LoadText.Text = "Bypassing..."
    task.wait(0.6)
    
    -- Плавное исчезновение загрузки
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(LoadingFrame, tweenInfo, {BackgroundTransparency = 1}):Play()
    TweenService:Create(LoadText, tweenInfo, {TextTransparency = 1}):Play()
    
    task.wait(0.5)
    LoadingFrame:Destroy()
    MainFrame.Visible = true -- Показываем главный хаб
end)

-- ==========================================
-- ЛОГИКА СВОРАЧИВАНИЯ / ЗАКРЫТИЯ ХАБА
-- ==========================================
MinimizeBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    MiniCircle.Visible = true
end)

MiniCircle.MouseButton1Click:Connect(function()
    MiniCircle.Visible = false
    MainFrame.Visible = true
end)

CloseHubBtn.MouseButton1Click:Connect(function()
    HubGui:Destroy() -- Полностью убивает хаб
end)
