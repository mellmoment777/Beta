local Players = game:GetService("Players")
local CS = game:GetService("CollectionService")
local TS = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

local MARK = "GC_Root"      
local result = nil        
local ui = nil            
local gen = 0             

local KEEP_DUP = 3         

local TOKEN = "GC_" .. tostring(os.clock()) .. "_" .. tostring(math.random(100000000, 999999999))
pcall(function() shared.__GC_TOKEN = TOKEN end)
local function tokenAlive()
    local ok, v = pcall(function() return shared.__GC_TOKEN == TOKEN end)
    return ok and v or false
end

local okMain, errMain = pcall(function()

local lp = Players.LocalPlayer
while not lp do
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    lp = Players.LocalPlayer
end

local pg = lp:WaitForChild("PlayerGui")



local function resolveHiddenParent()
    local okH, h = pcall(function()
        return type(gethui) == "function" and gethui() or nil
    end)
    if okH and h then
        return h, "gethui"
    end

    local okC, cg = pcall(function()
        return game:GetService("CoreGui")
    end)
    if okC and cg then
        local probe = Instance.new("Folder")
        local okP = pcall(function() probe.Parent = cg end)
        if okP then
            probe:Destroy()
            return cg, "CoreGui"
        end
    end
    return nil, nil
end

local function pickHost()
    local best, bestScore = nil, -1
    for _, c in ipairs(pg:GetChildren()) do
        if c:IsA("ScreenGui") and c.Enabled then
            local s = 0
            if not c.ResetOnSpawn then s = s + 2 end
            if s > bestScore then best = c; bestScore = s end
        end
    end
    return best
end

local function waitHost(timeout)
    local t0 = os.clock()
    while os.clock() - t0 < (timeout or 8) do
        local h = pickHost()
        if h then return h end
        task.wait(0.2)
    end
    return nil
end

local function cleanupPrevious()
    local hid = resolveHiddenParent()
    if hid then
        pcall(function()
            for _, old in ipairs(hid:GetChildren()) do
                if old:IsA("ScreenGui") and old.Name == "_GC" then old:Destroy() end
            end
        end)
    end
    pcall(function()
        for _, d in ipairs(pg:GetDescendants()) do
            if d:GetAttribute(MARK) then d:Destroy() end
        end
        for _, old in ipairs(pg:GetChildren()) do
            if old:IsA("ScreenGui") and old.Name == "_GC" then old:Destroy() end
        end
    end)
end



local function corner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = r or UDim.new(0, 8)
    c.Parent = p
end
local function stroke(p, c, t)
    local s = Instance.new("UIStroke")
    s.Color = c
    s.Thickness = t or 1.5
    s.Parent = p
end
local function grad(p, c0, c1, rot)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, c0), ColorSequenceKeypoint.new(1, c1)})
    g.Rotation = rot or 0
    g.Parent = p
end

local function num(v)
    return tostring(v)
