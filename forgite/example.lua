local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/fonctiono/libraries/refs/heads/main/forgite/forgite.lua"))()
local Window = Library:CreateWindow("Window Name | Forgite UI Lib by da.cli3nt on discord")

local Section1 = Window:CreateSection("Section 1")
local Tab1 = Section1:CreateTab("Tab 1")
local Tab2 = Section1:CreateTab("Tab 2")


local SettingsSection = Window:CreateSection("Settings")
local SettingsTab = SettingsSection:CreateTab("GUI Settings") -- dont remove Settings Tab it contains UI Settings and i highly recommend keeping it.


Tab1:AddToggle("Toggle", false, function(state)
    print(state)
end)
Tab1:AddSlider("Slider", 10, 500, 120, function(val)
    print(val)
end)
Tab2:AddColorPicker("Color Picker", Color3.fromRGB(255, 255, 255), function(col)
    print(tostring(col))
end)
Tab2:AddDropdown("Dropdown", {"Option 1", "Option 2", "Option 3"}, "Option 2", function(selected)
    print(selected)
end)
Tab2:AddKeybind("Keybind", Enum.KeyCode.X, function(key)
    print(tostring(key))
end)


-- dont remove UI Settings i recommend keeping it
SettingsTab:AddColorPicker("Color", Library.AccentColor, function(col)
    Library:SetAccentColor(col)
end)
SettingsTab:AddKeybind("Menu", Library.ToggleKeybind, function(key)
    Library.ToggleKeybind = key
end)
SettingsTab:AddSlider("Window Width", 400, 800, 500, function(width)
    Window:SetSize(width, Window.WindowFrame.Size.Y.Offset)
end)
SettingsTab:AddSlider("Window Height", 400, 900, 626, function(height)
    Window:SetSize(Window.WindowFrame.Size.X.Offset, height)
end)
