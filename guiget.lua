local Players = game:GetService("Players")
local SG = game:GetService("StarterGui")
local CS = game:GetService("CollectionService")
local TS = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

local function corner(p, r) Instance.new("UICorner", p).CornerRadius = r or UDim.new(0, 8) end
local function stroke(p, c, t) local s = Instance.new("UIStroke", p); s.Color = c; s.Thickness = t or 1.5 end
local function grad(p, c0, c1, rot)
    local g = Instance.new("UIGradient", p)
    g.Color = ColorSequence.new{ColorSequenceKeypoint.new(0,c0),ColorSequenceKeypoint.new(1,c1)}
    g.Rotation = rot or 0
end

local sGui = Instance.new("ScreenGui")
sGui.Name = "_GC"; sGui.ResetOnSpawn = false
sGui.DisplayOrder = 9999; sGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local win = Instance.new("Frame")
win.AnchorPoint = Vector2.new(0.5,0.5)
win.Size = UDim2.new(0,280,0,208)
win.Position = UDim2.new(0.5,0,0.5,0)
win.BackgroundColor3 = Color3.fromRGB(10,10,17)
win.BorderSizePixel = 0; win.ClipsDescendants = true; win.Parent = sGui
corner(win, UDim.new(0,10)); stroke(win, Color3.fromRGB(84,44,196), 1.5)

local hdr = Instance.new("Frame")
hdr.Size = UDim2.new(1,0,0,44)
hdr.BackgroundColor3 = Color3.fromRGB(19,11,44)
hdr.BorderSizePixel = 0; hdr.ZIndex = 2; hdr.Parent = win
corner(hdr, UDim.new(0,10))
grad(hdr, Color3.fromRGB(28,15,60), Color3.fromRGB(19,11,44), 90)

local hdrFix = Instance.new("Frame")
hdrFix.Size = UDim2.new(1,0,0,12); hdrFix.Position = UDim2.new(0,0,1,-12)
hdrFix.BackgroundColor3 = Color3.fromRGB(19,11,44)
hdrFix.BorderSizePixel = 0; hdrFix.ZIndex = 2; hdrFix.Parent = hdr

local ttl = Instance.new("TextLabel")
ttl.Size = UDim2.new(1,-48,1,0); ttl.Position = UDim2.new(0,14,0,0)
ttl.BackgroundTransparency = 1; ttl.Text = "◈  GUI COLLECTOR"
ttl.TextColor3 = Color3.fromRGB(148,108,252); ttl.TextSize = 13
ttl.Font = Enum.Font.GothamBold
ttl.TextXAlignment = Enum.TextXAlignment.Left; ttl.ZIndex = 3; ttl.Parent = hdr

local dot = Instance.new("Frame")
dot.Size = UDim2.new(0,8,0,8); dot.Position = UDim2.new(1,-20,0.5,-4)
dot.BackgroundColor3 = Color3.fromRGB(78,205,118)
dot.BorderSizePixel = 0; dot.ZIndex = 3; dot.Parent = hdr
corner(dot, UDim.new(1,0))

local info = Instance.new("TextLabel")
info.Size = UDim2.new(1,-20,0,22); info.Position = UDim2.new(0,12,0,52)
info.BackgroundTransparency = 1; info.Text = "Готов к сбору"
info.TextColor3 = Color3.fromRGB(105,182,145); info.TextSize = 11
info.Font = Enum.Font.Gotham
info.TextXAlignment = Enum.TextXAlignment.Left; info.Parent = win

local btnS = Instance.new("TextButton")
btnS.Size = UDim2.new(1,-20,0,42); btnS.Position = UDim2.new(0,10,0,82)
btnS.BackgroundColor3 = Color3.fromRGB(62,32,152); btnS.BorderSizePixel = 0
btnS.Text = "▶  НАЧАТЬ СБОР"
btnS.TextColor3 = Color3.fromRGB(210,190,255); btnS.TextSize = 13
btnS.Font = Enum.Font.GothamBold; btnS.AutoButtonColor = false; btnS.Parent = win
corner(btnS); stroke(btnS, Color3.fromRGB(94,54,210), 1)

