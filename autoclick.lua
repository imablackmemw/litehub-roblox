local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Главный контейнер
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AdvancedAutoclicker"
ScreenGui.Parent = game:CoreGui
ScreenGui.ResetOnSpawn = false

-- Хранилище данных о кликерах
local clickers = {} -- { [id] = { triggerFrame = Frame, ms = number, active = bool, thread = thread } }
local clickerCount = 0
local editMode = false

-- Вспомогательная функция для перетаскивания (Drag)
local function makeDraggable(guiObject)
	local dragging, dragInput, dragStart, startPos
	guiObject.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = guiObject.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	guiObject.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			guiObject.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

-- ==========================================
-- 1. МАЛЕНЬКАЯ КНОПКА (AC: OFF / AC: ON)
-- ==========================================
local MainToggle = Instance.new("TextButton")
MainToggle.Size = UDim2.new(0, 90, 0, 40)
MainToggle.Position = UDim2.new(0.05, 0, 0.2, 0)
MainToggle.BackgroundColor3 = Color3.fromRGB(255, 75, 75)
MainToggle.Text = "AC: OFF"
MainToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
MainToggle.Font = Enum.Font.SourceSansBold
MainToggle.TextSize = 18
MainToggle.Parent = ScreenGui
makeDraggable(MainToggle)

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainToggle

-- ==========================================
-- 2. ГЛАВНАЯ КНОПКА НАСТРОЕК (AC)
-- ==========================================
local MenuButton = Instance.new("TextButton")
MenuButton.Size = UDim2.new(0, 40, 0, 40)
MenuButton.Position = UDim2.new(0, 95, 0, 0) -- Справа от тумблера
MenuButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MenuButton.Text = "⚙️"
MenuButton.TextSize = 20
MenuButton.Parent = MainToggle

local MenuCorner = Instance.new("UICorner")
MenuCorner.CornerRadius = UDim.new(0, 8)
MenuCorner.Parent = MenuButton

-- ==========================================
-- 3. ОКНО МЕНЮ НАСТРОЕК
-- ==========================================
local MenuFrame = Instance.new("Frame")
MenuFrame.Size = UDim2.new(0, 320, 0, 380)
MenuFrame.Position = UDim2.new(0.5, -160, 0.5, -190)
MenuFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MenuFrame.Visible = false
MenuFrame.Parent = ScreenGui
makeDraggable(MenuFrame)

local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0, 12)
FrameCorner.Parent = MenuFrame

-- Размытие заднего фона (Blur)
local BlurEffect = Instance.new("BlurEffect")
BlurEffect.Size = 0
BlurEffect.Parent = game:GetService("Lighting")

-- Скролл-список кликеров в меню
local ScrollList = Instance.new("ScrollingFrame")
ScrollList.Size = UDim2.new(0, 300, 0, 240)
ScrollList.Position = UDim2.new(0, 10, 0, 50)
ScrollList.BackgroundTransparency = 1
ScrollList.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollList.ScrollBarThickness = 4
ScrollList.Parent = MenuFrame

local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 8)
ListLayout.Parent = ScrollList

-- Кнопка закрытия меню X
local CloseMenu = Instance.new("TextButton")
CloseMenu.Size = UDim2.new(0, 30, 0, 30)
CloseMenu.Position = UDim2.new(1, -35, 0, 5)
CloseMenu.BackgroundTransparency = 1
CloseMenu.Text = "✕"
CloseMenu.TextColor3 = Color3.fromRGB(150, 150, 150)
CloseMenu.TextSize = 18
CloseMenu.Parent = MenuFrame
CloseMenu.MouseButton1Click:Connect(function() MenuFrame.Visible = false BlurEffect.Size = 0 end)

-- Заголовок меню
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 200, 0, 40)
Title.Position = UDim2.new(0, 15, 0, 5)
Title.BackgroundTransparency = 1
Title.Text = "Настройки кликера"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 22
Title.Parent = MenuFrame

-- ==========================================
-- ПОДВАЛ МЕНЮ (КНОПКИ УПРАВЛЕНИЯ)
-- ==========================================
local MoveButton = Instance.new("TextButton")
MoveButton.Size = UDim2.new(0, 140, 0, 35)
MoveButton.Position = UDim2.new(0, 10, 1, -85)
MoveButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
MoveButton.Text = "MOVE TRIGGERS"
MoveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MoveButton.Font = Enum.Font.SourceSansBold
MoveButton.TextSize = 14
MoveButton.Parent = MenuFrame

local AddButton = Instance.new("TextButton")
AddButton.Size = UDim2.new(0, 140, 0, 35)
AddButton.Position = UDim2.new(0, 170, 1, -85)
AddButton.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
AddButton.Text = "+ Добавить точку"
AddButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AddButton.Font = Enum.Font.SourceSansBold
AddButton.TextSize = 14
AddButton.Parent = MenuFrame

