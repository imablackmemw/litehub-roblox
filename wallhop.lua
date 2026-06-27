local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "WallhopCheat"

local btn = Instance.new("TextButton", ScreenGui)
btn.Size = UDim2.new(0, 100, 0, 50)
btn.Position = UDim2.new(0.1, 0, 0.4, 0)
btn.Text = "Wallhop: OFF"
btn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
btn.Draggable = true

local enabled = false
btn.MouseButton1Click:Connect(function()
    enabled = not enabled
    btn.Text = enabled and "Wallhop: ON" or "Wallhop: OFF"
    btn.BackgroundColor3 = enabled and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
end)

RunService.RenderStepped:Connect(function()
    if enabled then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
            local hrp = char.HumanoidRootPart
            -- Проверка: если мы зажали пробел и перед нами есть объект
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                local ray = Ray.new(hrp.Position, hrp.CFrame.LookVector * 3)
                local hit, pos = workspace:FindPartOnRay(ray, char)
                
                if hit then
                    char.Humanoid.JumpPower = 50 -- Стандартный прыжок
                    char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end
    end
end)