local btnCp = Instance.new("TextButton")
btnCp.Size = UDim2.new(1,-20,0,42); btnCp.Position = UDim2.new(0,10,0,132)
btnCp.BackgroundColor3 = Color3.fromRGB(16,44,37); btnCp.BorderSizePixel = 0
btnCp.Text = "⧉  КОПИРОВАТЬ СКРИПТ"
btnCp.TextColor3 = Color3.fromRGB(72,152,122); btnCp.TextSize = 13
btnCp.Font = Enum.Font.GothamBold; btnCp.AutoButtonColor = false; btnCp.Parent = win
corner(btnCp)

local codeSec = Instance.new("Frame")
codeSec.Size = UDim2.new(1,0,0,202); codeSec.Position = UDim2.new(0,0,0,208)
codeSec.BackgroundTransparency = 1; codeSec.BorderSizePixel = 0
codeSec.Visible = false; codeSec.Parent = win

local codeDiv = Instance.new("Frame")
codeDiv.Size = UDim2.new(1,-20,0,1); codeDiv.Position = UDim2.new(0,10,0,6)
codeDiv.BackgroundColor3 = Color3.fromRGB(40,25,80)
codeDiv.BorderSizePixel = 0; codeDiv.Parent = codeSec

local codeLbl = Instance.new("TextLabel")
codeLbl.Size = UDim2.new(0,168,0,18); codeLbl.Position = UDim2.new(0,12,0,14)
codeLbl.BackgroundTransparency = 1; codeLbl.Text = "ПРЕДПРОСМОТР СКРИПТА"
codeLbl.TextColor3 = Color3.fromRGB(80,60,140); codeLbl.TextSize = 10
codeLbl.Font = Enum.Font.GothamBold
codeLbl.TextXAlignment = Enum.TextXAlignment.Left; codeLbl.Parent = codeSec

local selBtn = Instance.new("TextButton")
selBtn.Size = UDim2.new(0,78,0,18); selBtn.Position = UDim2.new(1,-88,0,14)
selBtn.BackgroundColor3 = Color3.fromRGB(38,22,76); selBtn.BorderSizePixel = 0
selBtn.Text = "SELECT ALL"; selBtn.TextColor3 = Color3.fromRGB(130,95,215)
selBtn.TextSize = 9; selBtn.Font = Enum.Font.GothamBold; selBtn.Parent = codeSec
corner(selBtn, UDim.new(0,4))

local codeScrl = Instance.new("ScrollingFrame")
codeScrl.Size = UDim2.new(1,-20,0,158); codeScrl.Position = UDim2.new(0,10,0,38)
codeScrl.BackgroundColor3 = Color3.fromRGB(7,7,12); codeScrl.BorderSizePixel = 0
codeScrl.ScrollBarThickness = 3
codeScrl.ScrollBarImageColor3 = Color3.fromRGB(80,50,160)
codeScrl.ScrollingDirection = Enum.ScrollingDirection.Y
codeScrl.AutomaticCanvasSize = Enum.AutomaticSize.Y
codeScrl.CanvasSize = UDim2.new(1,0,0,0); codeScrl.Parent = codeSec
corner(codeScrl, UDim.new(0,6))

local codeBox = Instance.new("TextBox")
codeBox.Size = UDim2.new(1,-8,0,0); codeBox.Position = UDim2.new(0,4,0,4)
codeBox.AutomaticSize = Enum.AutomaticSize.Y
codeBox.BackgroundTransparency = 1; codeBox.Text = ""
codeBox.TextSize = 9; codeBox.Font = Enum.Font.Code
codeBox.TextColor3 = Color3.fromRGB(170,215,170)
codeBox.TextXAlignment = Enum.TextXAlignment.Left
codeBox.TextYAlignment = Enum.TextYAlignment.Top
codeBox.MultiLine = true; codeBox.TextEditable = false
codeBox.TextWrapped = false; codeBox.ClearTextOnFocus = false; codeBox.Parent = codeScrl

sGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

local dragging, dragStart, startPos = false
hdr.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = i.Position; startPos = win.Position
    end
end)
UIS.InputChanged:Connect(function(i)
    if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
        local d = i.Position - dragStart
        win.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + d.X,
            startPos.Y.Scale, startPos.Y.Offset + d.Y
        )
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

local function sv(v)
    local t = typeof(v)
    if t == "string" then
        return ("%q"):format(v)
    elseif t == "number" then
        if v ~= v then return "(0/0)" end
        if v == math.huge then return "math.huge" end
        if v == -math.huge then return "-math.huge" end
        return tostring(v)
    elseif t == "boolean" then
        return v and "true" or "false"
    elseif t == "Color3" then
        return ("Color3.fromRGB(%d,%d,%d)"):format(
            math.round(v.R*255), math.round(v.G*255), math.round(v.B*255))
    elseif t == "UDim2" then
        return ("UDim2.new(%g,%d,%g,%d)"):format(
            v.X.Scale, v.X.Offset, v.Y.Scale, v.Y.Offset)
    elseif t == "UDim" then
        return ("UDim.new(%g,%d)"):format(v.Scale, v.Offset)
    elseif t == "Vector2" then
        return ("Vector2.new(%g,%g)"):format(v.X, v.Y)
    elseif t == "Vector3" then
        return ("Vector3.new(%g,%g,%g)"):format(v.X, v.Y, v.Z)
    elseif t == "Rect" then
        return ("Rect.new(%g,%g,%g,%g)"):format(v.Min.X, v.Min.Y, v.Max.X, v.Max.Y)
    elseif t == "ColorSequence" then
        local p = {}
        for _, k in ipairs(v.Keypoints) do
            p[#p+1] = ("ColorSequenceKeypoint.new(%g,Color3.fromRGB(%d,%d,%d))"):format(
                k.Time, math.round(k.Value.R*255),
                math.round(k.Value.G*255), math.round(k.Value.B*255))
        end
        return "ColorSequence.new({"..table.concat(p,",").."})"
    elseif t == "NumberSequence" then
        local p = {}
        for _, k in ipairs(v.Keypoints) do
            p[#p+1] = ("NumberSequenceKeypoint.new(%g,%g,%g)"):format(
                k.Time, k.Value, k.Envelope)
        end
        return "NumberSequence.new({"..table.concat(p,",").."})"
    elseif t == "EnumItem" then
        return tostring(v)
    elseif t == "Font" then
        return ('Font.new("%s",Enum.FontWeight.%s,Enum.FontStyle.%s)'):format(
            v.Family, v.Weight.Name, v.Style.Name)
    end
    return nil
end

local GOB = {
    "Name","Visible","ZIndex","LayoutOrder","AutoLocalize","SelectionGroup",
    "AnchorPoint","BackgroundColor3","BackgroundTransparency","BorderColor3",
    "BorderSizePixel","BorderMode","ClipsDescendants","Interactable",
    "Position","Rotation","Size","SizeConstraint",
}
local TXT = {
    "Font","FontFace","LineHeight","MaxVisibleGraphemes","RichText","Text",
    "TextColor3","TextScaled","TextSize","TextStrokeColor3","TextStrokeTransparency",
    "TextTransparency","TextWrapped","TextXAlignment","TextYAlignment",
}
local IMG = {
    "Image","ImageColor3","ImageRectOffset","ImageRectSize","ImageTransparency",
    "ResampleMode","ScaleType","SliceCenter","SliceScale","TileSize",
}
local BTN = {"AutoButtonColor","Modal","Selected","Style"}

