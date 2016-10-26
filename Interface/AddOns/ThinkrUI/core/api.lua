local F,C = unpack(select(2,...)) --导入 Functions,Constants

local media={
    ["fonts"]="Interface\\AddOns\\ThinKrUI\\media\\fonts",
    ["sound"]="Interface\\AddOns\\ThinKrUI\\media\\sound",
    ["texture"]="Interface\\AddOns\\ThinKrUI\\media\\texture"
}
-- 设置字体，材质 文件路径
C.media = {
  ["font"]=mediaPath.fonts.."font.ttf", --字体
  ["font2"]=mediaPath.fonts.."font.ttf", --备用字体（这才是主字体)
  ["backdrop"]=mediaPath.texture.."ChatFrameBackground", --默认背景
  ["glow"] = mediaPath.texture.."glowTex", --发光/阴影材质
  ["gradient"] = mediaPath.texture.."gradient",--梯度材质
  ["roleIcons"] =mediaPath.texture.. "UI-LFG-ICON-ROLES", --角色图标
  ["texture"] = mediaPath.texture.."statusbar", -- 状态条材质
  ["slider"]=mediaPath.texture.."UI-CastingBar-Spark"
}

local mainFont --字体

-- [[这玩意，设置不设置都一样。没用。]]
if C.appearance.fontUseAlternativeFont then --如果使用备用字体
  mainFont = C.media.font2
else
  mainFont = C.media.font
end

F.AddOptionsCallback('appearance','fontUseAlternativeFont',function()
    -- 这都不想写了。。。上边的代码再来一遍
    if C.appearance.fontUseAlternativeFont then --如果使用备用字体
      mainFont = C.media.font2
    else
      mainFont = C.media.font
    end
  end)

-- 设置职业颜色

C.classcolours = {
  ["DEATHKNIGHT"] = {r = 0.77, g = 0.12, b = 0.23}, --死亡骑士
  ["DEMONHUNTER"] = {r = 0.64, g = 0.19, b = 0.79}, --恶魔猎手
  ["DRUID"] = {r = 1, g = 0.49, b = 0.04}, --德鲁伊
  ["HUNTER"] = {r = 0.58, g = 0.86, b = 0.49}, --猎人
  ["MAGE"] = {r = 0, g = 0.76, b = 1}, --法师
  ["MONK"] = {r = 0.0, g = 1.00 , b = 0.59}, --武僧
  ["PALADIN"] = {r = 1, g = 0.22, b = 0.52}, --圣骑士
  ["PRIEST"] = {r = 0.8, g = 0.87, b = .9}, --牧师
  ["ROGUE"] = {r = 1, g = 0.91, b = 0.2}, --盗贼
  ["SHAMAN"] = {r = 0, g = 0.6, b = 0.6}, --萨满
  ["WARLOCK"] = {r = 0.6, g = 0.47, b = 0.85}, --术士
  ["WARRIOR"] = {r = 0.9, g = 0.65, b = 0.45}, --战士
}

local _,class = UnitClass("player") --当前玩家职业
--[[
    如果玩家自定义了颜色，则使用设置后的，否则使用职业色
    colourScheme：2 自定义。 1，估计就应该是职业色了。
--]]

-- TODO：。。。
if C.appearance.colourScheme ==2 then
  C.class={
      C.appearance.customColour.r,
      C.appearance.customColour.g,
      C.appearance.customColour.b
  }
else
  C.class={
      C.classcolours[class].r,
      C.classcolours[class].g,
      C.classcolours[class].b
  }
end

C.r, C.g, C.b = unpack(C.class)
-- 响应颜色
C.reactioncolours = {
	[1] = {1, .12, .24},
	[2] = {1, .12, .24},
	[3] = {1, .12, .24},
	[4] = {1, 1, 0.3},
	[5] = {0.26, 1, 0.22},
	[6] = {0.26, 1, 0.22},
	[7] = {0.26, 1, 0.22},
	[8] = {0.26, 1, 0.22},
}

C.myClass = class --本人职业色
C.myName = UnitName("player")
C.myRealm = GetRealmName()


C.FONT_SIZE_LARGE=2 --大字
C.FONT_SIZE_NORMAL=1--正常

