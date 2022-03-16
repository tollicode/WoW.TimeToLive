local startDrag = function(frame) if IsAltKeyDown() then frame:StartMoving() end end
local stopDrag = function(frame) frame:StopMovingOrSizing() end

local UnitHealth = UnitHealth

TTLTargetBar, TTLFocusBar, TTLElvUI = ...

local previousHealthTicks = queue.new()

local function addHealthTick(hp)
	previousHealthTicks:push(hp)

	if (previousHealthTicks:len() > 5) then
		previousHealthTicks:pop();
	end
end

local function getDpsAverage()
	local totalDamage = 0;
	totalDamage = totalDamage + (previousHealthTicks.list[5] - previousHealthTicks.list[4])
	totalDamage = totalDamage + (previousHealthTicks.list[4] - previousHealthTicks.list[3])
	totalDamage = totalDamage + (previousHealthTicks.list[3] - previousHealthTicks.list[2])
	totalDamage = totalDamage + (previousHealthTicks.list[2] - previousHealthTicks.list[1])
	if (totalDamage >= 0) then
		return 0
	end

	local averageDamage = totalDamage / 5
	return -1 * averageDamage

end

local function showBlank()
	TTLFocusBar:SetText("")
	TTLTargetBar:SetText("")
	if (TTLElvUI ~= nil) then
		TTLElvUI:SetText("")
	end
end

C_Timer.NewTicker(1, function()
	if (UnitAffectingCombat("player") == false) then
		return
	end
	-- Add current health of enemy to previous tickss
	local hp = UnitHealth("target")
	if (hp == 0) then
		showBlank()
		return;
	end
	addHealthTick(hp)

	if (previousHealthTicks:len() == 5) then
		local dpsAverage = getDpsAverage();
		if (dpsAverage == 0) then
			showBlank()
		end
		local secondsToKill = hp / dpsAverage;
		if (secondsToKill > 3600) then
			showBlank()
		else
			local minutes = secondsToKill / 60;
			local seconds = secondsToKill - (math.floor(minutes) * 60);
			if (math.floor(minutes) > 0) then
				TTLFocusBar:SetFormattedText("%1dm %1ds", minutes, seconds)
				TTLTargetBar:SetFormattedText("%1dm %1ds", minutes, seconds)
				if (TTLElvUI ~= nil) then
					TTLElvUI:SetFormattedText("%1dm %1ds", minutes, seconds)
				end
			else
				TTLFocusBar:SetFormattedText("%1ds", seconds)
				TTLTargetBar:SetFormattedText("%1ds", seconds)
				if (TTLElvUI ~= nil) then
					TTLElvUI:SetFormattedText("%1ds", seconds)
				end
			end
			
		end
		
	end
end)

local function clearHistory(event)
	local hp = UnitHealth("target")

	previousHealthTicks = queue.new();
	for i=1,5 do
		previousHealthTicks:push(hp)
	end
end

local target = CreateFrame("Frame", "FocusTTL", TargetFrameHealthBar)
target:SetPoint("LEFT", TargetFrameHealthBar, "LEFT", -51, -12)
target:SetWidth(50)
target:SetHeight(20)
target:EnableMouse(true)
target:RegisterForDrag("LeftButton")
target:SetClampedToScreen(true)
target:SetMovable(true)
target:SetScript("OnDragStart", startDrag)
target:SetScript("OnDragStop", stopDrag)
target.unit = "target"
TTLTargetBar = target:CreateFontString(nil, nil, "TextStatusBarText")
TTLTargetBar:SetAllPoints(target)
TTLTargetBar:SetJustifyH("RIGHT")

local target2 = CreateFrame("Frame", "FocusTTL", TargetFrameHealthBar)
target2:RegisterEvent("PLAYER_TARGET_CHANGED")
target2:SetScript("OnEvent", clearHistory)

local focus = CreateFrame("Frame", "FocusTTL", FocusFrameHealthBar)
focus:SetPoint("LEFT", FocusFrameHealthBar, "LEFT", -51, -12)
focus:SetWidth(50)
focus:SetHeight(20)
focus:EnableMouse(true)
focus:RegisterForDrag("LeftButton")
focus:SetClampedToScreen(true)
focus:SetMovable(true)
focus:SetScript("OnDragStart", startDrag)
focus:SetScript("OnDragStop", stopDrag)
focus.unit = "focus"
TTLFocusBar = focus:CreateFontString(nil, nil, "TextStatusBarText")
TTLFocusBar:SetAllPoints(focus)
TTLFocusBar:SetJustifyH("RIGHT")

local name, title, notes, enabled, loadable, reason, security = GetAddOnInfo("ElvUI")
if (name ~= nil) then
	local MonitorTargetFrame = CreateFrame("Frame", "MonitorTargetFrame", UIParent)
	MonitorTargetFrame:RegisterEvent("PLAYER_TARGET_CHANGED");
	MonitorTargetFrame:HookScript("OnEvent", function()
		if (loadable ~= "MISSING" or enabled == false) then
			return
		end
		local elvUIFrame = CreateFrame("Frame", nil, ElvUF_Target)
		elvUIFrame:SetPoint("LEFT", ElvUF_Target, "LEFT", -50, 0)
		elvUIFrame:SetWidth(50)
		elvUIFrame:SetHeight(20)
		elvUIFrame:EnableMouse(true)
		elvUIFrame:RegisterForDrag("LeftButton")
		elvUIFrame:SetClampedToScreen(true)
		elvUIFrame:SetMovable(true)
		elvUIFrame:SetScript("OnDragStart", startDrag)
		elvUIFrame:SetScript("OnDragStop", stopDrag)
		elvUIFrame.unit = "focus"
		TTLElvUI = elvUIFrame:CreateFontString(nil, nil, "TextStatusBarText")
		TTLElvUI:SetAllPoints(elvUIFrame)
		TTLElvUI:SetJustifyH("RIGHT")
		TTLElvUI:SetText("")
	end)
end