for _, btn in pairs({MoveButton, AddButton}) do
	local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, 6) c.Parent = btn
end

-- Панель сохранения для MOVE TRIGGERS (снизу экрана)
local SaveFrame = Instance.new("Frame")
SaveFrame.Size = UDim2.new(0, 300, 0, 50)
SaveFrame.Position = UDim2.new(0.5, -150, 1, -70)
SaveFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
SaveFrame.Visible = false
SaveFrame.Parent = ScreenGui

local SaveCorner = Instance.new("UICorner") SaveCorner.CornerRadius = UDim.new(0, 8) SaveCorner.Parent = SaveFrame

local CancelBtn = Instance.new("TextButton")
CancelBtn.Size = UDim2.new(0, 130, 0, 35)
CancelBtn.Position = UDim2.new(0, 10, 0, 7)
CancelBtn.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
CancelBtn.Text = "Назад"
CancelBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CancelBtn.Font = Enum.Font.SourceSansBold
CancelBtn.Parent = SaveFrame

local SaveBtn = Instance.new("TextButton")
SaveBtn.Size = UDim2.new(0, 130, 0, 35)
SaveBtn.Position = UDim2.new(0, 160, 0, 7)
SaveBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
SaveBtn.Text = "Готово"
SaveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SaveBtn.Font = Enum.Font.SourceSansBold
SaveBtn.Parent = SaveFrame

for _, btn in pairs({CancelBtn, SaveBtn}) do
	local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, 6) c.Parent = btn
end

-- ==========================================
-- ЛОГИКА СИМУЛЯЦИИ КЛИКОВ (Virtual Click)
-- ==========================================
local function clickAt(x, y)
	-- Симуляция тача/клика через VirtualUser для инжекторов
	local vu = game:GetService("VirtualUser")
	vu:CaptureController()
	vu:Button1Down(Vector2.new(x, y))
	task.wait(0.01)
	vu:Button1Up(Vector2.new(x, y))
end

local function startClicking(id)
	local data = clickers[id]
	if not data then return end
	if data.thread then task.cancel(data.thread) end
	
	data.thread = task.spawn(function()
		while data.active and MainToggle.Text == "AC: ON" do
			local trig = data.triggerFrame
			if trig and trig.Visible then
				local x = trig.AbsolutePosition.X + (trig.AbsoluteSize.X / 2)
				local y = trig.AbsolutePosition.Y + (trig.AbsoluteSize.Y / 2) + 36 -- +36 учитываетTopbar Роблокса
				clickAt(x, y)
			end
			task.wait(data.ms / 1000)
		end
	end)
end

-- ==========================================
-- УПРАВЛЕНИЕ КЛИКЕРАМИ (СОЗДАНИЕ / УДАЛЕНИЕ)
-- ==========================================
local savedPositions = {}

local function createClickerElement(id, initialMs)
	clickerCount = clickerCount + 1
	local ms = initialMs or 300
	
	-- 1. Создаем сам триггер-мишень на экране
	local Trigger = Instance.new("Frame")
	Trigger.Size = UDim2.new(0, 30, 0, 30)
	Trigger.Position = UDim2.new(0.4 + (id*0.02), 0, 0.4, 0)
	Trigger.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
	Trigger.BackgroundTransparency = 0.3
	Trigger.Visible = false -- Изначально триггеры скрыты, видны только при MOVE TRIGGERS
	Trigger.Parent = ScreenGui
	
	local tc = Instance.new("UICorner") tc.CornerRadius = UDim.new(1, 0) tc.Parent = Trigger
	local tl = Instance.new("TextLabel") tl.Size = UDim2.new(1,0,1,0) tl.BackgroundTransparency = 1 tl.Text = tostring(id) tl.TextColor3 = Color3.fromRGB(0,0,0) tl.Font = Enum.Font.SourceSansBold tl.TextSize = 14 tl.Parent = Trigger
	
	makeDraggable(Trigger)
	
	-- 2. Создаем строку управления в меню настроек
	local ListRow = Instance.new("Frame")
	ListRow.Size = UDim2.new(0, 285, 0, 45)
	ListRow.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	ListRow.Parent = ScrollList
	
	local rc = Instance.new("UICorner") rc.CornerRadius = UDim.new(0, 6) rc.Parent = ListRow
	
	local RowLabel = Instance.new("TextLabel")
	RowLabel.Size = UDim2.new(0, 80, 0, 45)
	RowLabel.Position = UDim2.new(0, 10, 0, 0)
	RowLabel.BackgroundTransparency = 1
	RowLabel.Text = "Точка #" .. id .. " (мс):"
	RowLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	RowLabel.Font = Enum.Font.SourceSans
	RowLabel.TextSize = 14
	RowLabel.TextXAlignment = Enum.TextXAlignment.Left
	RowLabel.Parent = ListRow
	
	-- Поле ввода задержки (мс)
	local TextBox = Instance.new("TextBox")
	TextBox.Size = UDim2.new(0, 60, 0, 25)
	TextBox.Position = UDim2.new(0, 100, 0, 10)
	TextBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	TextBox.Text = tostring(ms)
	TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
	TextBox.Font = Enum.Font.SourceSansBold
	TextBox.TextSize = 14
	TextBox.Parent = ListRow
	
	local tbc = Instance.new("UICorner") tbc.CornerRadius = UDim.new(0, 4) tbc.Parent = TextBox
	
	-- Кнопка Удалить
	local DeleteBtn = Instance.new("TextButton")
	DeleteBtn.Size = UDim2.new(0, 70, 0, 25)
	DeleteBtn.Position = UDim2.new(1, -80, 0, 10)
	DeleteBtn.BackgroundColor3 = Color3.fromRGB(192, 41, 43)
	DeleteBtn.Text = "Удалить"
	DeleteBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	DeleteBtn.Font = Enum.Font.SourceSansBold
	DeleteBtn.TextSize = 12
	DeleteBtn.Parent = ListRow
	
	local dc = Instance.new("UICorner") dc.CornerRadius = UDim.new(0, 4) dc.Parent = DeleteBtn
	
	clickers[id] = { triggerFrame = Trigger, ms = ms, active = true, thread = nil, uiRow = ListRow }
	ScrollList.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 10)
	
	-- Обработка изменения задержки
	TextBox.FocusLost:Connect(function()
		local num = tonumber(TextBox.Text)
		if num and num >= 1 then
			clickers[id].ms = num
		else
			TextBox.Text = tostring(clickers[id].ms)
		end
	end)
	
	-- Логика удаления
	DeleteBtn.MouseButton1Click:Connect(function()
		if clickers[id].thread then task.cancel(clickers[id].thread) end
		Trigger:Destroy()
		ListRow:Destroy()
		clickers[id] = nil
		ScrollList.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y - 45)
	end)
