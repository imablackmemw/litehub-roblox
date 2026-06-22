-- ==============================================================================
-- 🌟 LITEHUB MANAGER - ФИНАЛЬНАЯ ВЕРСИЯ
-- ==============================================================================
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

-- Список твоих скриптов
local MyScripts = {
    ["Teleport Manager"] = "https://raw.githubusercontent.com/imablackmemw/litehub-roblox/refs/heads/main/main.lua",
    ["Fly Pack"] = "https://raw.githubusercontent.com/imablackmemw/litehub-roblox/refs/heads/main/fly.lua",
    ["Combat Pack"] = "https://raw.githubusercontent.com/imablackmemw/litehub-roblox/refs/heads/main/combat.lua",
    ["Liteheaven RP"] = "https://raw.githubusercontent.com/imablackmemw/litehub-roblox/refs/heads/main/bh.lua"
}

-- Удаляем старое меню, если оно есть
if CoreGui:FindFirstChild("LiteHubManager") then CoreGui.LiteHubManager:Destroy() end

local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "LiteHubManager"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 220, 0, 320)
MainFrame.Position = UDim2.new(0.5, -110, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

-- Заголовок
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "LiteHub Manager"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.BackgroundTransparency = 1

local List = Instance.new("UIListLayout", MainFrame)
List.Padding = UDim.new(0, 10)
List.PaddingTop = UDim.new(0, 45)
List.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Функция безопасной загрузки
local function ExecuteScript(name, url)
    -- Проверка: если GUI скрипта уже существует, не запускаем
    -- (предполагаем, что каждый твой скрипт создает GUI с похожим именем)
    if CoreGui:FindFirstChild(name) then
        print(name .. " уже работает!")
        return
    end
    
    local success, err = pcall(function()
        loadstring(game:HttpGet(url))()
    end)
    
    if success then
        print("Загружен: " .. name)
    else
        warn("Ошибка запуска " .. name .. ": " .. err)
    end
end

-- Создаем кнопки для каждого скрипта из списка
for name, url in pairs(MyScripts) do
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(0.9, 0, 0, 40)
    btn.Text = "Запустить " .. name
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamSemibold
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    btn.MouseButton1Click:Connect(function()
        ExecuteScript(name, url)
    end)
end

-- Кнопка закрытия
local HideBtn = Instance.new("TextButton", MainFrame)
HideBtn.Size = UDim2.new(0.9, 0, 0, 40)
HideBtn.Text = "Скрыть навсегда"
HideBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
HideBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
HideBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

