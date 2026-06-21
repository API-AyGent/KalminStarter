
-- // Services \\ --

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- // Configuration & Theme \\ --
local Theme = {
    Background = Color3.fromRGB(15, 15, 15),
    Surface = Color3.fromRGB(22, 22, 22),
    Border = Color3.fromRGB(40, 40, 40),
    TextPrimary = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(160, 160, 160),
    
    Safe = {
        Main = Color3.fromRGB(25, 135, 84),
        Light = Color3.fromRGB(40, 167, 69),
        Dark = Color3.fromRGB(18, 93, 58)
    },
    Unsafe = {
        Main = Color3.fromRGB(220, 53, 69),
        Light = Color3.fromRGB(242, 92, 105),
        Dark = Color3.fromRGB(150, 30, 42)
    },
    
    FontBold = Enum.Font.GothamBold,
    FontMedium = Enum.Font.GothamMedium,
    FontHeader = Enum.Font.FredokaOne
}

local Connections = {}
local isExecuting = false

-- // Utilities \\ --
local function DisconnectAll()
    for _, connection in ipairs(Connections) do
        if typeof(connection) == "RBXScriptConnection" then
            connection:Disconnect()
        end
    end
    table.clear(Connections)
end

local function GetSecureParent()
    local success, parent = pcall(function()
        if gethui then return gethui() end
        if syn and syn.protect_gui then
            local gui = Instance.new("ScreenGui")
            syn.protect_gui(gui)
            gui.Parent = CoreGui
            return gui
        end
        return CoreGui
    end)
    return success and parent or Players.LocalPlayer:WaitForChild("PlayerGui")
end

-- Clear existing UI instances to prevent duplication
local TargetParent = GetSecureParent()
for _, child in ipairs(TargetParent:GetChildren()) do
    if child.Name == "KalminExecutionUI" then 
        child:Destroy() 
    end
end

-- // UI Framework Base \\ --
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KalminExecutionUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = TargetParent

-- // Main Canvas Frame \\ --
local MainFrame = Instance.new("CanvasGroup")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 580, 0, 320)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.GroupTransparency = 1
MainFrame.Parent = ScreenGui

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Theme.Border
MainStroke.Thickness = 1.5
MainStroke.Transparency = 1 -- Fix: Start fully transparent to prevent the initial flash
MainStroke.Parent = MainFrame

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

-- // Top Bar \\ --
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 45)
TopBar.BackgroundColor3 = Theme.Surface
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopBarDivider = Instance.new("Frame")
TopBarDivider.Size = UDim2.new(1, 0, 0, 1)
TopBarDivider.Position = UDim2.new(0, 0, 1, -1)
TopBarDivider.BackgroundColor3 = Theme.Border
TopBarDivider.BorderSizePixel = 0
TopBarDivider.Parent = TopBar

local TopBarCorner = Instance.new("UICorner")
TopBarCorner.CornerRadius = UDim.new(0, 12)
TopBarCorner.Parent = TopBar

-- Fix bottom corners of TopBar overlapping with CanvasGroup content
local TopBarFix = Instance.new("Frame")
TopBarFix.Size = UDim2.new(1, 0, 0, 10)
TopBarFix.Position = UDim2.new(0, 0, 1, -10)
TopBarFix.BackgroundColor3 = Theme.Surface
TopBarFix.BorderSizePixel = 0
TopBarFix.ZIndex = 0
TopBarFix.Parent = TopBar

local Icon = Instance.new("ImageLabel")
Icon.Size = UDim2.new(0, 24, 0, 24)
Icon.Position = UDim2.new(0, 16, 0.5, 0)
Icon.AnchorPoint = Vector2.new(0, 0.5)
Icon.BackgroundTransparency = 1
Icon.Image = "rbxassetid://126925031200401"
Icon.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -100, 1, 0)
Title.Position = UDim2.new(0, 48, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Kalmin Premium"
Title.TextColor3 = Theme.TextPrimary
Title.Font = Theme.FontBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 28, 0, 28)
CloseButton.Position = UDim2.new(1, -16, 0.5, 0)
CloseButton.AnchorPoint = Vector2.new(1, 0.5)
CloseButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
CloseButton.Text = "×"
CloseButton.TextColor3 = Theme.TextSecondary
CloseButton.Font = Theme.FontBold
CloseButton.TextSize = 20
CloseButton.AutoButtonColor = false
CloseButton.Parent = TopBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseButton

