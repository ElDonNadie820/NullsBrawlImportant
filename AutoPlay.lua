-- Auto Piano Mejorado: String/URL + Intervalo Dinámico
local Players             = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService          = game:GetService("RunService")
local HttpService         = game:GetService("HttpService")

local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "AutoPianoGUI"
gui.ResetOnSpawn = false

-- Estado
local songText = ""
local playing  = false
local paused   = false
local idx      = 1
local interval = 0.25  -- valor por defecto

-- Simula presionar una tecla
local function pressKey(key)
    VirtualInputManager:SendKeyEvent(true, key, false, game)
    task.wait(0.05)
    VirtualInputManager:SendKeyEvent(false, key, false, game)
end

-- Bucle de reproducción
local function playLoop()
    playing = true
    paused  = false
    while playing and idx <= #songText do
        if paused then
            RunService.RenderStepped:Wait()
        else
            local c = songText:sub(idx, idx)
            pressKey(c)
            idx += 1
            task.wait(interval)
        end
    end
    playing = false
end

-- Construcción de la GUI
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 480, 0, 230)
frame.Position = UDim2.new(0, 20, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
frame.BorderSizePixel = 0

-- Label y TextBox para String/URL
local label1 = Instance.new("TextLabel", frame)
label1.Size = UDim2.new(1, 0, 0, 25)
label1.Position = UDim2.new(0, 0, 0, 0)
label1.Text = "Put string or URL:"
label1.Font = Enum.Font.GothamBold
label1.TextSize = 18
label1.TextColor3 = Color3.fromRGB(255,255,255)
label1.BackgroundTransparency = 1

local input = Instance.new("TextBox", frame)
input.Size = UDim2.new(1, -20, 0, 45)
input.Position = UDim2.new(0, 10, 0, 25)
input.PlaceholderText = "e.g. qwertyasdf... or https://raw.githubusercontent.com/..."
input.ClearTextOnFocus = false
input.TextWrapped = true
input.TextXAlignment = Enum.TextXAlignment.Left
input.TextColor3 = Color3.fromRGB(230,230,230)
input.BackgroundColor3 = Color3.fromRGB(45,45,45)
input.Font = Enum.Font.Code
input.TextSize = 18

-- Label y TextBox para el intervalo
local label2 = Instance.new("TextLabel", frame)
label2.Size = UDim2.new(1, 0, 0, 25)
label2.Position = UDim2.new(0, 0, 0, 75)
label2.Text = "Interval (seconds):"
label2.Font = Enum.Font.GothamBold
label2.TextSize = 18
label2.TextColor3 = Color3.fromRGB(255,255,255)
label2.BackgroundTransparency = 1

local intervalInput = Instance.new("TextBox", frame)
intervalInput.Size = UDim2.new(0, 120, 0, 40)
intervalInput.Position = UDim2.new(0, 150, 0, 75)
intervalInput.PlaceholderText = tostring(interval)
intervalInput.ClearTextOnFocus = false
intervalInput.Text = ""
intervalInput.TextColor3 = Color3.fromRGB(230,230,230)
intervalInput.BackgroundColor3 = Color3.fromRGB(45,45,45)
intervalInput.Font = Enum.Font.Code
intervalInput.TextSize = 18

-- Botones
local startBtn = Instance.new("TextButton", frame)
startBtn.Size = UDim2.new(0, 120, 0, 40)
startBtn.Position = UDim2.new(0, 10, 0, 130)
startBtn.Text = "▶️ Start"
startBtn.Font = Enum.Font.GothamBold
startBtn.TextSize = 18
startBtn.TextColor3 = Color3.fromRGB(255,255,255)
startBtn.BackgroundColor3 = Color3.fromRGB(60,170,60)

local pauseBtn = Instance.new("TextButton", frame)
pauseBtn.Size = UDim2.new(0, 120, 0, 40)
pauseBtn.Position = UDim2.new(0, 165, 0, 130)
pauseBtn.Text = "⏸️ Pause"
pauseBtn.Font = Enum.Font.GothamBold
pauseBtn.TextSize = 18
pauseBtn.TextColor3 = Color3.fromRGB(255,255,255)
pauseBtn.BackgroundColor3 = Color3.fromRGB(180,170,60)

local stopBtn = Instance.new("TextButton", frame)
stopBtn.Size = UDim2.new(0, 120, 0, 40)
stopBtn.Position = UDim2.new(0, 320, 0, 130)
stopBtn.Text = "⏹️ Stop"
stopBtn.Font = Enum.Font.GothamBold
stopBtn.TextSize = 18
stopBtn.TextColor3 = Color3.fromRGB(255,255,255)
stopBtn.BackgroundColor3 = Color3.fromRGB(170,60,60)

-- Funciones de los botones
startBtn.MouseButton1Click:Connect(function()
    if playing then
        paused = false
        pauseBtn.Text = "⏸️ Pause"
        return
    end

    -- Leer y validar intervalo
    local val = tonumber(intervalInput.Text)
    if val and val > 0 then
        interval = val
    else
        interval = interval  -- mantiene el anterior si no es válido
    end

    -- Leer texto o URL
    local txt = input.Text
    if txt:match("^https?://") then
        local ok, res = pcall(HttpService.GetAsync, HttpService, txt)
        if not ok then
            warn("Error fetching URL:", res)
            return
        end
        songText = res:lower()
    else
        songText = txt:lower()
    end

    idx = 1
    task.spawn(playLoop)
end)

pauseBtn.MouseButton1Click:Connect(function()
    if playing then
        paused = not paused
        pauseBtn.Text = paused and "▶️ Resume" or "⏸️ Pause"
    end
end)

stopBtn.MouseButton1Click:Connect(function()
    playing = false
    paused  = false
    idx      = 1
    pauseBtn.Text = "⏸️ Pause"
end)