--[[函数]]

F.dummy = function() end -- 干啥用的？

-- 添加插件执行的函数
F.AddPlugin = function(func)
    func()
end



-- [[创建背景]]
local CreateBD= function(frame,a)
    frame:SetBackdrop({
        bgFile = C.media.backdrop,   --背景文件
        edgeFile =C.media.backdrop, --区域文件
        edgeSize =1 --区域大小
    })
    frame:SetBackdropColor(0,0,0,a or .5) --背景颜色
    frame:SetBackdropBorderColor(0,0,0) --背景边框样色
end

F.CreateBD = CreateBD

--[[创建背景材质]]
F.CreateBG = function(frame)
    local f = frame
    if frame:GetObjectType()=="Texture" then
        f = frame:GetParent()
    end
    local bg =f:CreateTexture(nil,"BACKGROUND") --创建背景材质
    bg:SetPoint("TOPLEFT",frame,-1,1)
    bg:SetPoint("BOTTOMRIGHT",frame,1,-1)
    bg:SetTexture(C.media.backdrop)
    bg:SetVertexColor(0,0,0)
    return bg
end

--[[创建阴影]]
F.CreateSD = function(parent, size, r, g, b, alpha, offset)
	local sd = CreateFrame("Frame", nil, parent)
	sd.size = size or 4
	sd.offset = offset or -1
	sd:SetBackdrop({
		edgeFile = C.media.glow,
		edgeSize = sd.size,
	})
	sd:SetPoint("TOPLEFT", parent, -sd.size - 0 - sd.offset, sd.size + 0 + sd.offset)
	sd:SetPoint("BOTTOMRIGHT", parent, sd.size + 0 + sd.offset, -sd.size - 0 - sd.offset)
	sd:SetBackdropBorderColor(r or .03, g or .03, b or .03)
	sd:SetAlpha(alpha or .6)
end
--[[创建文字样式]]
F.CreateFS = function(parent, fontSize, justify)
	local f = parent:CreateFontString(nil, "OVERLAY")
	F.SetFS(f, fontSize)

	if justify then f:SetJustifyH(justify) end

	return f
end

--[[设置字体样式]]
F.SetFS = function(fontObject, fontSize)
	local size

	if(not fontSize or fontSize == C.FONT_SIZE_NORMAL) then
		size = C.appearance.fontSizeNormal
	elseif fontSize == C.FONT_SIZE_LARGE then
		size = C.appearance.fontSizeLarge
	elseif fontSize > 4 then -- actual size
		size = fontSize
	end

	local outline = nil
	if C.appearance.fontOutline then
		outline = C.appearance.fontOutlineStyle == 2 and "OUTLINEMONOCHROME" or "OUTLINE"
	end
    -- 字体设置 ： 字体，大小，描边
	fontObject:SetFont(mainFont, size, outline)

	if C.appearance.fontShadow then
		fontObject:SetShadowColor(0, 0, 0)
		fontObject:SetShadowOffset(1, -1)
	else
		fontObject:SetShadowOffset(0, 0)
	end
end

--[[创建脉冲]]
F.CreatePulse = function(frame) -- pulse function originally by nightcracker
	local speed = .05
	local mult = 1
	local alpha = 1
	local last = 0
	frame:SetScript("OnUpdate", function(self, elapsed)
		last = last + elapsed
		if last > speed then
			last = 0
			self:SetAlpha(alpha)
		end
		alpha = alpha - elapsed*mult
		if alpha < 0 and mult > 0 then
			mult = mult*-1
			alpha = 0
		elseif alpha > 1 and mult < 0 then
			mult = mult*-1
		end
	end)
end

local r, g, b = unpack(C.class) --获取职业的三原色

local btnR,btnG,buttonB,btnA=.1,.1,.1,.8

--[[创建梯度渐变]]
local CreateGradient = function(frame)
    local tex = f:CreateTexture(nil,"BORDER")
    tex:SetPoint("TOPLEFT",1-1)
    tex:SetPoint("BOTTOMRIGHT", -1, 1)
	tex:SetTexture(C.media.backdrop)
    tex:SetVertexColor(btnR,btnG,btnB,btnA)
    return tex