-- // Header Text \\ --
local HeaderText = Instance.new("TextLabel")
HeaderText.Size = UDim2.new(1, 0, 0, 40)
HeaderText.Position = UDim2.new(0, 0, 0, 65)
HeaderText.BackgroundTransparency = 1
HeaderText.Text = "Select One Execution Script"
HeaderText.TextColor3 = Theme.TextPrimary
HeaderText.Font = Theme.FontHeader
HeaderText.TextSize = 24
HeaderText.Parent = MainFrame

-- // Action Area (Buttons) \\ --
local ButtonsFrame = Instance.new("Frame")
ButtonsFrame.Size = UDim2.new(1, -48, 0, 50) 
ButtonsFrame.Position = UDim2.new(0.5, 0, 0, 115)
ButtonsFrame.AnchorPoint = Vector2.new(0.5, 0)
ButtonsFrame.BackgroundTransparency = 1
ButtonsFrame.Parent = MainFrame

local function CreateModeButton(name, text, colorTheme, position, anchor)
    local Button = Instance.new("TextButton")
    Button.Name = name
    Button.Size = UDim2.new(0, 230, 1, 0)
    Button.Position = position
    Button.AnchorPoint = anchor
    Button.BackgroundColor3 = colorTheme.Dark
    Button.Text = text
    Button.TextColor3 = colorTheme.Light
    Button.Font = Theme.FontHeader
    Button.TextSize = 18
    Button.AutoButtonColor = false
    Button.Parent = ButtonsFrame

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = colorTheme.Main
    Stroke.Thickness = 1.5
    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    Stroke.Parent = Button

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Button
    
    return Button, Stroke
end

local SafeButton, SafeStroke = CreateModeButton("SafeButton", "Run Safe Script", Theme.Safe, UDim2.new(0, 0, 0.5, 0), Vector2.new(0, 0.5))
local UnsafeButton, UnsafeStroke = CreateModeButton("UnsafeButton", "Run Unsafe Script", Theme.Unsafe, UDim2.new(1, 0, 0.5, 0), Vector2.new(1, 0.5))

local OrText = Instance.new("TextLabel")
OrText.Size = UDim2.new(0, 40, 1, 0)
OrText.Position = UDim2.new(0.5, 0, 0.5, 0)
OrText.AnchorPoint = Vector2.new(0.5, 0.5)
OrText.BackgroundTransparency = 1
OrText.Text = "OR"
OrText.TextColor3 = Theme.TextSecondary
OrText.Font = Theme.FontBold
OrText.TextSize = 14
OrText.Parent = ButtonsFrame

-- // Contextual Descriptions \\ --
local ContentLayout = Instance.new("Frame")
ContentLayout.Size = UDim2.new(1, -48, 0, 110)
ContentLayout.Position = UDim2.new(0.5, 0, 1, -16)
ContentLayout.AnchorPoint = Vector2.new(0.5, 1)
ContentLayout.BackgroundTransparency = 1
ContentLayout.Parent = MainFrame

local InfoSide = Instance.new("Frame")
InfoSide.Size = UDim2.new(0.5, -15, 1, 0)
InfoSide.BackgroundTransparency = 1
InfoSide.Parent = ContentLayout

local SafeDesc = Instance.new("TextLabel")
SafeDesc.Size = UDim2.new(1, 0, 0, 45)
SafeDesc.BackgroundTransparency = 1
SafeDesc.Text = "🛡️ Safe Script:\nSafe Script Will Kick You If You Try To Run The Script On Blaklisted Game's."
SafeDesc.TextColor3 = Theme.Safe.Light
SafeDesc.Font = Theme.FontMedium
SafeDesc.TextSize = 11
SafeDesc.TextXAlignment = Enum.TextXAlignment.Left
SafeDesc.TextYAlignment = Enum.TextYAlignment.Top
SafeDesc.TextWrapped = true
SafeDesc.Parent = InfoSide

