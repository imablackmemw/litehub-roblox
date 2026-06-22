-- ==============================================================================
-- 🎯 LITEXUTOR COMBAT PACK v1.0 PRO
-- Мувмент, ВХ и Аимбот в одном кастомном UI-модуле!
-- ==============================================================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Глобальные переменные состояний
local Config = {
    InfJump = false,
    Noclip = false,
    ESP = false,
    Aimbot = false,
    WalkSpeed = 16,
    JumpPower = 50,
    FOV = 70
}

local ESP_Folder = Instance.new("Folder")
ESP_Folder.Name = "LitexutorESP"
ESP_Folder.Parent = CoreGui

-- Защита от двойного запуска
if CoreGui:FindFirstChild("LitexutorCombatPRO") then
    CoreGui.LitexutorCombatPRO:Destroy()
end

-- ==============================================================================
-- 🎨 СОЗДАНИЕ ИНТЕРФЕЙСА (UI)
-- ==============================================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LitexutorCombatPRO"
ScreenGui.ResetOnSpawn = false
local success = pcall(function() ScreenGui.Parent = CoreGui end)
if not success then ScreenGui.Parent = Player:WaitForChild("PlayerGui") end

-- 1. ЛЕТАЮЩАЯ КНОПКА (Свернутое меню)
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Parent = ScreenGui
ToggleBtn.Size = UDim2.new(0, 65, 0, 65)
ToggleBtn.Position = UDim2.new(0, 20, 0, 300)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
ToggleBtn.Text = "COMBAT"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 12
ToggleBtn.Active = true
ToggleBtn.Draggable = true
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)

-- 2. ГЛАВНОЕ МЕНЮ
local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 350, 0, 320)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- ВЕРХНЯЯ ПАНЕЛЬ
local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Litexutor Combat PRO"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
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

-- ВКЛАДКИ
local TabBar = Instance.new("Frame", MainFrame)
TabBar.Size = UDim2.new(1, 0, 0, 35)
TabBar.Position = UDim2.new(0, 0, 0, 40)
TabBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

local TabLayout = Instance.new("UIListLayout", TabBar)
TabLayout.FillDirection = Enum.FillDirection.Horizontal

local function CreateTabBtn(name, text)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(0.333, 0, 1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(150, 150, 150)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 13
    btn.BorderSizePixel = 0
    return btn
end

local Tab1Btn = CreateTabBtn("Tab1", "Main")
local Tab2Btn = CreateTabBtn("Tab2", "Visuals")
local Tab3Btn = CreateTabBtn("Tab3", "Combat")
Tab1Btn.Parent = TabBar
Tab2Btn.Parent = TabBar
Tab3Btn.Parent = TabBar

-- КОНТЕЙНЕРЫ ВКЛАДОК
local Content = Instance.new("Frame", MainFrame)
Content.Size = UDim2.new(1, 0, 1, -75)
Content.Position = UDim2.new(0, 0, 0, 75)
Content.BackgroundTransparency = 1

local Tab1Frame = Instance.new("Frame", Content)
Tab1Frame.Size = UDim2.new(1, 0, 1, 0)
Tab1Frame.BackgroundTransparency = 1

local Tab2Frame = Instance.new("Frame", Content)
Tab2Frame.Size = UDim2.new(1, 0, 1, 0)
Tab2Frame.BackgroundTransparency = 1
Tab2Frame.Visible = false

local Tab3Frame = Instance.new("Frame", Content)
Tab3Frame.Size = UDim2.new(1, 0, 1, 0)
Tab3Frame.BackgroundTransparency = 1
Tab3Frame.Visible = false

-- УТИЛИТА ДЛЯ СОЗДАНИЯ ЭЛЕМЕНТОВ
local function CreateToggle(parent, yPos, text, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, -20, 0, 35)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.Text = text .. ": OFF"
    btn.TextColor3 = Color3.fromRGB(255, 100, 100)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(40, 140, 60) or Color3.fromRGB(60, 60, 60)
        btn.TextColor3 = state and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
        btn.Text = text .. (state and ": ON" or ": OFF")
        callback(state)
    end)
end

local function CreateInput(parent, yPos, text, default, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -20, 0, 35)
    frame.Position = UDim2.new(0, 10, 0, yPos)
    frame.BackgroundTransparency = 1

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left

    local box = Instance.new("TextBox", frame)
    box.Size = UDim2.new(0.4, 0, 1, 0)
    box.Position = UDim2.new(0.6, 0, 0, 0)
    box.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    box.Text = tostring(default)
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.Font = Enum.Font.GothamBold
    box.TextSize = 14
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)

    box.FocusLost:Connect(function()
        local val = tonumber(box.Text)
        if val then callback(val) else box.Text = tostring(default) end
    end)
end

-- НАПОЛНЕНИЕ ВКЛАДОК
-- Tab 1: Main
CreateInput(Tab1Frame, 10, "WalkSpeed (Скорость)", 16, function(val)
    Config.WalkSpeed = val
    if Player.Character and Player.Character:FindFirstChild("Humanoid") then
        Player.Character.Humanoid.WalkSpeed = val
    end
end)

CreateInput(Tab1Frame, 55, "JumpPower (Прыжок)", 50, function(val)
    Config.JumpPower = val
    if Player.Character and Player.Character:FindFirstChild("Humanoid") then
        Player.Character.Humanoid.UseJumpPower = true
        Player.Character.Humanoid.JumpPower = val
    end
end)