end

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
        return ("Color3.new(%s,%s,%s)"):format(num(v.R), num(v.G), num(v.B))
    elseif t == "UDim2" then
        return ("UDim2.new(%s,%d,%s,%d)"):format(
            num(v.X.Scale), v.X.Offset, num(v.Y.Scale), v.Y.Offset)
    elseif t == "UDim" then
        return ("UDim.new(%s,%d)"):format(num(v.Scale), v.Offset)
    elseif t == "Vector2" then
        return ("Vector2.new(%s,%s)"):format(num(v.X), num(v.Y))
    elseif t == "Rect" then
        return ("Rect.new(%s,%s,%s,%s)"):format(num(v.Min.X), num(v.Min.Y), num(v.Max.X), num(v.Max.Y))
    elseif t == "ColorSequence" then
        local p = {}
        for _, k in ipairs(v.Keypoints) do
            p[#p+1] = ("ColorSequenceKeypoint.new(%s,%s)"):format(num(k.Time), sv(k.Value))
        end
        return "ColorSequence.new({"..table.concat(p,",").."})"
    elseif t == "NumberSequence" then
        local p = {}
        for _, k in ipairs(v.Keypoints) do
            p[#p+1] = ("NumberSequenceKeypoint.new(%s,%s,%s)"):format(
                num(k.Time), num(k.Value), num(k.Envelope or 0))
        end
        return "NumberSequence.new({"..table.concat(p,",").."})"
    elseif t == "EnumItem" then
        return tostring(v)
    end
    return nil
end



local GOB = {
    "Name","Visible","ZIndex","LayoutOrder","AnchorPoint","Position","Size",
    "BackgroundColor3","BackgroundTransparency","BorderSizePixel",
    "ClipsDescendants","AutomaticSize","Rotation",
}
local TXT = {
    "Font","Text","TextColor3","TextSize","TextScaled","TextWrapped",
    "TextXAlignment","TextYAlignment","TextStrokeColor3",
    "TextStrokeTransparency","RichText",
}
local IMG = {
    "Image","ImageColor3","ImageTransparency","ScaleType","SliceCenter",
}
local BTN = {"AutoButtonColor"}

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
    ScreenGui = {"Name","DisplayOrder","Enabled","IgnoreGuiInset","ResetOnSpawn","ZIndexBehavior"},
    Frame     = GOB,
    TextLabel = mg(GOB, TXT),
    TextButton = mg(GOB, TXT, BTN),
    TextBox   = mg(GOB, TXT, {"PlaceholderText","PlaceholderColor3","MultiLine","ClearTextOnFocus"}),
    ImageLabel = mg(GOB, IMG),
    ImageButton = mg(GOB, IMG, BTN),
    ScrollingFrame = mg(GOB, {
        "ScrollBarThickness","ScrollBarImageColor3","ScrollBarImageTransparency",
        "CanvasSize","AutomaticCanvasSize","ScrollingDirection"
    }),
    CanvasGroup = mg(GOB, {"GroupColor3","GroupTransparency"}),
    UICorner    = {"Name","CornerRadius"},
    UIStroke    = {"Name","ApplyStrokeMode","Color","Thickness","Transparency"},
    UIGradient  = {"Name","Color","Rotation","Offset","Transparency","Enabled"},
    UIListLayout = {"Name","FillDirection","Padding","SortOrder","HorizontalAlignment","VerticalAlignment","Wraps"},
    UIGridLayout = {"Name","CellSize","CellPadding","FillDirection","SortOrder","HorizontalAlignment","VerticalAlignment"},
    UIPadding   = {"Name","PaddingBottom","PaddingLeft","PaddingRight","PaddingTop"},
    UIAspectRatioConstraint = {"Name","AspectRatio","AspectType","DominantAxis"},
    UIScale     = {"Name","Scale"},
    UISizeConstraint = {"Name","MinSize","MaxSize"},
    UIPageLayout = {"Name","FillDirection","Padding","SortOrder"},
    Folder      = {"Name"},
}

-- классы, бесполезные для стиля: 3D-превью, видео, код игры
local SKIP = {
    ViewportFrame = true,
    VideoFrame = true,
    SurfaceGui = true,
    BillboardGui = true,
    LocalScript = true,
    Script = true,
    ModuleScript = true,
}