local UnsafeDesc = Instance.new("TextLabel")
UnsafeDesc.Size = UDim2.new(1, 0, 0, 45)
UnsafeDesc.Position = UDim2.new(0, 0, 0, 55)
UnsafeDesc.BackgroundTransparency = 1
UnsafeDesc.Text = "⚠️ Unsafe Script:\nUnsafe Script Will Allow You To Run The Script On Blaklisted Game's."
UnsafeDesc.TextColor3 = Theme.Unsafe.Light
UnsafeDesc.Font = Theme.FontMedium
UnsafeDesc.TextSize = 11
UnsafeDesc.TextXAlignment = Enum.TextXAlignment.Left
UnsafeDesc.TextYAlignment = Enum.TextYAlignment.Top
UnsafeDesc.TextWrapped = true
UnsafeDesc.Parent = InfoSide

local Divider = Instance.new("Frame")
Divider.Size = UDim2.new(0, 1, 1, 0)
Divider.Position = UDim2.new(0.5, 0, 0, 0)
Divider.AnchorPoint = Vector2.new(0.5, 0)
Divider.BackgroundColor3 = Theme.Border
Divider.BorderSizePixel = 0
Divider.Parent = ContentLayout

local BlacklistDesc = Instance.new("TextLabel")
BlacklistDesc.Size = UDim2.new(0.5, -15, 1, 0)
BlacklistDesc.Position = UDim2.new(0.5, 15, 0, 0)
BlacklistDesc.BackgroundTransparency = 1
BlacklistDesc.Text = "💡 BlackListed Game's\n\nThis Are Game's That Have Strong Anti-Cheat That Executing This Script May Lead Your Account Getting Banned From That Game! Eg Rivals"
BlacklistDesc.TextColor3 = Theme.TextSecondary
BlacklistDesc.Font = Theme.FontMedium
BlacklistDesc.TextSize = 11
BlacklistDesc.TextXAlignment = Enum.TextXAlignment.Left
BlacklistDesc.TextYAlignment = Enum.TextYAlignment.Top
BlacklistDesc.TextWrapped = true
BlacklistDesc.Parent = ContentLayout

-- // Toast Notification Subsystem \\ --
local NotifFrame = Instance.new("Frame")
NotifFrame.Name = "Notification"
NotifFrame.Size = UDim2.new(0, 260, 0, 45)
NotifFrame.Position = UDim2.new(1, 50, 0, 24) 
NotifFrame.AnchorPoint = Vector2.new(1, 0)
NotifFrame.BackgroundColor3 = Theme.Surface
NotifFrame.Parent = ScreenGui

local NotifCorner = Instance.new("UICorner")
NotifCorner.CornerRadius = UDim.new(0, 8)
NotifCorner.Parent = NotifFrame

local NotifStroke = Instance.new("UIStroke")
NotifStroke.Color = Theme.Border
NotifStroke.Thickness = 1.5
NotifStroke.Parent = NotifFrame

local NotifText = Instance.new("TextLabel")
NotifText.Size = UDim2.new(1, -24, 1, 0)
NotifText.Position = UDim2.new(0, 12, 0, 0)
NotifText.BackgroundTransparency = 1
NotifText.Text = "Waiting For Choice..."
NotifText.TextColor3 = Theme.TextPrimary
NotifText.Font = Theme.FontMedium
NotifText.TextSize = 13
NotifText.TextXAlignment = Enum.TextXAlignment.Left
NotifText.Parent = NotifFrame

