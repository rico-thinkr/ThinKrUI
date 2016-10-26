local F, C = unpack(ThinKrUI)

if not C.notifications.enable then return end

local playSounds = C.notifications.playSounds
local animations = C.notifications.animations
local timeShown = C.notifications.timeShown

F.AddOptionsCallback("notifications", "playSounds", function()
	playSounds = C.notifications.playSounds
end)

F.AddOptionsCallback("notifications", "animations", function()
	animations = C.notifications.animations
end)

F.AddOptionsCallback("notifications", "timeShown", function()
	timeShown = C.notifications.timeShown
end)

local bannerWidth = 440
local interval = 0.1

-- Create frame and stuff

local f = CreateFrame("Frame", "ThinKrUINotifications", UIParent)
f:SetFrameStrata("FULLSCREEN_DIALOG")
f:SetSize(bannerWidth, 50)
f:SetPoint("TOP", UIParent, "TOP")
f:Hide()
f:SetAlpha(0.1)
f:SetScale(0.1)
F.CreateBD(f)

local icon = f:CreateTexture(nil, "OVERLAY")
icon:SetSize(32, 32)
icon:SetPoint("LEFT", f, "LEFT", 9, 0)
F.CreateBG(icon)

local sep = f:CreateTexture(nil, "BACKGROUND")
sep:SetSize(1, 50)
sep:SetPoint("LEFT", icon, "RIGHT", 9, 0)
sep:SetColorTexture(0, 0, 0)

local title = f:CreateFontString(nil, "OVERLAY")
title:SetFont(C.media.font2, 14)
title:SetShadowOffset(1, -1)
title:SetPoint("TOPLEFT", sep, "TOPRIGHT", 9, -9)
title:SetPoint("RIGHT", f, -9, 0)
title:SetJustifyH("LEFT")

local text = f:CreateFontString(nil, "OVERLAY")
text:SetFont(C.media.font2, 12)
text:SetShadowOffset(1, -1)
text:SetPoint("BOTTOMLEFT", sep, "BOTTOMRIGHT", 9, 9)
text:SetPoint("RIGHT", f, -9, 0)
text:SetJustifyH("LEFT")

-- Banner show/hide animations

local bannerShown = false

local function hideBanner()
	if animations then
		local scale
		f:SetScript("OnUpdate", function(self)
			scale = self:GetScale() - interval
			if scale <= 0.1 then
				self:SetScript("OnUpdate", nil)
				self:Hide()
				bannerShown = false
				return
			end
			self:SetScale(scale)
			self:SetAlpha(scale)
		end)
	else
		f:Hide()
		f:SetScale(0.1)
		f:SetAlpha(0.1)
		bannerShown = false
	end
end

local function fadeTimer()
	local last = 0
	f:SetScript("OnUpdate", function(self, elapsed)
		local width = f:GetWidth()
		if width > bannerWidth then
			self:SetWidth(width - (interval*100))
		end
		last = last + elapsed
		if last >= timeShown then
			self:SetWidth(bannerWidth)
			self:SetScript("OnUpdate", nil)
			hideBanner()
		end
	end)
end

local function showBanner()
	bannerShown = true
	if animations then
		f:Show()
		local scale
		f:SetScript("OnUpdate", function(self)
			scale = self:GetScale() + interval
			self:SetScale(scale)
			self:SetAlpha(scale)
			if scale >= 1 then
				self:SetScale(1)
				self:SetScript("OnUpdate", nil)
				fadeTimer()
			end
		end)
	else
		f:SetScale(1)
		f:SetAlpha(1)
		f:Show()
		fadeTimer()
	end
end

-- Display a notification

local function display(name, message, clickFunc, texture, ...)
	if type(clickFunc) == "function" then
		f.clickFunc = clickFunc
	else
		f.clickFunc = nil
	end

	if type(texture) == "string" then
		icon:SetTexture(texture)

		if ... then
			icon:SetTexCoord(...)
		else
			icon:SetTexCoord(.08, .92, .08, .92)
		end
	else
		icon:SetTexture("Interface\\Icons\\achievement_general")
		icon:SetTexCoord(.08, .92, .08, .92)
	end

	title:SetText(name)
	text:SetText(message)

	showBanner()

	if playSounds then
		PlaySoundFile("Interface\\AddOns\\ThinKrUI\\media\\sound.mp3")
	end
end

-- Handle incoming notifications

local handler = CreateFrame("Frame")
local incoming = {}
local processing = false

local function handleIncoming()
	processing = true
	local i = 1

	handler:SetScript("OnUpdate", function(self)
		if incoming[i] == nil then
			self:SetScript("OnUpdate", nil)
			incoming = {}
			processing = false
			return
		else
			if not bannerShown then
				display(unpack(incoming[i]))
				i = i + 1
			end
		end
	end)
end

handler:SetScript("OnEvent", function(self, _, unit)
	if unit == "player" and not UnitIsAFK("player") then
		handleIncoming()
		self:UnregisterEvent("PLAYER_FLAGS_CHANGED")
	end
end)

-- The API show function

F.Notification = function(name, message, clickFunc, texture, ...)
	if UnitIsAFK("player") then
		tinsert(incoming, {name, message, clickFunc, texture, ...})
		handler:RegisterEvent("PLAYER_FLAGS_CHANGED")
	elseif bannerShown or #incoming ~= 0 then
		tinsert(incoming, {name, message, clickFunc, texture, ...})
		if not processing then
			handleIncoming()
		end
	else
		display(name, message, clickFunc, texture, ...)
	end
end

-- Mouse events

local function expand(self)
	local width = self:GetWidth()

	if text:IsTruncated() and width < (GetScreenWidth() / 1.5) then
		self:SetWidth(width+(interval*100))
	else
		self:SetScript("OnUpdate", nil)
	end
end

f:SetScript("OnEnter", function(self)
	self:SetScript("OnUpdate", nil)
	self:SetScale(1)
	self:SetAlpha(1)
	self:SetScript("OnUpdate", expand)
end)

f:SetScript("OnLeave", fadeTimer)

f:SetScript("OnMouseUp", function(self, button)
	self:SetScript("OnUpdate", nil)
	self:Hide()
	self:SetScale(0.1)
	self:SetAlpha(0.1)
	bannerShown = false
	-- right click just hides the banner
	if button ~= "RightButton" and f.clickFunc then
		f.clickFunc()
	end

	-- dismiss all
	if IsShiftKeyDown() then
		handler:SetScript("OnUpdate", nil)
		incoming = {}
		processing = false
	end
end)