local function mg(...)
    local r, s = {}, {}
    for _, t in ipairs({...}) do
        for _, v in ipairs(t) do
            if not s[v] then s[v] = true; r[#r+1] = v end
        end
    end
    return r
end

local P = {
    ScreenGui = {
        "Name","DisplayOrder","Enabled","IgnoreGuiInset","ResetOnSpawn",
        "ZIndexBehavior","ScreenInsets","ClipToDeviceSafeArea"
    },
    Frame              = mg(GOB, {"Style"}),
    TextLabel          = mg(GOB, TXT),
    TextButton         = mg(GOB, TXT, BTN),
    TextBox            = mg(GOB, TXT, {
        "ClearTextOnFocus","MultiLine","PlaceholderColor3",
        "PlaceholderText","ShowNativeInput","TextEditable"
    }),
    ImageLabel         = mg(GOB, IMG),
    ImageButton        = mg(GOB, IMG, BTN, {"HoverImage","PressedImage"}),
    ScrollingFrame     = mg(GOB, {
        "AutomaticCanvasSize","BottomImage","CanvasPosition","CanvasSize",
        "ElasticBehavior","HorizontalScrollBarInset","MidImage",
        "ScrollBarImageColor3","ScrollBarImageTransparency","ScrollBarThickness",
        "ScrollingDirection","ScrollingEnabled","TopImage",
        "VerticalScrollBarInset","VerticalScrollBarPosition"
    }),
    ViewportFrame      = mg(GOB, {
        "Ambient","LightColor","LightDirection","ImageColor3","ImageTransparency"
    }),
    VideoFrame         = mg(GOB, {
        "Looped","Playing","TimePosition","Video","Volume"
    }),
    BillboardGui       = {
        "Name","Active","AlwaysOnTop","Brightness","ClipsDescendants",
        "DistanceLowerLimit","DistanceUpperLimit","ExtentsOffset",
        "ExtentsOffsetWorldSpace","LightInfluence","MaxDistance","ResetOnSpawn",
        "Size","SizeOffset","StudsOffset","StudsOffsetWorldSpace","ZIndexBehavior"
    },
    SurfaceGui         = {
        "Name","Active","Brightness","ClipsDescendants","Face",
        "LightInfluence","MaxDistance","PixelsPerStud","ResetOnSpawn",
        "SizingMode","ToolPunchThroughDistance","ZIndexBehavior","ZOffset"
    },
    UIAspectRatioConstraint = {"Name","AspectRatio","AspectType","DominantAxis"},
    UICorner           = {"Name","CornerRadius"},
    UIFlexItem         = {"Name","FlexMode","GrowRatio","ShrinkRatio"},
    UIGradient         = {"Name","Color","Enabled","Offset","Rotation","Transparency"},
    UIGridLayout       = {
        "Name","CellPadding","CellSize","FillDirection",
        "FillDirectionMaxCells","HorizontalAlignment","SortOrder",
        "StartCorner","VerticalAlignment"
    },
    UIListLayout       = {
        "Name","FillDirection","HorizontalAlignment","ItemLineAlignment",
        "Padding","SortOrder","VerticalAlignment","Wraps"
    },
    UIPadding          = {"Name","PaddingBottom","PaddingLeft","PaddingRight","PaddingTop"},
    UIPageLayout       = {
        "Name","Animated","Circular","EasingDirection","EasingStyle",
        "FillDirection","GamepadInputEnabled","HorizontalAlignment","Padding",
        "ScrollWheelInputEnabled","SortOrder","TouchInputEnabled","TweenTime",
        "VerticalAlignment"
    },
    UIScale            = {"Name","Scale"},
    UISizeConstraint   = {"Name","MaxSize","MinSize"},
    UIStroke           = {
        "Name","ApplyStrokeMode","Color","Enabled","LineJoinMode",
        "Thickness","Transparency"
    },
    UITableLayout      = {
        "Name","FillDirection","FillEmptySpaceColumns","FillEmptySpaceRows",
        "HorizontalAlignment","MajorAxis","Padding","SortOrder","VerticalAlignment"
    },
    UITextSizeConstraint = {"Name","MaxTextSize","MinTextSize"},
    Folder             = {"Name"},
    LocalScript        = {"Name","Disabled"},
    Script             = {"Name","Disabled","RunContext"},
    ModuleScript       = {"Name"},
}

local function build()
    local objs = {}
    local function walk(inst, pidx)
        local i = #objs + 1
        objs[i] = {inst = inst, pidx = pidx, cn = inst.ClassName}
        for _, c in ipairs(inst:GetChildren()) do walk(c, i) end
    end
    for _, c in ipairs(SG:GetChildren()) do walk(c, 0) end

    local L = {
        'local _sg=game:GetService("StarterGui")',
        'local _cs=game:GetService("CollectionService")',
        "local _o={}",
        "",
    }

    for i, d in ipairs(objs) do
        local inst = d.inst
        L[#L+1] = ('_o[%d]=Instance.new("%s")'):format(i, d.cn)
        for _, p in ipairs(P[d.cn] or {"Name"}) do
            local ok, v = pcall(function() return inst[p] end)
            if ok and v ~= nil then
                local s = sv(v)
                if s then L[#L+1] = ("_o[%d].%s=%s"):format(i, p, s) end
            end
        end
        for _, tag in ipairs(CS:GetTags(inst)) do
            L[#L+1] = ('_cs:AddTag(_o[%d],"%s")'):format(i, tag)
        end
        if d.pidx == 0 then
            L[#L+1] = ("_o[%d].Parent=_sg"):format(i)
        else
            L[#L+1] = ("_o[%d].Parent=_o[%d]"):format(i, d.pidx)
        end
        L[#L+1] = ""
    end

    return table.concat(L, "\n"), #objs
end

local result = nil

btnS.MouseEnter:Connect(function() btnS.BackgroundColor3 = Color3.fromRGB(80,46,178) end)
btnS.MouseLeave:Connect(function() btnS.BackgroundColor3 = Color3.fromRGB(62,32,152) end)
btnCp.MouseEnter:Connect(function()
    if result then btnCp.BackgroundColor3 = Color3.fromRGB(22,58,48) end
end)
btnCp.MouseLeave:Connect(function()
    if result then btnCp.BackgroundColor3 = Color3.fromRGB(16,44,37) end
end)

selBtn.MouseButton1Click:Connect(function()
    codeBox:CaptureFocus()
    codeBox.SelectionStart = 1
    codeBox.CursorPosition = #codeBox.Text + 1
end)

btnS.MouseButton1Click:Connect(function()
    dot.BackgroundColor3 = Color3.fromRGB(220,175,40)
    info.Text = "Сканирование..."
    task.wait()
    local ok, code, count = pcall(build)
    if ok then
        result = code
        dot.BackgroundColor3 = Color3.fromRGB(78,205,118)
        info.Text = ("Собрано: %d объектов · %d симв."):format(count, #code)
        if #code <= 200000 then
            codeBox.Text = code
            codeSec.Visible = true
            TS:Create(win, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {Size = UDim2.new(0,280,0,414)}):Play()
        else
            codeSec.Visible = false
            info.Text = ("Собрано: %d объектов · %d симв. → Output"):format(count, #code)
        end
        local N = 9000
        for i = 1, #code, N do
            print(code:sub(i, math.min(i+N-1, #code)))
        end
    else
        dot.BackgroundColor3 = Color3.fromRGB(220,68,68)
        info.Text = "Ошибка сбора"
        warn("[GC] " .. tostring(code))
    end
end)

btnCp.MouseButton1Click:Connect(function()
    if not result then return end
    local ok = pcall(setclipboard, result)
    local prev = btnCp.Text
    if ok then
        btnCp.Text = "✓  СКОПИРОВАНО"
        dot.BackgroundColor3 = Color3.fromRGB(55,175,215)
        task.delay(1.8, function()
            btnCp.Text = prev
            if result then dot.BackgroundColor3 = Color3.fromRGB(78,205,118) end
        end)
    else
        info.Text = "→ Смотри Output (SELECT ALL в превью)"
    end
end)