-- // Tween Parameters \\ --
local TInfoFast = TweenInfo.new(0.12, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
local TInfoSmooth = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function Transition(object, info, properties)
    local tween = TweenService:Create(object, info, properties)
    tween:Play()
    return tween
end

-- // Logic Controllers \\ --
local function TriggerNotification(accentColor, message)
    NotifStroke.Color = accentColor
    NotifText.Text = message
    
    -- Slide In
    Transition(NotifFrame, TInfoSmooth, {Position = UDim2.new(1, -24, 0, 24)})
    -- Fade Out Panel and Manually Fade Stroke Fix
    Transition(MainFrame, TInfoSmooth, {GroupTransparency = 1, Size = UDim2.new(0, 550, 0, 300)})
    Transition(MainStroke, TInfoSmooth, {Transparency = 1})
    
    task.delay(2.5, function()
        local hide = Transition(NotifFrame, TInfoSmooth, {Position = UDim2.new(1, 300, 0, 24)})
        hide.Completed:Wait()
        DisconnectAll()
        ScreenGui:Destroy()
    end)
end

local function ExecuteScript(isSafe)
    if isExecuting then return end
    isExecuting = true
    
    if isSafe then
        TriggerNotification(Theme.Safe.Light, "Executing Safe Script (Please Wait)...")
        task.spawn(pcall, function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/FuddyOG/MainOptimumRealScript/refs/heads/main/MainOptumumRealScript.lua"))()
        end)
    else
        TriggerNotification(Theme.Unsafe.Light, "Executing Unsafe Script (Please Wait)...")
        task.spawn(pcall, function()
            -- Placeholder configuration for Unsafe script endpoint
            -- loadstring(game:HttpGet("UNSAFE_ENDPOINT_HERE"))()
        end)
    end
end

-- // Micro-Interactions & Events \\ --
local function ConnectHover(button, targetColor, originalColor, stroke, strokeColor, originalStrokeColor)
    table.insert(Connections, button.MouseEnter:Connect(function()
        Transition(button, TInfoFast, {BackgroundColor3 = targetColor})
        if stroke then Transition(stroke, TInfoFast, {Color = strokeColor}) end
    end))
    table.insert(Connections, button.MouseLeave:Connect(function()
        Transition(button, TInfoFast, {BackgroundColor3 = originalColor})
        if stroke then Transition(stroke, TInfoFast, {Color = originalStrokeColor}) end
    end))
end

ConnectHover(SafeButton, Theme.Safe.Main, Theme.Safe.Dark, SafeStroke, Theme.TextPrimary, Theme.Safe.Main)
ConnectHover(UnsafeButton, Theme.Unsafe.Main, Theme.Unsafe.Dark, UnsafeStroke, Theme.TextPrimary, Theme.Unsafe.Main)
ConnectHover(CloseButton, Color3.fromRGB(180, 40, 50), Color3.fromRGB(30, 30, 30))

table.insert(Connections, SafeButton.MouseButton1Click:Connect(function() ExecuteScript(true) end))
table.insert(Connections, UnsafeButton.MouseButton1Click:Connect(function() ExecuteScript(false) end))

table.insert(Connections, CloseButton.MouseButton1Click:Connect(function()
    if isExecuting then return end
    isExecuting = true
    
    -- Fix: Fade stroke along with group transparency
    Transition(MainStroke, TInfoSmooth, {Transparency = 1})
    local dismiss = Transition(MainFrame, TInfoSmooth, {GroupTransparency = 1, Size = UDim2.new(0, 550, 0, 300)})
    
    dismiss.Completed:Wait()
    DisconnectAll()
    ScreenGui:Destroy()
end))

-- // High-Performance Lerped Dragging Subsystem \\ --
local Dragging, DragInput, DragStart, StartPos

table.insert(Connections, TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        Dragging = true
        DragStart = input.Position
        StartPos = MainFrame.Position
    end
end))

table.insert(Connections, UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        DragInput = input
    end
end))

table.insert(Connections, UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        Dragging = false
    end
end))

table.insert(Connections, RunService.RenderStepped:Connect(function()
    if Dragging and DragInput then
        local Delta = DragInput.Position - DragStart
        local TargetPosition = UDim2.new(
            StartPos.X.Scale, StartPos.X.Offset + Delta.X,
            StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y
        )
        MainFrame.Position = MainFrame.Position:Lerp(TargetPosition, 0.25)
    end
end))

-- // Initial Boot Sequence \\ --
MainFrame.Size = UDim2.new(0, 550, 0, 300)
Transition(MainFrame, TInfoSmooth, {GroupTransparency = 0, Size = UDim2.new(0, 580, 0, 320)})
Transition(MainStroke, TInfoSmooth, {Transparency = 0}) -- Fix: Fade in stroke 