end

-- Создаем изначальную 1 точку (по дефолту на 300 мс)
createClickerElement(1, 300)

-- Добавление новых точек через кнопку меню
local nextId = 2
AddButton.MouseButton1Click:Connect(function()
	createClickerElement(nextId, 300)
	nextId = nextId + 1
end)

-- Окно меню настроек (Показ/Скрытие)
MenuButton.MouseButton1Click:Connect(function()
	MenuFrame.Visible = not MenuFrame.Visible
	BlurEffect.Size = MenuFrame.Visible and 15 or 0
end)

-- ==========================================
-- РЕЖИМ ПЕРЕМЕЩЕНИЯ (MOVE TRIGGERS)
-- ==========================================
MoveButton.MouseButton1Click:Connect(function()
	MenuFrame.Visible = false
	SaveFrame.Visible = true
	editMode = true
	BlurEffect.Size = 8 -- Легкое размытие в режиме редактирования
	
	-- Запоминаем старые позиции и делаем триггеры видимыми
	savedPositions = {}
	for id, data in pairs(clickers) do
		savedPositions[id] = data.triggerFrame.Position
		data.triggerFrame.Visible = true
		data.triggerFrame.BackgroundColor3 = Color3.fromRGB(255, 165, 0) -- Оранжевые во время перемещения
	end
end)

-- Назад (Не сохранять)
CancelBtn.MouseButton1Click:Connect(function()
	SaveFrame.Visible = false
	MenuFrame.Visible = true
	editMode = false
	BlurEffect.Size = 15
	
	for id, data in pairs(clickers) do
		if savedPositions[id] then
			data.triggerFrame.Position = savedPositions[id]
		end
		data.triggerFrame.Visible = false
		data.triggerFrame.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
	end
end)

-- Готово (Сохранить)
SaveBtn.MouseButton1Click:Connect(function()
	SaveFrame.Visible = false
	MenuFrame.Visible = true
	editMode = false
	BlurEffect.Size = 15
	
	for id, data in pairs(clickers) do
		data.triggerFrame.Visible = false
		data.triggerFrame.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
	end
end)

-- ==========================================
-- ВКЛЮЧЕНИЕ / ВЫКЛЮЧЕНИЕ КЛИКЕРА (Тумблер)
-- ==========================================
MainToggle.MouseButton1Click:Connect(function()
	if editMode then return end -- Нельзя включать кликер во время редактирования позиций
	
	if MainToggle.Text == "AC: OFF" then
		MainToggle.Text = "AC: ON"
		MainToggle.BackgroundColor3 = Color3.fromRGB(75, 255, 75)
		
		-- Запуск потоков кликов
		for id, data in pairs(clickers) do
			data.active = true
			startClicking(id)
		end
	else
		MainToggle.Text = "AC: OFF"
		MainToggle.BackgroundColor3 = Color3.fromRGB(255, 75, 75)
		
		-- Остановка всех кликеров
		for id, data in pairs(clickers) do
			data.active = false
			if data.thread then
				task.cancel(data.thread)
				data.thread = nil
			end
		end
	end
end)
