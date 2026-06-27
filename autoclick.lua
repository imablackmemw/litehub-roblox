-- Минималистичный и надежный вариант для Codex
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AdvancedAutoclicker"
ScreenGui.Parent = CoreGui 
ScreenGui.ResetOnSpawn = false

local btn = Instance.new("TextButton", ScreenGui)
btn.Size = UDim2.new(0, 100, 0, 50)
btn.Position = UDim2.new(0.5, 0, 0.5, 0)
btn.Text = "OFF"
btn.BackgroundColor3 = Color3.new(1, 0, 0)
btn.Active = true
btn.Draggable = true -- Встроенный драг от Роблокса, чтобы точно работало

local toggled = false
btn.MouseButton1Click:Connect(function()
    toggled = not toggled
    btn.Text = toggled and "ON" or "OFF"
    btn.BackgroundColor3 = toggled and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
    
    while toggled do
        VirtualUser:CaptureController()
        VirtualUser:ClickButton1(Vector2.new(0,0))
        task.wait(0.1)
    end
end)
