local Library = {
    AccentColor = Color3.fromRGB(130, 0, 2),
    AccentObjects = {},
    Windows = {},
    BlockWindowDrag = false,
    ActiveColorPicker = nil,
    ActiveDropdown = nil,
    ToggleKeybind = Enum.KeyCode.RightShift
}
Library.__index = Library

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local FONTS = {
    Montserrat = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
    BuilderIcons = Font.new("rbxasset://LuaPackages/Packages/_Index/BuilderIcons/BuilderIcons/BuilderIcons.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
}

local COLORS = {
    WindowBG = Color3.fromRGB(12, 12, 12),
    ElementBG = Color3.fromRGB(20, 20, 20),
    BorderGray = Color3.fromRGB(45, 45, 45),
    TextGray = Color3.fromRGB(195, 195, 195),
    TextWhite = Color3.fromRGB(255, 255, 255)
}

local function RandomString(len)
    len = len or math.random(10, 16)
    local charSet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local result = ""
    for _ = 1, len do
        local randIndex = math.random(1, #charSet)
        result = result .. string.sub(charSet, randIndex, randIndex)
    end
    return result
end

local function CloseAllPopups()
    if Library.ActiveColorPicker then
        Library.ActiveColorPicker.Visible = false
        Library.ActiveColorPicker = nil
    end
    if Library.ActiveDropdown then
        Library.ActiveDropdown.Visible = false
        Library.ActiveDropdown = nil
    end
end

local function RegisterAccent(instance, property)
    table.insert(Library.AccentObjects, {Instance = instance, Property = property})
    instance[property] = Library.AccentColor
end

function Library:SetAccentColor(newColor)
    Library.AccentColor = newColor
    for i = #Library.AccentObjects, 1, -1 do
        local entry = Library.AccentObjects[i]
        if entry.Instance and entry.Instance.Parent then
            entry.Instance[entry.Property] = newColor
        else
            table.remove(Library.AccentObjects, i)
        end
    end
    for _, win in ipairs(Library.Windows) do
        if win.UpdateSectionColors then
            win:UpdateSectionColors()
        end
    end
end

local function MakeDraggable(guiObj, dragHandle)
    dragHandle = dragHandle or guiObj
    local dragging = false
    local dragStart, startPos

    dragHandle.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and not Library.BlockWindowDrag and not Library.ActiveColorPicker then
            dragging = true
            dragStart = input.Position
            startPos = guiObj.Position
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            local targetPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            TweenService:Create(guiObj, TweenInfo.new(0.08, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = targetPos}):Play()
            
            CloseAllPopups()
        end
    end)
end

local function AddShadow(parent)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = RandomString()
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.Position = UDim2.new(0.5, 0, 0.5, 2)
    shadow.Size = UDim2.new(1, 28, 1, 28)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://1316045217"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.55
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.ZIndex = math.max(0, parent.ZIndex - 1)
    shadow.Parent = parent
    return shadow
end

function Library:CreateWindow(titleText)

    local window = {
        Sections = {},
        ActiveSection = nil,
        WindowFrame = nil,
        ScreenGui = nil,
        Overlay = nil
    }

    table.insert(Library.Windows, window)

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = RandomString()
    ScreenGui.DisplayOrder = 2147483647
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    ScreenGui.Parent = CoreGui or Players.LocalPlayer:WaitForChild("PlayerGui")
    window.ScreenGui = ScreenGui

    local Overlay = Instance.new("Frame")
    Overlay.Name = RandomString()
    Overlay.Size = UDim2.fromScale(1, 1)
    Overlay.Position = UDim2.fromScale(0, 0)
    Overlay.BackgroundTransparency = 1
    Overlay.BorderSizePixel = 0
    Overlay.ClipsDescendants = false
    Overlay.ZIndex = 10000
    Overlay.Parent = ScreenGui
    window.Overlay = Overlay

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Library.ToggleKeybind then
            ScreenGui.Enabled = not ScreenGui.Enabled

            if not ScreenGui.Enabled then
                CloseAllPopups()
            end
        end
    end)

    local WindowFrame = Instance.new("ImageButton")
    WindowFrame.Name = RandomString()
    WindowFrame.Size = UDim2.new(0, 500, 0, 626)
    WindowFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    WindowFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    WindowFrame.BackgroundColor3 = COLORS.WindowBG
    WindowFrame.BackgroundTransparency = 0
    WindowFrame.ImageTransparency = 0
    WindowFrame.AutoButtonColor = false
    WindowFrame.Active = true
    WindowFrame.Selectable = false

    WindowFrame.Image = "rbxassetid://85165299423433"
    WindowFrame:SetAttribute("AssetId", "123714237161450")
    WindowFrame:SetAttribute("TextureId", "85165299423433")
    WindowFrame.ImageColor3 = Library.AccentColor
    WindowFrame.ImageTransparency = 0.95
    WindowFrame.ScaleType = Enum.ScaleType.Stretch
    WindowFrame.ResampleMode = Enum.ResamplerMode.Default

    WindowFrame.ClipsDescendants = true
    WindowFrame.Parent = ScreenGui
    window.WindowFrame = WindowFrame

    task.defer(function()
        pcall(function()
            game:GetService("ContentProvider"):PreloadAsync({WindowFrame})
        end)
    end)

    RegisterAccent(WindowFrame, "ImageColor3")

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 4)
    UICorner.Parent = WindowFrame

    local UIStroke = Instance.new("UIStroke")
    UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    UIStroke.Color = COLORS.BorderGray
    UIStroke.Parent = WindowFrame

    AddShadow(WindowFrame)
    MakeDraggable(WindowFrame)

    function window:SetSize(width, height)
        WindowFrame.Size = UDim2.new(0, width, 0, height)
    end

    local WindowTitle = Instance.new("TextLabel")
    WindowTitle.Name = RandomString()
    WindowTitle.Size = UDim2.new(1, 0, 0, 24)
    WindowTitle.BackgroundTransparency = 1
    WindowTitle.FontFace = FONTS.Montserrat
    WindowTitle.RichText = true
    WindowTitle.Text = titleText or "Moonlight Copy | discord @ da.cli3nt"
    WindowTitle.TextSize = 14
    WindowTitle.TextXAlignment = Enum.TextXAlignment.Left
    WindowTitle.Parent = WindowFrame
    RegisterAccent(WindowTitle, "TextColor3")

    local TitlePadding = Instance.new("UIPadding")
    TitlePadding.PaddingLeft = UDim.new(0, 8)
    TitlePadding.Parent = WindowTitle

    local SectionsContainer = Instance.new("Frame")
    SectionsContainer.Name = RandomString()
    SectionsContainer.Size = UDim2.new(1, -14, 0, 24)
    SectionsContainer.Position = UDim2.new(0, 7, 0, 28)
    SectionsContainer.BackgroundTransparency = 1
    SectionsContainer.ClipsDescendants = false
    SectionsContainer.Parent = WindowFrame

    local SecCorner = Instance.new("UICorner")
    SecCorner.CornerRadius = UDim.new(0, 4)
    SecCorner.Parent = SectionsContainer

    local SecStroke = Instance.new("UIStroke")
    SecStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    SecStroke.Color = COLORS.BorderGray
    SecStroke.Parent = SectionsContainer

    local SecPadding = Instance.new("UIPadding")
    SecPadding.PaddingLeft = UDim.new(0, 8)
    SecPadding.Parent = SectionsContainer

    local SecLayout = Instance.new("UIListLayout")
    SecLayout.FillDirection = Enum.FillDirection.Horizontal
    SecLayout.Padding = UDim.new(0, 5)
    SecLayout.SortOrder = Enum.SortOrder.LayoutOrder
    SecLayout.Parent = SectionsContainer

    function window:UpdateSectionColors()
        for _, sec in ipairs(window.Sections) do
            if window.ActiveSection == sec then
                sec.Button.TextColor3 = Library.AccentColor
            else
                sec.Button.TextColor3 = COLORS.TextGray
            end
        end
    end

    function window:CreateSection(sectionName)
        local sectionObj = {
            Frame = nil,
            Button = nil
        }

        local SectionBtn = Instance.new("TextButton")
        SectionBtn.Name = RandomString()
        SectionBtn.Size = UDim2.new(0, 65, 0, 24)
        SectionBtn.BackgroundTransparency = 1
        SectionBtn.FontFace = FONTS.Montserrat
        SectionBtn.Text = sectionName
        SectionBtn.TextColor3 = COLORS.TextGray
        SectionBtn.TextSize = 14
        SectionBtn.AutoButtonColor = false
        SectionBtn.Parent = SectionsContainer
        sectionObj.Button = SectionBtn

        local MainFrame = Instance.new("ScrollingFrame")
        MainFrame.Name = RandomString()
        MainFrame.Size = UDim2.new(1, -14, 1, -60)
        MainFrame.Position = UDim2.new(0, 7, 0, 56)
        MainFrame.AnchorPoint = Vector2.new(0, 0)
        MainFrame.BackgroundTransparency = 1
        MainFrame.BorderSizePixel = 0
        MainFrame.ScrollBarThickness = 4
        MainFrame.ScrollBarImageTransparency = 0.35
        MainFrame.ScrollingDirection = Enum.ScrollingDirection.Y
        MainFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
        MainFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        MainFrame.ClipsDescendants = true
        MainFrame.Visible = false
        MainFrame.Parent = WindowFrame
        sectionObj.Frame = MainFrame

        local MainFrame2 = Instance.new("Frame")
        MainFrame2.Name = RandomString()
        MainFrame2.Size = UDim2.new(1, -4, 0, 0)
        MainFrame2.Position = UDim2.new(0, 2, 0, 1)
        MainFrame2.BackgroundTransparency = 1
        MainFrame2.AutomaticSize = Enum.AutomaticSize.Y
        MainFrame2.ClipsDescendants = false
        MainFrame2.Parent = MainFrame

        local GridList = Instance.new("UIListLayout")
        GridList.Padding = UDim.new(0, 5)
        GridList.SortOrder = Enum.SortOrder.LayoutOrder
        GridList.Wraps = true
        GridList.FillDirection = Enum.FillDirection.Horizontal
        GridList.Parent = MainFrame2

        local function SelectSection()
            CloseAllPopups()
            window.ActiveSection = sectionObj
            for _, sec in ipairs(window.Sections) do
                sec.Frame.Visible = (sec == sectionObj)
            end

            task.defer(function()
                if sectionObj.Frame.Parent then
                    sectionObj.Frame.CanvasPosition = Vector2.zero
                    local content = sectionObj.Frame:FindFirstChildOfClass("Frame")
                    if content then
                        sectionObj.Frame.CanvasSize = UDim2.fromOffset(0, content.AbsoluteSize.Y + 4)
                    end
                end
            end)

            window:UpdateSectionColors()
        end

        SectionBtn.MouseButton1Click:Connect(SelectSection)

        table.insert(window.Sections, sectionObj)
        if #window.Sections == 1 then
            SelectSection()
        end

        function sectionObj:CreateTab(tabName)
            local tab = {}

            local TabCard = Instance.new("Frame")
            TabCard.Name = RandomString()
            TabCard.Size = UDim2.new(0.49, 0, 0, 0)
            TabCard.AutomaticSize = Enum.AutomaticSize.Y
            TabCard.BackgroundColor3 = COLORS.WindowBG
            TabCard.BackgroundTransparency = 0.2
            TabCard.ClipsDescendants = false
            TabCard.Parent = MainFrame2

            local CardCorner = Instance.new("UICorner")
            CardCorner.CornerRadius = UDim.new(0, 4)
            CardCorner.Parent = TabCard

            local CardStroke = Instance.new("UIStroke")
            CardStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            CardStroke.Color = COLORS.BorderGray
            CardStroke.Parent = TabCard

            local CardPadding = Instance.new("UIPadding")
            CardPadding.PaddingLeft = UDim.new(0, 8)
            CardPadding.PaddingTop = UDim.new(0, 4)
            CardPadding.PaddingBottom = UDim.new(0, 8)
            CardPadding.PaddingRight = UDim.new(0, 8)
            CardPadding.Parent = TabCard

            local CardList = Instance.new("UIListLayout")
            CardList.Padding = UDim.new(0, 9)
            CardList.SortOrder = Enum.SortOrder.LayoutOrder
            CardList.Parent = TabCard

            local TitleLabel = Instance.new("TextLabel")
            TitleLabel.Name = RandomString()
            TitleLabel.Size = UDim2.new(1, 0, 0, 14)
            TitleLabel.BackgroundTransparency = 1
            TitleLabel.FontFace = FONTS.Montserrat
            TitleLabel.Text = tabName
            TitleLabel.TextColor3 = COLORS.TextWhite
            TitleLabel.TextSize = 14
            TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
            TitleLabel.Parent = TabCard

            function tab:AddToggle(name, default, callback)
                local toggled = default or false

                local ToggleFrame = Instance.new("Frame")
                ToggleFrame.Name = RandomString()
                ToggleFrame.Size = UDim2.new(1, 0, 0, 14)
                ToggleFrame.BackgroundTransparency = 1
                ToggleFrame.Parent = TabCard

                local Checkbox = Instance.new("TextButton")
                Checkbox.Name = RandomString()
                Checkbox.Size = UDim2.new(0, 14, 0, 14)
                Checkbox.BackgroundColor3 = COLORS.ElementBG
                Checkbox.FontFace = FONTS.BuilderIcons
                Checkbox.Text = "check-large"
                Checkbox.TextSize = 12
                Checkbox.TextTransparency = toggled and 0 or 1
                Checkbox.AutoButtonColor = false
                Checkbox.Parent = ToggleFrame

                local BoxCorner = Instance.new("UICorner")
                BoxCorner.CornerRadius = UDim.new(0, 1)
                BoxCorner.Parent = Checkbox

                local BoxStroke = Instance.new("UIStroke")
                BoxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                BoxStroke.Color = COLORS.BorderGray
                BoxStroke.Parent = Checkbox

                RegisterAccent(Checkbox, "TextColor3")

                local ToggleLabel = Instance.new("TextLabel")
                ToggleLabel.Name = RandomString()
                ToggleLabel.Size = UDim2.new(1, -14, 0, 14)
                ToggleLabel.Position = UDim2.new(1, 0, 0, 0)
                ToggleLabel.AnchorPoint = Vector2.new(1, 0)
                ToggleLabel.BackgroundTransparency = 1
                ToggleLabel.FontFace = FONTS.Montserrat
                ToggleLabel.Text = name
                ToggleLabel.TextColor3 = COLORS.TextGray
                ToggleLabel.TextSize = 14
                ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
                ToggleLabel.Parent = ToggleFrame

                local LabelPadding = Instance.new("UIPadding")
                LabelPadding.PaddingLeft = UDim.new(0, 8)
                LabelPadding.Parent = ToggleLabel

                Checkbox.MouseButton1Click:Connect(function()
                    toggled = not toggled
                    Checkbox.TextTransparency = toggled and 0 or 1
                    if callback then callback(toggled) end
                end)

                return ToggleFrame
            end

            function tab:AddSlider(name, min, max, default, callback)
                local value = math.clamp(default or min, min, max)

                local SliderFrame = Instance.new("Frame")
                SliderFrame.Name = RandomString()
                SliderFrame.Size = UDim2.new(1, 0, 0, 36)
                SliderFrame.BackgroundTransparency = 1
                SliderFrame.Parent = TabCard

                local SliderLabel = Instance.new("TextLabel")
                SliderLabel.Name = RandomString()
                SliderLabel.Size = UDim2.new(1, 0, 0, 14)
                SliderLabel.BackgroundTransparency = 1
                SliderLabel.FontFace = FONTS.Montserrat
                SliderLabel.Text = name
                SliderLabel.TextColor3 = COLORS.TextGray
                SliderLabel.TextSize = 14
                SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
                SliderLabel.Parent = SliderFrame

                local SliderValue = Instance.new("TextBox")
                SliderValue.Name = RandomString()
                SliderValue.Size = UDim2.new(1, 0, 0, 14)
                SliderValue.Position = UDim2.new(1, 0, 0, 0)
                SliderValue.AnchorPoint = Vector2.new(1, 0)
                SliderValue.BackgroundTransparency = 1
                SliderValue.FontFace = FONTS.Montserrat
                SliderValue.Text = tostring(value)
                SliderValue.TextColor3 = COLORS.TextWhite
                SliderValue.TextSize = 14
                SliderValue.TextXAlignment = Enum.TextXAlignment.Right
                SliderValue.Parent = SliderFrame

                local ValPadding = Instance.new("UIPadding")
                ValPadding.PaddingRight = UDim.new(0, 4)
                ValPadding.Parent = SliderValue

                local SliderMain = Instance.new("TextButton")
                SliderMain.Name = RandomString()
                SliderMain.Size = UDim2.new(1, -4, 0, 18)
                SliderMain.Position = UDim2.new(0, 0, 1, 0)
                SliderMain.AnchorPoint = Vector2.new(0, 1)
                SliderMain.BackgroundColor3 = COLORS.ElementBG
                SliderMain.Text = ""
                SliderMain.AutoButtonColor = false
                SliderMain.Parent = SliderFrame

                local TrackCorner = Instance.new("UICorner")
                TrackCorner.CornerRadius = UDim.new(0, 4)
                TrackCorner.Parent = SliderMain

                local TrackStroke = Instance.new("UIStroke")
                TrackStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                TrackStroke.Color = COLORS.BorderGray
                TrackStroke.Parent = SliderMain

                local FillFrame = Instance.new("Frame")
                FillFrame.Name = RandomString()
                FillFrame.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
                FillFrame.Parent = SliderMain

                local FillCorner = Instance.new("UICorner")
                FillCorner.CornerRadius = UDim.new(0, 4)
                FillCorner.Parent = FillFrame

                RegisterAccent(FillFrame, "BackgroundColor3")

                local dragging = false
                local function UpdateSlider(input)
                    local pos = math.clamp((input.Position.X - SliderMain.AbsolutePosition.X) / SliderMain.AbsoluteSize.X, 0, 1)
                    value = math.floor(min + ((max - min) * pos))
                    FillFrame.Size = UDim2.new(pos, 0, 1, 0)
                    SliderValue.Text = tostring(value)
                    if callback then callback(value) end
                end

                SliderMain.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        if Library.ActiveColorPicker or Library.ActiveDropdown then return end
                        dragging = true
                        Library.BlockWindowDrag = true
                        UpdateSlider(input)
                    end
                end)

                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                        Library.BlockWindowDrag = false
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        UpdateSlider(input)
                    end
                end)

                return SliderFrame
            end

            function tab:AddDropdown(name, options, default, callback)
                options = options or {}

                local selected = default
                if selected == nil or not table.find(options, selected) then
                    selected = options[1] or ""
                end

                local DropDown = Instance.new("Frame")
                DropDown.Name = RandomString()
                DropDown.Size = UDim2.new(1, 0, 0, 36)
                DropDown.BackgroundTransparency = 1
                DropDown.ClipsDescendants = false
                DropDown.Parent = TabCard

                local DropdownLabel = Instance.new("TextLabel")
                DropdownLabel.Name = RandomString()
                DropdownLabel.Size = UDim2.new(1, 0, 0, 14)
                DropdownLabel.BackgroundTransparency = 1
                DropdownLabel.FontFace = FONTS.Montserrat
                DropdownLabel.Text = tostring(name)
                DropdownLabel.TextColor3 = COLORS.TextGray
                DropdownLabel.TextSize = 14
                DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
                DropdownLabel.Parent = DropDown

                local DropdownMain = Instance.new("TextButton")
                DropdownMain.Name = RandomString()
                DropdownMain.Size = UDim2.new(1, -4, 0, 18)
                DropdownMain.Position = UDim2.new(0, 0, 1, 0)
                DropdownMain.AnchorPoint = Vector2.new(0, 1)
                DropdownMain.BackgroundColor3 = COLORS.ElementBG
                DropdownMain.FontFace = FONTS.Montserrat
                DropdownMain.Text = "  " .. tostring(selected)
                DropdownMain.TextColor3 = COLORS.TextWhite
                DropdownMain.TextSize = 13
                DropdownMain.TextXAlignment = Enum.TextXAlignment.Left
                DropdownMain.AutoButtonColor = false
                DropdownMain.ZIndex = 100
                DropdownMain.Parent = DropDown

                local DropCorner = Instance.new("UICorner")
                DropCorner.CornerRadius = UDim.new(0, 2)
                DropCorner.Parent = DropdownMain

                local DropStroke = Instance.new("UIStroke")
                DropStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                DropStroke.Color = COLORS.BorderGray
                DropStroke.Parent = DropdownMain

                local Arrow = Instance.new("TextLabel")
                Arrow.Name = RandomString()
                Arrow.Size = UDim2.new(1, -6, 1, 0)
                Arrow.BackgroundTransparency = 1
                Arrow.FontFace = FONTS.Montserrat
                Arrow.Text = "▼"
                Arrow.TextColor3 = COLORS.TextWhite
                Arrow.TextSize = 10
                Arrow.TextXAlignment = Enum.TextXAlignment.Right
                Arrow.ZIndex = 101
                Arrow.Parent = DropdownMain

                local OptionContainer = Instance.new("ScrollingFrame")
                OptionContainer.Name = RandomString()
                OptionContainer.BackgroundColor3 = COLORS.ElementBG
                OptionContainer.BackgroundTransparency = 0
                OptionContainer.BorderSizePixel = 0
                OptionContainer.ScrollBarThickness = 3
                OptionContainer.ScrollBarImageColor3 = COLORS.BorderGray
                OptionContainer.ScrollingDirection = Enum.ScrollingDirection.Y
                OptionContainer.CanvasPosition = Vector2.zero
                OptionContainer.CanvasSize = UDim2.fromOffset(0, 0)
                OptionContainer.AutomaticCanvasSize = Enum.AutomaticSize.None
                OptionContainer.Visible = false
                OptionContainer.Active = true
                OptionContainer.ClipsDescendants = true
                OptionContainer.ZIndex = 20000
                OptionContainer.Parent = window.Overlay

                local ContainerCorner = Instance.new("UICorner")
                ContainerCorner.CornerRadius = UDim.new(0, 2)
                ContainerCorner.Parent = OptionContainer

                local ContainerStroke = Instance.new("UIStroke")
                ContainerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                ContainerStroke.Color = COLORS.BorderGray
                ContainerStroke.Parent = OptionContainer

                local OptionList = Instance.new("UIListLayout")
                OptionList.SortOrder = Enum.SortOrder.LayoutOrder
                OptionList.Padding = UDim.new(0, 0)
                OptionList.Parent = OptionContainer

                local function PositionDropdown()
                    if not DropdownMain.Parent or not OptionContainer.Parent then
                        return
                    end

                    local buttonPos = DropdownMain.AbsolutePosition
                    local buttonSize = DropdownMain.AbsoluteSize
                    local overlayPos = window.Overlay.AbsolutePosition
                    local overlaySize = window.Overlay.AbsoluteSize

                    local width = buttonSize.X
                    local optionHeight = math.min(#options * 22, 110)

                    local x = buttonPos.X - overlayPos.X
                    local y = buttonPos.Y - overlayPos.Y + buttonSize.Y + 3

                    if y + optionHeight > overlaySize.Y then
                        y = buttonPos.Y - overlayPos.Y - optionHeight - 3
                    end

                    if x + width > overlaySize.X then
                        x = overlaySize.X - width - 2
                    end

                    if x < 2 then
                        x = 2
                    end

                    if y < 2 then
                        y = 2
                    end

                    OptionContainer.Position = UDim2.fromOffset(x, y)
                    OptionContainer.Size = UDim2.fromOffset(width, optionHeight)
                end

                local function UpdateCanvas()
                    local contentHeight = OptionList.AbsoluteContentSize.Y

                    OptionContainer.CanvasSize = UDim2.fromOffset(
                        0,
                        contentHeight
                    )
                end

                local function ClearOptions()
                    for _, child in ipairs(OptionContainer:GetChildren()) do
                        if child:IsA("TextButton") then
                            child:Destroy()
                        end
                    end
                end

                local function PopulateOptions()
                    ClearOptions()

                    for index, option in ipairs(options) do
                        local value = option

                        local OptionBtn = Instance.new("TextButton")
                        OptionBtn.Name = RandomString()
                        OptionBtn.Size = UDim2.new(1, -3, 0, 22)
                        OptionBtn.BackgroundColor3 = COLORS.ElementBG
                        OptionBtn.BackgroundTransparency = 1
                        OptionBtn.BorderSizePixel = 0
                        OptionBtn.FontFace = FONTS.Montserrat
                        OptionBtn.Text = "  " .. tostring(value)
                        OptionBtn.TextColor3 = COLORS.TextGray
                        OptionBtn.TextSize = 13
                        OptionBtn.TextXAlignment = Enum.TextXAlignment.Left
                        OptionBtn.LayoutOrder = index
                        OptionBtn.AutoButtonColor = false
                        OptionBtn.ZIndex = 20001
                        OptionBtn.Parent = OptionContainer

                        OptionBtn.MouseEnter:Connect(function()
                            if OptionBtn.Parent then
                                OptionBtn.TextColor3 = COLORS.TextWhite
                            end
                        end)

                        OptionBtn.MouseLeave:Connect(function()
                            if OptionBtn.Parent then
                                OptionBtn.TextColor3 = COLORS.TextGray
                            end
                        end)

                        OptionBtn.MouseButton1Click:Connect(function()
                            selected = value
                            DropdownMain.Text = "  " .. tostring(selected)

                            OptionContainer.Visible = false

                            if Library.ActiveDropdown == OptionContainer then
                                Library.ActiveDropdown = nil
                            end

                            if callback then
                                callback(selected)
                            end
                        end)
                    end

                    task.defer(function()
                        if OptionContainer.Parent then
                            UpdateCanvas()
                        end
                    end)
                end

                OptionList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    UpdateCanvas()

                    if OptionContainer.Visible then
                        PositionDropdown()
                    end
                end)

                PopulateOptions()

                DropdownMain.MouseButton1Click:Connect(function()
                    local shouldOpen = not OptionContainer.Visible

                    CloseAllPopups()

                    if not shouldOpen then
                        return
                    end

                    OptionContainer.Visible = true
                    Library.ActiveDropdown = OptionContainer

                    PositionDropdown()
                    UpdateCanvas()

                    task.defer(function()
                        if OptionContainer.Visible then
                            PositionDropdown()
                            UpdateCanvas()
                        end
                    end)
                end)

                DropDown:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
                    if OptionContainer.Visible then
                        PositionDropdown()
                    end
                end)

                DropdownMain:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
                    if OptionContainer.Visible then
                        PositionDropdown()
                    end
                end)

                DropdownMain:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                    if OptionContainer.Visible then
                        PositionDropdown()
                    end
                end)

                window.Overlay:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                    if OptionContainer.Visible then
                        PositionDropdown()
                    end
                end)

                local DropdownObj = {}

                function DropdownObj:Set(value)
                    if not table.find(options, value) then
                        return
                    end

                    selected = value
                    DropdownMain.Text = "  " .. tostring(selected)

                    if callback then
                        callback(selected)
                    end
                end

                function DropdownObj:Get()
                    return selected
                end

                function DropdownObj:Refresh(newOptions, newDefault)
                    options = newOptions or {}

                    if newDefault ~= nil and table.find(options, newDefault) then
                        selected = newDefault
                    else
                        selected = options[1] or ""
                    end

                    DropdownMain.Text = "  " .. tostring(selected)

                    PopulateOptions()

                    if OptionContainer.Visible then
                        PositionDropdown()
                        UpdateCanvas()
                    end
                end

                function DropdownObj:Destroy()
                    if Library.ActiveDropdown == OptionContainer then
                        Library.ActiveDropdown = nil
                    end

                    if OptionContainer then
                        OptionContainer:Destroy()
                    end

                    if DropDown then
                        DropDown:Destroy()
                    end
                end

                return DropdownObj
            end

            function tab:AddColorPicker(name, defaultColor, callback)
                local currentColor = defaultColor or Color3.fromRGB(255, 0, 0)
                local h, s, v = Color3.toHSV(currentColor)

                local ColorPickerFrame = Instance.new("Frame")
                ColorPickerFrame.Name = RandomString()
                ColorPickerFrame.Size = UDim2.new(1, 0, 0, 14)
                ColorPickerFrame.BackgroundTransparency = 1
                ColorPickerFrame.Parent = TabCard

                local PickerLabel = Instance.new("TextLabel")
                PickerLabel.Name = RandomString()
                PickerLabel.Size = UDim2.new(1, -24, 0, 14)
                PickerLabel.BackgroundTransparency = 1
                PickerLabel.FontFace = FONTS.Montserrat
                PickerLabel.Text = name
                PickerLabel.TextColor3 = COLORS.TextGray
                PickerLabel.TextSize = 14
                PickerLabel.TextXAlignment = Enum.TextXAlignment.Left
                PickerLabel.Parent = ColorPickerFrame

                local ColorDisplay = Instance.new("TextButton")
                ColorDisplay.Name = RandomString()
                ColorDisplay.Size = UDim2.new(0, 20, 0, 14)
                ColorDisplay.Position = UDim2.new(1, 0, 0, 0)
                ColorDisplay.AnchorPoint = Vector2.new(1, 0)
                ColorDisplay.BackgroundColor3 = currentColor
                ColorDisplay.Text = ""
                ColorDisplay.AutoButtonColor = false
                ColorDisplay.Parent = ColorPickerFrame

                local DispCorner = Instance.new("UICorner")
                DispCorner.CornerRadius = UDim.new(0, 2)
                DispCorner.Parent = ColorDisplay

                local DispStroke = Instance.new("UIStroke")
                DispStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                DispStroke.Color = COLORS.BorderGray
                DispStroke.Parent = ColorDisplay

                local PaletteWindow = Instance.new("Frame")
                PaletteWindow.Name = RandomString()
                PaletteWindow.Size = UDim2.new(0, 180, 0, 134)
                PaletteWindow.BackgroundColor3 = COLORS.ElementBG
                PaletteWindow.ZIndex = 20000
                PaletteWindow.Active = true
                PaletteWindow.Visible = false
                PaletteWindow.Parent = window.Overlay

                local PalCorner = Instance.new("UICorner")
                PalCorner.CornerRadius = UDim.new(0, 4)
                PalCorner.Parent = PaletteWindow

                local PalStroke = Instance.new("UIStroke")
                PalStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                PalStroke.Color = COLORS.BorderGray
                PalStroke.Parent = PaletteWindow

                AddShadow(PaletteWindow)

                local CloseBtn = Instance.new("TextButton")
                CloseBtn.Name = RandomString()
                CloseBtn.Size = UDim2.new(0, 14, 0, 14)
                CloseBtn.Position = UDim2.new(1, -4, 0, 4)
                CloseBtn.AnchorPoint = Vector2.new(1, 0)
                CloseBtn.BackgroundTransparency = 1
                CloseBtn.FontFace = FONTS.Montserrat
                CloseBtn.Text = "X"
                CloseBtn.TextColor3 = COLORS.TextGray
                CloseBtn.TextSize = 11
                CloseBtn.ZIndex = 20003
                CloseBtn.Parent = PaletteWindow

                local SVCanvas = Instance.new("ImageLabel")
                SVCanvas.Name = RandomString()
                SVCanvas.Size = UDim2.new(1, -12, 0, 90)
                SVCanvas.Position = UDim2.new(0.5, 0, 0, 20)
                SVCanvas.AnchorPoint = Vector2.new(0.5, 0)
                SVCanvas.Image = "rbxassetid://4155801252"
                SVCanvas.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                SVCanvas.ZIndex = 20001
                SVCanvas.Active = true
                SVCanvas.Parent = PaletteWindow

                local SVCursor = Instance.new("Frame")
                SVCursor.Name = RandomString()
                SVCursor.Size = UDim2.new(0, 8, 0, 8)
                SVCursor.AnchorPoint = Vector2.new(0.5, 0.5)
                SVCursor.Position = UDim2.new(s, 0, 1 - v, 0)
                SVCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                SVCursor.ZIndex = 20002
                SVCursor.Parent = SVCanvas

                local SVCurCorner = Instance.new("UICorner")
                SVCurCorner.CornerRadius = UDim.new(1, 0)
                SVCurCorner.Parent = SVCursor

                local SVCurStroke = Instance.new("UIStroke")
                SVCurStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                SVCurStroke.Color = Color3.fromRGB(0, 0, 0)
                SVCurStroke.Parent = SVCursor

                local HueBar = Instance.new("Frame")
                HueBar.Name = RandomString()
                HueBar.Size = UDim2.new(1, -12, 0, 12)
                HueBar.Position = UDim2.new(0.5, 0, 0, 115)
                HueBar.AnchorPoint = Vector2.new(0.5, 0)
                HueBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                HueBar.ZIndex = 20001
                HueBar.Active = true
                HueBar.Parent = PaletteWindow

                local HueBarCorner = Instance.new("UICorner")
                HueBarCorner.CornerRadius = UDim.new(0, 2)
                HueBarCorner.Parent = HueBar

                local RainbowGradient = Instance.new("UIGradient")
                RainbowGradient.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                    ColorSequenceKeypoint.new(0.166, Color3.fromRGB(255, 255, 0)),
                    ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
                    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                    ColorSequenceKeypoint.new(0.666, Color3.fromRGB(0, 0, 255)),
                    ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
                })
                RainbowGradient.Parent = HueBar

                local HueCursor = Instance.new("Frame")
                HueCursor.Name = RandomString()
                HueCursor.Size = UDim2.new(0, 4, 1, 4)
                HueCursor.AnchorPoint = Vector2.new(0.5, 0.5)
                HueCursor.Position = UDim2.new(h, 0, 0.5, 0)
                HueCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                HueCursor.ZIndex = 20002
                HueCursor.Parent = HueBar

                local HueCurCorner = Instance.new("UICorner")
                HueCurCorner.CornerRadius = UDim.new(0, 2)
                HueCurCorner.Parent = HueCursor

                local HueCurStroke = Instance.new("UIStroke")
                HueCurStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                HueCurStroke.Color = Color3.fromRGB(0, 0, 0)
                HueCurStroke.Parent = HueCursor

                local function PositionPalette()
                    local absPos = ColorDisplay.AbsolutePosition
                    local absSize = ColorDisplay.AbsoluteSize
                    local overlayPos = window.Overlay.AbsolutePosition
                    local overlaySize = window.Overlay.AbsoluteSize

                    local x = absPos.X - overlayPos.X + absSize.X - 180
                    local y = absPos.Y - overlayPos.Y + absSize.Y + 4

                    if x + 180 > overlaySize.X then
                        x = overlaySize.X - 184
                    end
                    if x < 4 then
                        x = 4
                    end

                    if y + 134 > overlaySize.Y then
                        y = absPos.Y - overlayPos.Y - 138
                    end
                    if y < 4 then
                        y = 4
                    end

                    PaletteWindow.Position = UDim2.fromOffset(x, y)
                end

                local function UpdateColor()
                    currentColor = Color3.fromHSV(h, s, v)
                    ColorDisplay.BackgroundColor3 = currentColor
                    SVCanvas.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                    SVCursor.Position = UDim2.new(s, 0, 1 - v, 0)
                    HueCursor.Position = UDim2.new(h, 0, 0.5, 0)
                    if callback then callback(currentColor) end
                end

                local draggingSV, draggingHue = false, false

                SVCanvas.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingSV = true
                        Library.BlockWindowDrag = true
                    end
                end)

                HueBar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingHue = true
                        Library.BlockWindowDrag = true
                    end
                end)

                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingSV, draggingHue = false, false
                        Library.BlockWindowDrag = false
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseMovement then
                        if draggingSV then
                            local x = math.clamp((input.Position.X - SVCanvas.AbsolutePosition.X) / SVCanvas.AbsoluteSize.X, 0, 1)
                            local y = math.clamp((input.Position.Y - SVCanvas.AbsolutePosition.Y) / SVCanvas.AbsoluteSize.Y, 0, 1)
                            s = x
                            v = 1 - y
                            UpdateColor()
                        elseif draggingHue then
                            local x = math.clamp((input.Position.X - HueBar.AbsolutePosition.X) / HueBar.AbsoluteSize.X, 0, 1)
                            h = x
                            UpdateColor()
                        end
                    end
                end)

                CloseBtn.MouseButton1Click:Connect(function()
                    PaletteWindow.Visible = false
                    if Library.ActiveColorPicker == PaletteWindow then
                        Library.ActiveColorPicker = nil
                    end
                end)

                ColorDisplay.MouseButton1Click:Connect(function()
                    local willBeVisible = not PaletteWindow.Visible
                    CloseAllPopups()
                    if willBeVisible then
                        PositionPalette()
                        PaletteWindow.Visible = true
                        Library.ActiveColorPicker = PaletteWindow
                    end
                end)

                return ColorPickerFrame
            end

            function tab:AddKeybind(name, defaultKey, callback)
                local currentKey = defaultKey or Enum.KeyCode.RightShift

                local KeybindFrame = Instance.new("Frame")
                KeybindFrame.Name = RandomString()
                KeybindFrame.Size = UDim2.new(1, 0, 0, 14)
                KeybindFrame.BackgroundTransparency = 1
                KeybindFrame.Parent = TabCard

                local KeyLabel = Instance.new("TextLabel")
                KeyLabel.Name = RandomString()
                KeyLabel.Size = UDim2.new(1, -60, 0, 14)
                KeyLabel.BackgroundTransparency = 1
                KeyLabel.FontFace = FONTS.Montserrat
                KeyLabel.Text = name
                KeyLabel.TextColor3 = COLORS.TextGray
                KeyLabel.TextSize = 14
                KeyLabel.TextXAlignment = Enum.TextXAlignment.Left
                KeyLabel.Parent = KeybindFrame

                local KeyBtn = Instance.new("TextButton")
                KeyBtn.Name = RandomString()
                KeyBtn.Size = UDim2.new(0, 60, 0, 14)
                KeyBtn.Position = UDim2.new(1, 0, 0, 0)
                KeyBtn.AnchorPoint = Vector2.new(1, 0)
                KeyBtn.BackgroundColor3 = COLORS.ElementBG
                KeyBtn.FontFace = FONTS.Montserrat
                KeyBtn.Text = currentKey.Name
                KeyBtn.TextColor3 = COLORS.TextWhite
                KeyBtn.TextSize = 12
                KeyBtn.AutoButtonColor = false
                KeyBtn.Parent = KeybindFrame

                local KeyCorner = Instance.new("UICorner")
                KeyCorner.CornerRadius = UDim.new(0, 2)
                KeyCorner.Parent = KeyBtn

                local KeyStroke = Instance.new("UIStroke")
                KeyStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                KeyStroke.Color = COLORS.BorderGray
                KeyStroke.Parent = KeyBtn

                local listening = false
                KeyBtn.MouseButton1Click:Connect(function()
                    listening = true
                    KeyBtn.Text = "..."
                end)

                UserInputService.InputBegan:Connect(function(input, gpe)
                    if listening and not gpe then
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            currentKey = input.KeyCode
                            KeyBtn.Text = currentKey.Name
                            listening = false
                            if callback then callback(currentKey) end
                        end
                    end
                end)

                return KeybindFrame
            end

            return tab
        end

        return sectionObj
    end

    return window
end

return Library