CreateInput(Tab1Frame, 100, "Camera FOV (Поле зрения)", 70, function(val)
    Config.FOV = val
    Camera.FieldOfView = val
end)

CreateToggle(Tab1Frame, 145, "Infinite Jump (Беск. прыжок)", function(state) Config.InfJump = state end)
CreateToggle(Tab1Frame, 190, "Noclip (Сквозь стены)", function(state) Config.Noclip = state end)

-- Tab 2: Visuals
CreateToggle(Tab2Frame, 10, "Player ESP (ВХ)", function(state) 
    Config.ESP = state 
    if not state then ESP_Folder:ClearAllChildren() end
end)

-- Tab 3: Combat
CreateToggle(Tab3Frame, 10, "Silent Aimbot (Авто-наводка)", function(state) Config.Aimbot = state end)


-- ==============================================================================
-- ⚙️ ЛОГИКА ИНТЕРФЕЙСА И ВКЛАДОК
-- ==============================================================================

local function SwitchTab(tabId)
    Tab1Frame.Visible = (tabId == 1)
    Tab2Frame.Visible = (tabId == 2)
    Tab3Frame.Visible = (tabId == 3)
    Tab1Btn.TextColor3 = tabId == 1 and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)
    Tab2Btn.TextColor3 = tabId == 2 and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)
    Tab3Btn.TextColor3 = tabId == 3 and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)
end

Tab1Btn.MouseButton1Click:Connect(function() SwitchTab(1) end)
Tab2Btn.MouseButton1Click:Connect(function() SwitchTab(2) end)
Tab3Btn.MouseButton1Click:Connect(function() SwitchTab(3) end)
SwitchTab(1)

ToggleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)


-- ==============================================================================
-- 🚀 ИГРОВАЯ ЛОГИКА И ХАКИ
-- ==============================================================================

-- 1. Бесконечный прыжок
UserInputService.JumpRequest:Connect(function()
    if Config.InfJump and Player.Character and Player.Character:FindFirstChild("Humanoid") then
        Player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- 2. Переназначение скорости при возрождении
Player.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    task.wait(0.5)
    hum.WalkSpeed = Config.WalkSpeed
    hum.UseJumpPower = true
    hum.JumpPower = Config.JumpPower
    Camera.FieldOfView = Config.FOV
end)

-- Логика ВХ (ESP)
local function UpdateESP()
    if not Config.ESP then return end
    
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= Player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
            
            local char = v.Character
            local espName = "ESP_" .. v.Name
            
            -- Если ЕСП для игрока еще нет, создаем
            if not ESP_Folder:FindFirstChild(espName) then
                local hl = Instance.new("Highlight")
                hl.Name = espName
                hl.Parent = ESP_Folder
                hl.Adornee = char
                hl.FillTransparency = 0.5
                hl.FillColor = Color3.fromRGB(255, 0, 0)
                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                
                -- Текст над головой
                local bgui = Instance.new("BillboardGui", hl)
                bgui.Name = "NameTag"
                bgui.AlwaysOnTop = true
                bgui.Size = UDim2.new(0, 100, 0, 30)
                bgui.StudsOffset = Vector3.new(0, 3, 0)
                bgui.Adornee = char:FindFirstChild("Head")
                
                local txt = Instance.new("TextLabel", bgui)
                txt.Size = UDim2.new(1, 0, 1, 0)
                txt.BackgroundTransparency = 1
                txt.Text = v.Name
                txt.TextColor3 = Color3.fromRGB(255, 255, 255)
                txt.TextStrokeTransparency = 0
                txt.Font = Enum.Font.GothamBold
                txt.TextSize = 12
            else
                -- Обновляем привязку, если персонаж ресетнулся
                local hl = ESP_Folder:FindFirstChild(espName)
                if hl.Adornee ~= char then
                    hl.Adornee = char
                    if hl:FindFirstChild("NameTag") and char:FindFirstChild("Head") then
                        hl.NameTag.Adornee = char.Head
                    end
                end
            end
        else
            -- Удаляем ЕСП, если игрок умер или вышел
            if ESP_Folder:FindFirstChild("ESP_" .. v.Name) then
                ESP_Folder:FindFirstChild("ESP_" .. v.Name):Destroy()
            end
        end
    end
end

-- Логика Аимбота (Поиск ближайшего)
local function GetClosestPlayer()
    local closest = nil
    local shortestDistance = math.huge

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= Player and v.Character and v.Character:FindFirstChild("Head") and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
            -- Проверка на команду (TeamCheck)
            if v.Team ~= Player.Team or Player.Team == nil then
                local pos = v.Character.Head.Position
                local distance = (Camera.CFrame.Position - pos).Magnitude
                
                if distance < shortestDistance then
                    closest = v.Character.Head
                    shortestDistance = distance
                end
            end
        end
    end
    return closest
end

-- Основной цикл (RenderStepped) для Ноуклипа, ВХ и Аимбота
RunService.RenderStepped:Connect(function()
    -- Noclip
    if Config.Noclip and Player.Character then
        for _, part in pairs(Player.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
    
    -- Обновление ВХ
    UpdateESP()
    
    -- Aimbot
    if Config.Aimbot then
        local target = GetClosestPlayer()
        if target then
            -- Мгновенно наводим камеру на голову врага
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
        end
    end
end)

print("LITEXUTOR COMBAT PRO ЗАГРУЖЕН! УДАЧНОЙ ОХОТЫ!")