end

F.CreateGradient = CreateGradient
--[[按钮发光开始]]
local function StartGlow(f)
	if not f:IsEnabled() then return end
	f:SetBackdropColor(r, g, b, .1)
	f:SetBackdropBorderColor(r, g, b)
end
--[[按钮发光结束]]
local function StopGlow(f)
	f:SetBackdropColor(0, 0, 0, 0)
	f:SetBackdropBorderColor(0, 0, 0)
end

--[[定义皮肤]]
F.Reskin = function(f,noGlow)
    f:SetNormalTexture("")
	f:SetHighlightTexture("")
	f:SetPushedTexture("")
	f:SetDisabledTexture("")

	if f.Left then f.Left:SetAlpha(0) end
	if f.Middle then f.Middle:SetAlpha(0) end
	if f.Right then f.Right:SetAlpha(0) end
	if f.LeftSeparator then f.LeftSeparator:Hide() end
	if f.RightSeparator then f.RightSeparator:Hide() end
    F.CreateBD(f,0)
    f.tex=CreateGradient(f)
    if not noGlow then
        f:HookScript("OnEnter",StartGlow)
        f:HookScript("OnLeave",StopGlow)
    end
end

-- [[定义滚动条皮肤]]

local function SetScroll(f)
    if f:IsEnabled() then
        f.tex:SetVertexColor(r,g,b)
    end
end

local function ClearScroll(f)
    f.tex:SetVertexColor(1,1,1)
end

F.ReskinScroll = function(f,parent)

    -- [[滚动条上中下痕迹。]]
    local frame= f:GetName()
    local track = (f.trackBG or f.Background) or (_G[frame.."Track"] or _G[frame.."BG"])
    if track then track:Hide() end
    local top = (f.ScrollBarTop or f.Top) or _G[frame.."Top"]
    if top then top:Hide() end
    local middle =(f.ScrollBarMiddle or f.Middle) or _G[frame.."Middle"]
    if middle then middle:Hide() end
    local bottom =(f.ScrollBarBottom or f.Bottom) or _G[frame.."Bottom"]
    if bottom then bottom:Hide() end

    local bu = f.ThumbTexture or f.thumbTexture or _G[frame.."ThumbTexture"]
    bu:SetAlpha(0)
    bu:SetWidth(15)

    --设置
    bu.bg = CreateFrame("Frame",nil,f)
    bu.bg:SetPoint("TOPLEFT",bu,0,-2)
    bu.bg:SetPoint("BOTTOMRIGHT", bu, 0, 4)
	F.CreateBD(bu.bg, 0)

    local tex = CreateGradient(f)
    tex:SetPoint("TOPLEFT", bu.bg, 1, -1)
	tex:SetPoint("BOTTOMRIGHT", bu.bg, -1, 1)
    --上 ， 下 按钮
	local up = f.ScrollUpButton or f.UpButton or _G[(frame or parent).."ScrollUpButton"]
	local down = f.ScrollDownButton or f.DownButton or _G[(frame or parent).."ScrollDownButton"]

    up:SetWidth(15)
    down:SetWidth(15)

    F:Reskin(up,true)
    F:Reskin(down,true)

    --设置 上 按钮的材质
    up:SetDisabledTexture(C.media.backdrop)
	local dis1 = up:GetDisabledTexture()
	dis1:SetVertexColor(0, 0, 0, .4)
	dis1:SetDrawLayer("OVERLAY")

    local uptex = up:CreateTexture(nil, "ARTWORK")
	uptex:SetTexture(C.media.arrowUp)
	uptex:SetSize(8, 8)
	uptex:SetPoint("CENTER")
	uptex:SetVertexColor(1, 1, 1)
	up.tex = uptex

    --设置 下 按钮的材质
	down:SetDisabledTexture(C.media.backdrop)
	local dis2 = down:GetDisabledTexture()
	dis2:SetVertexColor(0, 0, 0, .4)
	dis2:SetDrawLayer("OVERLAY")

	local downtex = down:CreateTexture(nil, "ARTWORK")
	downtex:SetTexture(C.media.arrowDown)
	downtex:SetSize(8, 8)
	downtex:SetPoint("CENTER")
	downtex:SetVertexColor(1, 1, 1)
	down.tex = downtex

	up:HookScript("OnEnter", colourScroll)
	up:HookScript("OnLeave", clearScroll)
	down:HookScript("OnEnter", colourScroll)
	down:HookScript("OnLeave", clearScroll)
