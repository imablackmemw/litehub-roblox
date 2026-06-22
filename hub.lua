-- LiteHub for Delta (compact mobile UI)
-- Скрипт создаёт мини-меню с быстрой загрузкой скриптов по прямым ссылкам
-- Защита от дубликатов, перетаскиваемое окно, кнопка-триггер.

local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

-- Таблица для отслеживания уже загруженных скриптов
local loadedURLs = {}

-- Убедимся, что скрипт не задвоится сам
if CoreGui:FindFirstChild("LiteHub_Main") then
    return print("LiteHub уже запущен!")
end

-- Основной ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LiteHub_Main"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- Главный фрейм (компактное меню)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 200, 0, 250)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

-- Скругление углов главного фрейма
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = MainFrame

-- Тень для красоты (опционально)
local shadow = Instance.new("ImageLabel")
shadow.Image = "rbxassetid://6015897843"
shadow.Size = UDim2.new(1, 20, 1, 20)
shadow.Position = UDim2.new(0, -10, 0, -10)
shadow.BackgroundTransparency = 1
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(10,10,10,10)
shadow.Parent = MainFrame

MainFrame.Parent = ScreenGui

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Text = "LiteHub"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, -30, 0, 30)
Title.Position = UDim2.new(0, 10, 0, 5)
Title.Parent = MainFrame

-- Кнопка "Скрыть" (крестик)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Text = "✕"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.TextColor3 = Color3.new(1,0.3,0.3)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(1, -28, 0, 8)
CloseBtn.Parent = MainFrame

-- Маленькая круглая кнопка-триггер (показывается всегда)
local ToggleBtn = Instance.new("Frame")
ToggleBtn.Name = "ToggleBtn"
ToggleBtn.Size = UDim2.new(0, 40, 0, 40)
ToggleBtn.AnchorPoint = Vector2.new(1, 0)
ToggleBtn.Position = UDim2.new(1, -10, 0, 10)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
ToggleBtn.BorderSizePixel = 0
ToggleBtn.Active = true
ToggleBtn.Draggable = true
local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(1, 0)
toggleCorner.Parent = ToggleBtn
local toggleLabel = Instance.new("TextLabel")
toggleLabel.Text = "LH"
toggleLabel.Font = Enum.Font.GothamBold
toggleLabel.TextSize = 14
toggleLabel.TextColor3 = Color3.new(1,1,1)
toggleLabel.BackgroundTransparency = 1
toggleLabel.Size = UDim2.new(1,0,1,0)
toggleLabel.Parent = ToggleBtn
ToggleBtn.Parent = ScreenGui

-- Контейнер для кнопок внутри MainFrame
local BtnFrame = Instance.new("Frame")
BtnFrame.Name = "BtnFrame"
BtnFrame.Size = UDim2.new(1, -20, 1, -60)
BtnFrame.Position = UDim2.new(0, 10, 0, 45)
BtnFrame.BackgroundTransparency = 1
BtnFrame.Parent = MainFrame

-- Список кнопок
local buttons = {
    { Name = "Teleport",    URL = "https://raw.githubusercontent.com/imablackmemw/litehub-roblox/refs/heads/main/main.lua" },
    { Name = "Fly",         URL = "https://raw.githubusercontent.com/imablackmemw/litehub-roblox/refs/heads/main/fly.lua" },
    { Name = "Combat",      URL = "https://raw.githubusercontent.com/imablackmemw/litehub-roblox/refs/heads/main/combat.lua" },
    { Name = "Brookhaven",  URL = "https://raw.githubusercontent.com/imablackmemw/litehub-roblox/refs/heads/main/bh.lua" }
}

-- Функция создания кнопки
local function createButton(name, url, yPos)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Text = name
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.TextColor3 = Color3.new(1,1,1)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.BorderSizePixel = 0
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.Position = UDim2.new(0, 0, 0, yPos)
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn

    -- Событие нажатия
    btn.MouseButton1Click:Connect(function()
        -- Проверка дубликата
        if loadedURLs[url] then
            print("Скрипт уже запущен: " .. name)
            return
        end
        -- Загрузка и выполнение скрипта
        local success, err = pcall(function()
            loadstring(game:HttpGet(url))()
        end)
        if success then
            loadedURLs[url] = true
            print("Скрипт загружен: " .. name)
        else
            warn("Ошибка загрузки " .. name .. ": " .. tostring(err))
        end
    end)

    return btn
end

-- Размещаем кнопки внутри BtnFrame
for i, btnData in ipairs(buttons) do
    local btn = createButton(btnData.Name, btnData.URL, (i-1)*40)
    btn.Parent = BtnFrame
end

-- Логика показа/скрытия меню
local function hideMain()
    MainFrame.Visible = false
end

local function showMain()
    MainFrame.Visible = true
end

CloseBtn.MouseButton1Click:Connect(hideMain)
ToggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if MainFrame.Visible then
            hideMain()
        else
            showMain()
        end
    end
end)

-- Чтобы кнопка-триггер не перекрывала меню при перетаскивании
ToggleBtn.DragStopped:Connect(function()
    -- Ничего, оставляем позицию
end)

print("LiteHub загружен! Кнопка-триггер в правом верхнем углу.")
