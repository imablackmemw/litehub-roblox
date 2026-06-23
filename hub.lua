-- ==============================================================================
-- 🌟 LITEHUB V3 (MINIMAL EDITION)
-- ==============================================================================
local CoreGui = game:GetService("CoreGui")

-- Удаляем старую версию хаба, если она уже открыта
if CoreGui:FindFirstChild("LiteHub_V3") then 
    CoreGui.LiteHub_V3:Destroy() 
end

local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "LiteHub_V3"

-- Ссылки на твои скрипты
local Scripts = {
    ["Телепорт PRO"] = "https://raw.githubusercontent.com/imablackmemw/litehub-roblox/refs/heads/main/main.lua",
    ["Fly Pack"] = "https://raw.githubusercontent.com/imablackmemw/litehub-roblox/refs/heads/main/fly.lua"
}

-- ==============================================================================
-- 🎨 ИНТЕРФЕЙС
-- ==============================================================================

-- Летающий кружок (когда хаб свернут)
local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Size = UDim2.new(0, 45, 0, 45)
OpenBtn.Position = UDim2.new(0.05, 0, 0.15, 0)
OpenBtn.BackgroundColor3 = Color3.fromRGB(130, 50, 255)
OpenBtn.Text = "Hub"
OpenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.TextSize = 14
OpenBtn.Visible = false
OpenBtn.Active = true
OpenBtn.Draggable = true
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)

-- Главное меню
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 220, 0, 240)
MainFrame.Position = UDim2.new(0.5, -110, 0.5, -120)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- Верхняя панель (Хедер)
local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 35)
Header.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 10)
local HeaderFix = Instance.new("Frame", Header)
HeaderFix.Size = UDim2.new(1, 0, 0, 10)
HeaderFix.Position = UDim2.new(0, 0, 1, -10)
HeaderFix.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
HeaderFix.BorderSizePixel = 0

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(0.7, 0, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.Text = "LITEHUB V3"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1

-- Кнопка свернуть "_"
local MinimizeBtn = Instance.new("TextButton", Header)
MinimizeBtn.Size = UDim2.new(0, 30, 0, 25)
MinimizeBtn.Position = UDim2.new(1, -35, 0, 5)
MinimizeBtn.Text = "_"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
MinimizeBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 6)

-- Вкладки (Скрипты и Настройки)
local TabContainer = Instance.new("Frame", MainFrame)
TabContainer.Size = UDim2.new(1, 0, 1, -40)
TabContainer.Position = UDim2.new(0, 0, 0, 40)
TabContainer.BackgroundTransparency = 1

local ScriptsTab = Instance.new("Frame", TabContainer)
ScriptsTab.Size = UDim2.new(1, 0, 1, 0)
ScriptsTab.BackgroundTransparency = 1

local SettingsTab = Instance.new("Frame", TabContainer)
SettingsTab.Size = UDim2.new(1, 0, 1, 0)
SettingsTab.BackgroundTransparency = 1
SettingsTab.Visible = false

local ScriptsLayout = Instance.new("UIListLayout", ScriptsTab)
ScriptsLayout.Padding = UDim.new(0, 8)
ScriptsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
Instance.new("Frame", ScriptsTab).Size = UDim2.new(1,0,0,2) -- Отступ сверху

local SettingsLayout = Instance.new("UIListLayout", SettingsTab)
SettingsLayout.Padding = UDim.new(0, 8)
SettingsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
Instance.new("Frame", SettingsTab).Size = UDim2.new(1,0,0,2) -- Отступ сверху

-- ==============================================================================
-- ⚙️ ФУНКЦИИ И КНОПКИ
-- ==============================================================================

local function CreateButton(parent, text, color, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Text = text
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Создаем кнопки для скриптов
for name, url in pairs(Scripts) do
    CreateButton(ScriptsTab, "🚀 Запустить: " .. name, Color3.fromRGB(45, 45, 55), function()
        pcall(function()
            loadstring(game:HttpGet(url))()
        end)
    end)
end

-- Кнопка перехода в настройки
CreateButton(ScriptsTab, "⚙️ Настройки", Color3.fromRGB(70, 50, 120), function()
    ScriptsTab.Visible = false
    SettingsTab.Visible = true
end)

-- Кнопки в настройках
CreateButton(SettingsTab, "◀️ Назад", Color3.fromRGB(45, 45, 55), function()
    SettingsTab.Visible = false
    ScriptsTab.Visible = true
end)

CreateButton(SettingsTab, "❌ Закрыть Хаб", Color3.fromRGB(180, 50, 50), function()
    ScreenGui:Destroy()
end)

-- Логика сворачивания
MinimizeBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    OpenBtn.Visible = true
end)

OpenBtn.MouseButton1Click:Connect(function()
    OpenBtn.Visible = false
    MainFrame.Visible = true
end)

print("LiteHub V3 Загружен! Успешной игры!")

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