end

--[[设置箭头皮肤]]

local function SetArrow()
    if f:IsEnabled() then
        f.tex:SetVertexColor(r,g,b)
    end
end

local function ClearArrow()
    f.tex:SetVertexColor(1,1,1)
end

F.SetArrow = SetArrow
F.ClearArrow = ClearArrow

F.ReskinArrow = function(f, direction)
	f:SetSize(20, 20)
	F.Reskin(f, true)

	f:SetDisabledTexture(C.media.backdrop)
	local dis = f:GetDisabledTexture()
	dis:SetVertexColor(0, 0, 0, .3)
	dis:SetDrawLayer("OVERLAY")

	local tex = f:CreateTexture(nil, "ARTWORK")
	tex:SetTexture(mediaPath.texture.."arrow-"..direction.."-active")
	tex:SetSize(8, 8)
	tex:SetPoint("CENTER")
	f.tex = tex

	f:HookScript("OnEnter", colourArrow)
	f:HookScript("OnLeave", clearArrow)
end


--[[下拉列表皮肤]]
F.ReskinDropDown = function (f)
    local frame = f:GetName()
    local left = _G[frame.."Left"]
	local middle = _G[frame.."Middle"]
	local right = _G[frame.."Right"]

	if left then left:SetAlpha(0) end
	if middle then middle:SetAlpha(0) end
	if right then right:SetAlpha(0) end


    local bg = CreateFrame("Frame", nil, f)
	bg:SetPoint("TOPLEFT", 10, -4)
	bg:SetPoint("BOTTOMRIGHT", -12, 8)
	bg:SetFrameLevel(f:GetFrameLevel()-1)
	F.CreateBD(bg, 0)

	local gradient = F.CreateGradient(f)
	gradient:SetPoint("TOPLEFT", bg, 1, -1)
	gradient:SetPoint("BOTTOMRIGHT", bg, -1, 1)

	local down = _G[frame.."Button"]

	down:SetSize(20, 20)
	down:ClearAllPoints()
	down:SetPoint("TOPRIGHT", bg)

	F.Reskin(down, true)

	down:SetDisabledTexture(C.media.backdrop)
	local dis = down:GetDisabledTexture()
	dis:SetVertexColor(0, 0, 0, .4)
	dis:SetDrawLayer("OVERLAY")
	dis:SetAllPoints()

	local tex = down:CreateTexture(nil, "ARTWORK")
	tex:SetTexture(C.media.arrowDown)
	tex:SetSize(8, 8)
	tex:SetPoint("CENTER")
	tex:SetVertexColor(1, 1, 1)
	down.tex = tex

	down:HookScript("OnEnter", SetArrow)
	down:HookScript("OnLeave", ClearArrow)
end


--[[设置关闭按钮皮肤]]

local function SetClose(f)
	if f:IsEnabled() then
		for _, pixel in pairs(f.pixels) do
			pixel:SetColorTexture(r, g, b)
		end
	end
end

local function ClearClose(f)
	for _, pixel in pairs(f.pixels) do
		pixel:SetColorTexture(1, 1, 1)
	end
end

F.ReskinClose = function(f, a1, p, a2, x, y)
	f:SetSize(20, 20)

	if a1 then
		f:ClearAllPoints()
		f:SetPoint(a1, p, a2, x, y)
	else
		f:SetPoint("TOPRIGHT", -4, -4)
	end

	f:SetNormalTexture("")
	f:SetHighlightTexture("")
	f:SetPushedTexture("")
	f:SetDisabledTexture("")

	F.CreateBD(f, 0)

	CreateGradient(f)

	f:SetDisabledTexture(C.media.backdrop)
	local dis = f:GetDisabledTexture()
	dis:SetVertexColor(0, 0, 0, .4)
	dis:SetDrawLayer("OVERLAY")
	dis:SetAllPoints()

	f.pixels = {}

	local lineOfs = 2.5
	for i = 1, 2 do
		local line = f:CreateLine()
		line:SetColorTexture(1, 1, 1)
		line:SetThickness(0.5)
		if i == 1 then
			line:SetStartPoint("TOPLEFT", lineOfs, -lineOfs)
			line:SetEndPoint("BOTTOMRIGHT", -lineOfs, lineOfs)
		else
			line:SetStartPoint("TOPRIGHT", -lineOfs, -lineOfs)
			line:SetEndPoint("BOTTOMLEFT", lineOfs, lineOfs)
		end
		tinsert(f.pixels, line)
	end

	f:HookScript("OnEnter", SetClose)
	f:HookScript("OnLeave", ClearClose)