local function collectRoots()
    local roots = {}
    for _, c in ipairs(pg:GetChildren()) do
        roots[#roots + 1] = c
    end
    local hid = resolveHiddenParent()
    if hid then
        pcall(function()
            for _, c in ipairs(hid:GetChildren()) do
                if not (ui and ui.container and c == ui.container) then
                    roots[#roots + 1] = c
                end
            end
        end)
    end
    return roots
end

local function build()
    local nodes = {}
    local rootNodes = {}

    local function skipOwn(inst)
        return ui and ui.container
            and (inst == ui.container or inst:IsDescendantOf(ui.container))
    end

    local function capture(inst, cn)
        local props = {}
        local list = P[cn] or {"Name"}
        for _, p in ipairs(list) do
            local ok, v = pcall(function() return inst[p] end)
            if ok and v ~= nil then
                local s = sv(v)
                if s then props[#props + 1] = {k = p, v = s} end
            end
        end
        return props
    end

    local function walk(inst, parentNode)
        if skipOwn(inst) then return end
        local cn = inst.ClassName
        if SKIP[cn] then return end
        local i = #nodes + 1
        local node = {
            inst = inst, cn = cn, props = capture(inst, cn),
            kids = {}, sig = nil, dupOf = nil, dupTotal = 0,
        }
        nodes[i] = node
        if parentNode then
            parentNode.kids[#parentNode.kids + 1] = node
        else
            rootNodes[#rootNodes + 1] = node
        end
        for _, c in ipairs(inst:GetChildren()) do
            walk(c, node)
        end
        if i % 50 == 0 then
            task.wait()
        end
    end

    for _, root in ipairs(collectRoots()) do
        pcall(walk, root, nil)
    end
    if #nodes == 0 then
        return "", 0, 0, 0
    end

   
    local function signature(node)
        if node.sig then return node.sig end
        local pk = {}
        for _, pr in ipairs(node.props) do
            pk[#pk + 1] = pr.k .. "=" .. pr.v
        end
        table.sort(pk)
        local cs = {}
        for _, c in ipairs(node.kids) do
            cs[#cs + 1] = signature(c)
        end
        node.sig = node.cn .. "{" .. table.concat(pk, ";") .. "}[" .. table.concat(cs, ",") .. "]"
        return node.sig
    end

    local skippedDups = 0

    local function markDups(children)
        local first, nth = {}, {}
        for _, c in ipairs(children) do
            local s = signature(c)
            if not first[s] then
                first[s] = c
                nth[s] = 1
            else
                nth[s] = nth[s] + 1
                if nth[s] > KEEP_DUP then
                    c.dupOf = first[s]
                    skippedDups = skippedDups + 1
                end
            end
        end
        for s, f in pairs(first) do
            if nth[s] > KEEP_DUP then
                f.dupTotal = nth[s]
            end
        end
    end

    local function markAll(node)
        markDups(node.kids)
        for _, c in ipairs(node.kids) do
            if not c.dupOf then
                markAll(c)
            end
        end
    end

    markDups(rootNodes)
    for _, r in ipairs(rootNodes) do
        if not r.dupOf then
            markAll(r)
        end
    end


    local colorFreq, palette = {}, {}
    for _, nd in ipairs(nodes) do
        for _, pr in ipairs(nd.props) do
            local v = pr.v
            if v:sub(1, 10) == "Color3.new" then
                colorFreq[v] = (colorFreq[v] or 0) + 1
            end
        end
    end
    for cval, n in pairs(colorFreq) do
        palette[#palette + 1] = {v = cval, n = n}
    end
    table.sort(palette, function(a, b) return a.n > b.n end)

   
    local L = {}
    L[#L + 1] = '-- ═══ GUI STYLE SNAPSHOT ═══'
    L[#L + 1] = '-- Назначение: референс стиля для генерации похожего Roblox GUI'
    L[#L + 1] = ('-- Игра: %s · PlaceId %s'):format(tostring(game.Name), tostring(game.PlaceId))
    L[#L + 1] = '-- Однотипные повторяющиеся блоки сокращены до ' .. KEEP_DUP .. ' экземпляров'
    L[#L + 1] = '-- Исключены: Script/LocalScript, ViewportFrame, VideoFrame, SurfaceGui'
    local topColors = {}
    for i = 1, math.min(12, #palette) do
        topColors[#topColors + 1] = palette[i].v
    end
    if #topColors > 0 then
        L[#L + 1] = '-- Частые цвета: ' .. table.concat(topColors, " · ")
    end
    L[#L + 1] = 'local Players=game:GetService("Players")'
    L[#L + 1] = 'local lp=Players.LocalPlayer'
    L[#L + 1] = 'while not lp do Players:GetPropertyChangedSignal("LocalPlayer"):Wait() lp=Players.LocalPlayer end'
    L[#L + 1] = 'local _pg=lp:WaitForChild("PlayerGui")'
    L[#L + 1] = 'local _cs=game:GetService("CollectionService")'
    L[#L + 1] = 'local _par=_pg'
    L[#L + 1] = 'do'
    L[#L + 1] = ' local _ok,_h=pcall(function() return type(gethui)=="function" and gethui() or nil end)'
    L[#L + 1] = ' if _ok and _h then _par=_h else'
    L[#L + 1] = '  local _ok2,_cg=pcall(function() return game:GetService("CoreGui") end)'
    L[#L + 1] = '  if _ok2 and _cg then'
    L[#L + 1] = '   local _f=Instance.new("Folder")'
    L[#L + 1] = '   local _ok3=pcall(function() _f.Parent=_cg end)'
    L[#L + 1] = '   _f:Destroy()'
    L[#L + 1] = '   if _ok3 then _par=_cg end'
    L[#L + 1] = '  end'
    L[#L + 1] = ' end'
    L[#L + 1] = 'end'
    L[#L + 1] = 'local _o={}'
    L[#L + 1] = ""

    local idOf = {}
    local kept = 0

    local function emit(node, parentIdx)
        kept = kept + 1
        local i = kept
        idOf[node] = i
        if kept % 200 == 0 then
            task.wait()
        end
        L[#L + 1] = ('_o[%d]=Instance.new("%s")'):format(i, node.cn)
        for _, pr in ipairs(node.props) do
            L[#L + 1] = ("_o[%d].%s=%s"):format(i, pr.k, pr.v)
        end
        if parentIdx == 0 then
            if node.cn == "ScreenGui" then
                L[#L + 1] = ('do local _e=_par:FindFirstChild(%s) if _e then _e:Destroy() end end')
                    :format(("%q"):format(tostring(node.inst.Name)))
            end
            L[#L + 1] = ("_o[%d].Parent=_par"):format(i)
        else
            L[#L + 1] = ("_o[%d].Parent=_o[%d]"):format(i, parentIdx)
        end
        L[#L + 1] = ""
        for _, c in ipairs(node.kids) do
            if c.dupOf then
                local total = c.dupOf.dupTotal or KEEP_DUP
                L[#L + 1] = ("-- ... ещё %d таких же блоков (копия _o[%d])"):format(
                    total - KEEP_DUP, idOf[c.dupOf] or 0)
            else
                emit(c, i)
            end
        end
    end

    for _, r in ipairs(rootNodes) do
        if r.dupOf then
            local total = r.dupOf.dupTotal or KEEP_DUP
            L[#L + 1] = ("-- ... ещё %d таких же ScreenGui (копия _o[%d])"):format(
                total - KEEP_DUP, idOf[r.dupOf] or 0)
        else
            emit(r, 0)
        end
    end

    return table.concat(L, "\n"), kept, skippedDups, #nodes
end



UIS.InputChanged:Connect(function(i)
    local w = ui and ui.win
    if w and w.Parent and ui.dragging
        and (i.UserInputType == Enum.UserInputType.MouseMovement
            or i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - ui.dragStart
        w.Position = UDim2.new(
            ui.startPos.X.Scale, ui.startPos.X.Offset + d.X,
            ui.startPos.Y.Scale, ui.startPos.Y.Offset + d.Y
        )
    end
end)
UIS.InputEnded:Connect(function(i)
    if ui and (i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch) then
        ui.dragging = false
    end
end)



local function buildUI()
    gen = gen + 1
    local myGen = gen
    cleanupPrevious()

    local hid, kind = resolveHiddenParent()
    local container, modeLabel, hiddenParent

    if hid then
        local sGui = Instance.new("ScreenGui")
        sGui.Name = "_GC"
        sGui.ResetOnSpawn = false
        sGui.DisplayOrder = 9999
        sGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        sGui.Parent = hid
        container = sGui
        hiddenParent = hid
        modeLabel = kind
    else
        local host = pickHost() or waitHost(8)
        if host then
            local root = Instance.new("Frame")
            root.Name = "Holder"
            root:SetAttribute(MARK, true)
            root.BackgroundTransparency = 1
            root.BorderSizePixel = 0
            root.Size = UDim2.new(1, 0, 1, 0)
            root.ZIndex = 999
            root.Parent = host
            container = root
            modeLabel = "встроено: " .. tostring(host.Name):sub(1, 14)
        else
            local sGui = Instance.new("ScreenGui")
            sGui.Name = "_GC"
            sGui.ResetOnSpawn = false
            sGui.DisplayOrder = 9999
            sGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            sGui.Parent = pg
            container = sGui
            modeLabel = "PlayerGui (без скрытия)"
        end
    end

    local win = Instance.new("Frame")
    win.AnchorPoint = Vector2.new(0.5, 0.5)
    win.Size = UDim2.new(0, 280, 0, 208)
    win.Position = UDim2.new(0.5, 0, 0.5, 0)
    win.BackgroundColor3 = Color3.fromRGB(10, 10, 17)
    win.BorderSizePixel = 0
    win.ClipsDescendants = true
    win.Active = true
    win.ZIndex = 500
    win.Parent = container
    corner(win, UDim.new(0, 10))
    stroke(win, Color3.fromRGB(84, 44, 196), 1.5)

    local hdr = Instance.new("Frame")
    hdr.Size = UDim2.new(1, 0, 0, 44)
    hdr.BackgroundColor3 = Color3.fromRGB(19, 11, 44)
    hdr.BorderSizePixel = 0
    hdr.ZIndex = 2
    hdr.Parent = win
    corner(hdr, UDim.new(0, 10))
    grad(hdr, Color3.fromRGB(28, 15, 60), Color3.fromRGB(19, 11, 44), 90)

    local hdrFix = Instance.new("Frame")
    hdrFix.Size = UDim2.new(1, 0, 0, 12)
    hdrFix.Position = UDim2.new(0, 0, 1, -12)
    hdrFix.BackgroundColor3 = Color3.fromRGB(19, 11, 44)
    hdrFix.BorderSizePixel = 0
    hdrFix.ZIndex = 2
    hdrFix.Parent = hdr

    local ttl = Instance.new("TextLabel")
    ttl.Size = UDim2.new(1, -48, 1, 0)
    ttl.Position = UDim2.new(0, 14, 0, 0)
    ttl.BackgroundTransparency = 1
    ttl.Text = "◈  GUI COLLECTOR"
    ttl.TextColor3 = Color3.fromRGB(148, 108, 252)
    ttl.TextSize = 13
    ttl.Font = Enum.Font.GothamBold
    ttl.TextXAlignment = Enum.TextXAlignment.Left
    ttl.ZIndex = 3
    ttl.Parent = hdr

    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 8, 0, 8)
    dot.Position = UDim2.new(1, -20, 0.5, -4)
    dot.BackgroundColor3 = Color3.fromRGB(78, 205, 118)
    dot.BorderSizePixel = 0
    dot.ZIndex = 3
    dot.Parent = hdr
    corner(dot, UDim.new(1, 0))

    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(1, -20, 0, 22)
    info.Position = UDim2.new(0, 12, 0, 52)
    info.BackgroundTransparency = 1
    info.Text = "Готов к сбору · " .. modeLabel
    info.TextColor3 = Color3.fromRGB(105, 182, 145)
    info.TextSize = 11
    info.Font = Enum.Font.Gotham
    info.TextXAlignment = Enum.TextXAlignment.Left
    info.Parent = win

    local btnS = Instance.new("TextButton")
    btnS.Size = UDim2.new(1, -20, 0, 42)
    btnS.Position = UDim2.new(0, 10, 0, 82)
    btnS.BackgroundColor3 = Color3.fromRGB(62, 32, 152)
    btnS.BorderSizePixel = 0
    btnS.Text = "▶  НАЧАТЬ СБОР"
    btnS.TextColor3 = Color3.fromRGB(210, 190, 255)
    btnS.TextSize = 13
    btnS.Font = Enum.Font.GothamBold
    btnS.AutoButtonColor = false
    btnS.Parent = win
    corner(btnS)
    stroke(btnS, Color3.fromRGB(94, 54, 210), 1)

    local btnCp = Instance.new("TextButton")
    btnCp.Size = UDim2.new(1, -20, 0, 42)
    btnCp.Position = UDim2.new(0, 10, 0, 132)
    btnCp.BackgroundColor3 = Color3.fromRGB(16, 44, 37)
    btnCp.BorderSizePixel = 0
    btnCp.Text = "⧉  КОПИРОВАТЬ СКРИПТ"
    btnCp.TextColor3 = Color3.fromRGB(72, 152, 122)
    btnCp.TextSize = 13
    btnCp.Font = Enum.Font.GothamBold
    btnCp.AutoButtonColor = false
    btnCp.Parent = win
    corner(btnCp)

    local codeSec = Instance.new("Frame")
    codeSec.Size = UDim2.new(1, 0, 0, 202)
    codeSec.Position = UDim2.new(0, 0, 0, 208)
    codeSec.BackgroundTransparency = 1
    codeSec.BorderSizePixel = 0
    codeSec.Visible = false
    codeSec.Parent = win

    local codeDiv = Instance.new("Frame")
    codeDiv.Size = UDim2.new(1, -20, 0, 1)
    codeDiv.Position = UDim2.new(0, 10, 0, 6)
    codeDiv.BackgroundColor3 = Color3.fromRGB(40, 25, 80)
    codeDiv.BorderSizePixel = 0
    codeDiv.Parent = codeSec

    local codeLbl = Instance.new("TextLabel")
    codeLbl.Size = UDim2.new(0, 168, 0, 18)
    codeLbl.Position = UDim2.new(0, 12, 0, 14)
    codeLbl.BackgroundTransparency = 1
    codeLbl.Text = "СЛЕПОК СТИЛЯ ДЛЯ ИИ"
    codeLbl.TextColor3 = Color3.fromRGB(80, 60, 140)
    codeLbl.TextSize = 10
    codeLbl.Font = Enum.Font.GothamBold
    codeLbl.TextXAlignment = Enum.TextXAlignment.Left
    codeLbl.Parent = codeSec

    local selBtn = Instance.new("TextButton")
    selBtn.Size = UDim2.new(0, 78, 0, 18)
    selBtn.Position = UDim2.new(1, -88, 0, 14)
    selBtn.BackgroundColor3 = Color3.fromRGB(38, 22, 76)
    selBtn.BorderSizePixel = 0
    selBtn.Text = "SELECT ALL"
    selBtn.TextColor3 = Color3.fromRGB(130, 95, 215)
    selBtn.TextSize = 9
    selBtn.Font = Enum.Font.GothamBold
    selBtn.Parent = codeSec
    corner(selBtn, UDim.new(0, 4))

    local codeScrl = Instance.new("ScrollingFrame")
    codeScrl.Size = UDim2.new(1, -20, 0, 158)
    codeScrl.Position = UDim2.new(0, 10, 0, 38)
    codeScrl.BackgroundColor3 = Color3.fromRGB(7, 7, 12)
    codeScrl.BorderSizePixel = 0
    codeScrl.ScrollBarThickness = 3
    codeScrl.ScrollBarImageColor3 = Color3.fromRGB(80, 50, 160)
    codeScrl.ScrollingDirection = Enum.ScrollingDirection.Y
    codeScrl.AutomaticCanvasSize = Enum.AutomaticSize.Y
    codeScrl.CanvasSize = UDim2.new(1, 0, 0, 0)
    codeScrl.Parent = codeSec
    corner(codeScrl, UDim.new(0, 6))

    local codeBox = Instance.new("TextBox")
    codeBox.Size = UDim2.new(1, -8, 0, 0)
    codeBox.Position = UDim2.new(0, 4, 0, 4)
    codeBox.AutomaticSize = Enum.AutomaticSize.Y
    codeBox.BackgroundTransparency = 1
    codeBox.Text = ""
    codeBox.TextSize = 9
    codeBox.Font = Enum.Font.Code
    codeBox.TextColor3 = Color3.fromRGB(170, 215, 170)
    codeBox.TextXAlignment = Enum.TextXAlignment.Left
    codeBox.TextYAlignment = Enum.TextYAlignment.Top
    codeBox.MultiLine = true
    codeBox.TextEditable = false
    codeBox.TextWrapped = false
    codeBox.ClearTextOnFocus = false
    codeBox.Parent = codeScrl

    ui = {
        container = container,
        hiddenParent = hiddenParent,
        win = win,
        hdr = hdr,
        dot = dot,
        info = info,
        btnS = btnS,
        btnCp = btnCp,
        codeSec = codeSec,
        codeBox = codeBox,
        dragging = false,
        dragStart = nil,
        startPos = nil,
    }

    hdr.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch then
            ui.dragging = true
            ui.dragStart = i.Position
            ui.startPos = win.Position
        end
    end)

    container.AncestryChanged:Connect(function(_, parent)
        if parent == nil then
            task.delay(0.6, function()
                if gen == myGen and tokenAlive() then
                    pcall(buildUI)
                end
            end)
        end
    end)

    selBtn.MouseButton1Click:Connect(function()
        codeBox:CaptureFocus()
        codeBox.SelectionStart = 1
        codeBox.CursorPosition = #codeBox.Text + 1
    end)

    btnS.MouseEnter:Connect(function() btnS.BackgroundColor3 = Color3.fromRGB(80, 46, 178) end)
    btnS.MouseLeave:Connect(function() btnS.BackgroundColor3 = Color3.fromRGB(62, 32, 152) end)
    btnCp.MouseEnter:Connect(function()
        if result then btnCp.BackgroundColor3 = Color3.fromRGB(22, 58, 48) end
    end)
    btnCp.MouseLeave:Connect(function()
        if result then btnCp.BackgroundColor3 = Color3.fromRGB(16, 44, 37) end
    end)

    btnS.MouseButton1Click:Connect(function()
        dot.BackgroundColor3 = Color3.fromRGB(220, 175, 40)
        info.Text = "Сканирование..."
        task.wait()
        local okB, code, count, dups, total = pcall(build)
        if okB and count > 0 then
            result = code
            dot.BackgroundColor3 = Color3.fromRGB(78, 205, 118)
            info.Text = ("Собрано: %d об. (из %d) · -%d дублей"):format(count, total, dups)
            if #code <= 200000 then
                codeBox.Text = code
                codeSec.Visible = true
                TS:Create(win, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    {Size = UDim2.new(0, 280, 0, 414)}):Play()
                info.Text = ("Собрано: %d об. (из %d) · -%d дублей · %d симв."):format(count, total, dups, #code)
            else
                codeSec.Visible = false
                info.Text = ("Собрано: %d об. · -%d дублей · %d симв. → Output"):format(count, dups, #code)
            end
            local N = 9000
            for i = 1, #code, N do
                print(code:sub(i, math.min(i + N - 1, #code)))
            end
        elseif okB then
            dot.BackgroundColor3 = Color3.fromRGB(220, 175, 40)
            info.Text = "GUI не найдены"
        else
            dot.BackgroundColor3 = Color3.fromRGB(220, 68, 68)
            info.Text = "Ошибка сбора"
            warn("[GC] " .. tostring(code))
        end
    end)

    btnCp.MouseButton1Click:Connect(function()
        if not result then return end
        local fn = (type(setclipboard) == "function" and setclipboard)
            or (type(toclipboard) == "function" and toclipboard)
            or nil
        local ok = false
        if fn then
            ok = pcall(fn, result)
        end
        local prev = btnCp.Text
        if ok then
            btnCp.Text = "✓  СКОПИРОВАНО"
            dot.BackgroundColor3 = Color3.fromRGB(55, 175, 215)
            task.delay(1.8, function()
                btnCp.Text = prev
                if result then dot.BackgroundColor3 = Color3.fromRGB(78, 205, 118) end
            end)
        else
            info.Text = "→ Смотри Output (SELECT ALL в превью)"
        end
    end)
end

buildUI()

end)

if not okMain then
    warn("[GC] Ошибка запуска: " .. tostring(errMain))
end