end

--[[设置输入框皮肤]]
F.ReskinInput = function(f, height, width)
	local frame = f:GetName()

	local left = f.Left or _G[frame.."Left"]
	local middle = f.Middle or _G[frame.."Middle"] or _G[frame.."Mid"]
	local right = f.Right or _G[frame.."Right"]

	left:Hide()
	middle:Hide()
	right:Hide()

	local bd = CreateFrame("Frame", nil, f)
	bd:SetPoint("TOPLEFT", -2, 0)
	bd:SetPoint("BOTTOMRIGHT")
	bd:SetFrameLevel(f:GetFrameLevel()-1)
	F.CreateBD(bd, 0)

	local gradient = CreateGradient(f)
	gradient:SetPoint("TOPLEFT", bd, 1, -1)
	gradient:SetPoint("BOTTOMRIGHT", bd, -1, 1)

	if height then f:SetHeight(height) end
	if width then f:SetWidth(width) end
end

--[[设置多选样式]]
F.ReskinCheck = function(f)
	f:SetNormalTexture("")
	f:SetPushedTexture("")
	f:SetHighlightTexture(C.media.texture)
	local hl = f:GetHighlightTexture()
	hl:SetPoint("TOPLEFT", 5, -5)
	hl:SetPoint("BOTTOMRIGHT", -5, 5)
	hl:SetVertexColor(r, g, b, .2)

	local bd = CreateFrame("Frame", nil, f)
	bd:SetPoint("TOPLEFT", 4, -4)
	bd:SetPoint("BOTTOMRIGHT", -4, 4)
	bd:SetFrameLevel(f:GetFrameLevel()-1)
	F.CreateBD(bd, 0)

	local tex = CreateGradient(f)
	tex:SetPoint("TOPLEFT", 5, -5)
	tex:SetPoint("BOTTOMRIGHT", -5, 5)

	local ch = f:GetCheckedTexture()
	ch:SetDesaturated(true)
	ch:SetVertexColor(r, g, b)
end


--[[设置单选按钮皮肤]]

local function SetRadio(f)
	f.bd:SetBackdropBorderColor(r, g, b)
end

local function ClearRadio(f)
	f.bd:SetBackdropBorderColor(0, 0, 0)
end

F.ReskinRadio = function(f)
	f:SetNormalTexture("")
	f:SetHighlightTexture("")
	f:SetCheckedTexture(C.media.texture)

	f:SetDisabledCheckedTexture(C.media.backdrop)

	local ch = f:GetCheckedTexture()
	ch:SetPoint("TOPLEFT", 4, -4)
	ch:SetPoint("BOTTOMRIGHT", -4, 4)
	ch:SetVertexColor(r, g, b, .6)

	local dch = f:GetDisabledCheckedTexture()
	dch:SetPoint("TOPLEFT", 4, -4)
	dch:SetPoint("BOTTOMRIGHT", -4, 4)
	dch:SetVertexColor(.7, .7, .7, .6)

	local bd = CreateFrame("Frame", nil, f)
	bd:SetPoint("TOPLEFT", 3, -3)
	bd:SetPoint("BOTTOMRIGHT", -3, 3)
	bd:SetFrameLevel(f:GetFrameLevel()-1)
	F.CreateBD(bd, 0)
	f.bd = bd

	local tex = F.CreateGradient(f)
	tex:SetPoint("TOPLEFT", 4, -4)
	tex:SetPoint("BOTTOMRIGHT", -4, 4)

	f:HookScript("OnEnter", SetRadio)
	f:HookScript("OnLeave", ClearRadio)
end



--[[设置滑动条样式]]
F.ReskinSlider = function(f)
	f:SetBackdrop(nil)
	f.SetBackdrop = F.dummy

	local bd = CreateFrame("Frame", nil, f)
	bd:SetPoint("TOPLEFT", 14, -2)
	bd:SetPoint("BOTTOMRIGHT", -15, 3)
	bd:SetFrameStrata("BACKGROUND")
	bd:SetFrameLevel(f:GetFrameLevel()-1)
	F.CreateBD(bd, 0)

	CreateGradient(bd)

	local slider = select(4, f:GetRegions())
	slider:SetTexture(C.media.slider)
	slider:SetBlendMode("ADD")
end



--[[设置折叠面板]]


local function SetExpandOrCollapse(f)
	if f:IsEnabled() then
		f.plus:SetVertexColor(r, g, b)
		f.minus:SetVertexColor(r, g, b)
	end
end

local function ClearExpandOrCollapse(f)
	f.plus:SetVertexColor(1, 1, 1)
	f.minus:SetVertexColor(1, 1, 1)
end

F.SetExpandOrCollapse = SetExpandOrCollapse
F.ClearExpandOrCollapse = ClearExpandOrCollapse

F.ReskinExpandOrCollapse = function(f)
	f:SetSize(13, 13)

	F.Reskin(f, true)
	f.SetNormalTexture = F.dummy

	f.minus = f:CreateTexture(nil, "OVERLAY")
	f.minus:SetSize(7, 1)
	f.minus:SetPoint("CENTER")
	f.minus:SetTexture(C.media.backdrop)
	f.minus:SetVertexColor(1, 1, 1)

	f.plus = f:CreateTexture(nil, "OVERLAY")
	f.plus:SetSize(1, 7)
	f.plus:SetPoint("CENTER")
	f.plus:SetTexture(C.media.backdrop)
	f.plus:SetVertexColor(1, 1, 1)

	f:HookScript("OnEnter", SetExpandOrCollapse)
	f:HookScript("OnLeave", ClearExpandOrCollapse)
end

--[[设置背景]]
F.SetBD = function(f, x, y, x2, y2)
	local bg = CreateFrame("Frame", nil, f)
	if not x then
		bg:SetPoint("TOPLEFT")
		bg:SetPoint("BOTTOMRIGHT")
	else
		bg:SetPoint("TOPLEFT", x, y)
		bg:SetPoint("BOTTOMRIGHT", x2, y2)
	end
	bg:SetFrameLevel(f:GetFrameLevel()-1)
	F.CreateBD(bg)
	F.CreateSD(bg)
end

--[[设置肖像框皮肤]]
F.ReskinPortraitFrame = function(f, isButtonFrame)
	local name = f:GetName()

	f.Bg:Hide()
	_G[name.."TitleBg"]:Hide()
	f.portrait:Hide()
	f.portraitFrame:Hide()
	_G[name.."TopRightCorner"]:Hide()
	f.topLeftCorner:Hide()
	f.topBorderBar:Hide()
	f.TopTileStreaks:SetTexture("")
	_G[name.."BotLeftCorner"]:Hide()
	_G[name.."BotRightCorner"]:Hide()
	_G[name.."BottomBorder"]:Hide()
	f.leftBorderBar:Hide()
	_G[name.."RightBorder"]:Hide()

	F.ReskinClose(f.CloseButton)
	f.portrait.Show = F.dummy

	if isButtonFrame then
		_G[name.."BtnCornerLeft"]:SetTexture("")
		_G[name.."BtnCornerRight"]:SetTexture("")
		_G[name.."ButtonBottomBorder"]:SetTexture("")

		f.Inset.Bg:Hide()
		f.Inset:DisableDrawLayer("BORDER")
	end

	F.CreateBD(f)
	F.CreateSD(f)
end


--[[创建背景框架]]
F.CreateBDFrame = function(f, a)
	local frame
	if f:GetObjectType() == "Texture" then
		frame = f:GetParent()
	else
		frame = f
	end

	local lvl = frame:GetFrameLevel()

	local bg = CreateFrame("Frame", nil, frame)
	bg:SetPoint("TOPLEFT", f, -1, 1)
	bg:SetPoint("BOTTOMRIGHT", f, 1, -1)
	bg:SetFrameLevel(lvl == 0 and 1 or lvl - 1)

	CreateBD(bg, a or .5)

	return bg
end

--[[设置颜色拾取器皮肤]]
F.ReskinColourSwatch = function(f)
	local name = f:GetName()

	local bg = _G[name.."SwatchBg"]

	f:SetNormalTexture(C.media.backdrop)
	local nt = f:GetNormalTexture()

	nt:SetPoint("TOPLEFT", 3, -3)
	nt:SetPoint("BOTTOMRIGHT", -3, 3)

	bg:SetColorTexture(0, 0, 0)
	bg:SetPoint("TOPLEFT", 2, -2)
	bg:SetPoint("BOTTOMRIGHT", -2, 2)
end

--[[设置过滤按钮皮肤]]
F.ReskinFilterButton = function(f)
	f.TopLeft:Hide()
	f.TopRight:Hide()
	f.BottomLeft:Hide()
	f.BottomRight:Hide()
	f.TopMiddle:Hide()
	f.MiddleLeft:Hide()
	f.MiddleRight:Hide()
	f.BottomMiddle:Hide()
	f.MiddleMiddle:Hide()

	F.Reskin(f)
	f.Icon:SetTexture(C.media.arrowRight)

	f.Text:SetPoint("CENTER")
	f.Icon:SetPoint("RIGHT", f, "RIGHT", -5, 0)
	f.Icon:SetSize(8, 8)
end


--[[设置导航皮肤]]
F.ReskinNavBar = function(f)
	local overflowButton = f.overflowButton

	f:GetRegions():Hide()
	f:DisableDrawLayer("BORDER")
	f.overlay:Hide()
	f.homeButton:GetRegions():Hide()

	F.Reskin(f.homeButton)
	F.Reskin(overflowButton, true)

	local tex = overflowButton:CreateTexture(nil, "ARTWORK")
	tex:SetTexture(C.media.arrowLeft)
	tex:SetSize(8, 8)
	tex:SetPoint("CENTER")
	overflowButton.tex = tex

	overflowButton:HookScript("OnEnter", SetArrow)
	overflowButton:HookScript("OnLeave", ClearArrow)
end


--[[设置要塞报告皮肤]]
F.ReskinGarrisonPortrait = function(portrait)
	portrait:SetSize(portrait.Portrait:GetSize())
	F.CreateBD(portrait, 1)

	portrait.Portrait:ClearAllPoints()
	portrait.Portrait:SetPoint("TOPLEFT")

	portrait.PortraitRing:Hide()
	portrait.PortraitRingQuality:SetTexture("")
	portrait.PortraitRingCover:SetTexture("")
 	portrait.LevelBorder:SetAlpha(0)

	local lvlBG = portrait:CreateTexture(nil, "BORDER")
 	lvlBG:SetColorTexture(0, 0, 0, 0.5)
 	lvlBG:SetPoint("TOPLEFT", portrait, "BOTTOMLEFT", 1, 12)
 	lvlBG:SetPoint("BOTTOMRIGHT", portrait, -1, 1)

 	local level = portrait.Level
	level:ClearAllPoints()
	level:SetPoint("CENTER", lvlBG)
end

--[[设置图标皮肤]]
F.ReskinIcon = function(icon)
	icon:SetTexCoord(.08, .92, .08, .92)
	return F.CreateBG(icon)
end

local msg = {
    ["title"]="ThinKrUI |cffffffff"..GetAddOnMetadata("ThinKrUI", "Version"),
    ["cmd"]="|cffffffff输入|r /tkui |cffffffff打开设置界面|r",
    ["qq"]="|cffffffff获取更多信息联系QQ 133302599"
}
DEFAULT_CHAT_FRAME:AddMessage(msg.title, unpack(C.class))
DEFAULT_CHAT_FRAME:AddMessage(msg.cmd, unpack(C.class))
DEFAULT_CHAT_FRAME:AddMessage(msg.qq, unpack(C.class))
