-----------------------------------------------------------
-- Sindragosa
--
local mod = BigWigs:NewBoss("Sindragosa", "Icecrown Citadel")
if not mod then return end

-- Sindragosa, Rimefang, Spinestalker
mod:RegisterEnableMob(36853, 37533, 37534)
mod.toggleOptions = {
	"airphase",
	"phase2",
	70127,
	{69762, "FLASHSHAKE"},
	69766,
	70106,
	71047,
	{70126, "FLASHSHAKE"},
	"proximity",
	"berserk",
	"bosskill"
}
local CL = LibStub("AceLocale-3.0"):GetLocale("Big Wigs: Common")
mod.optionHeaders = {
	airphase = CL.phase:format(1),
	phase2 = CL.phase:format(2),
	[69762] = "general"
}

local beaconTargets = mod:NewTargetList()
local engage_trigger = "You are fools to have come to this place."
local phase2_trigger = "Now, feel my master's limitless power and despair!"
local airphase_trigger = "Your incursion ends here! None shall survive!"

local L = mod:NewLocale("enUS", true)
if L then
	L.engage_trigger = engage_trigger

	L.phase2 = "Phase 2"
	L.phase2_desc = "Warn when Sindragosa goes into phase 2, at 35%."
	L.phase2_trigger = phase2_trigger
	L.phase2_message = "Phase 2!"

	L.airphase = "Air phase"
	L.airphase_desc = "Warn when Sindragosa will lift off."
	L.airphase_trigger = airphase_trigger
	L.airphase_message = "Air phase!"
	L.airphase_bar = "Next air phase"

	L.boom_message = "Explosion!"
	L.boom_bar = "Explosion"

	L.grip_bar = "Next Icy Grip"

	L.unchained_message = "Unchained magic on YOU!"
	L.unchained_bar = "Unchained Magic"
	L.instability_message = "Unstable x%d!"
	L.chilled_message = "Chilled x%d!"
	L.buffet_message = "Magic x%d!"
	L.buffet_cd = "Next Magic"
end
L = mod:GetLocale()

function mod:OnBossEnable()
	self:Log("SPELL_AURA_APPLIED", "Unchained", 69762)
	self:Log("SPELL_AURA_REMOVED", "UnchainedRemoved", 69762)
	self:Log("SPELL_AURA_APPLIED_DOSE", "Instability", 69766)
	self:Log("SPELL_AURA_APPLIED_DOSE", "Chilled", 70106)
	self:Log("SPELL_AURA_APPLIED_DOSE", "Buffet", 70127, 72528, 72529, 72530)

	self:Log("SPELL_AURA_APPLIED", "FrostBeacon", 70126)
	self:Log("SPELL_AURA_REMOVED", "SafeBeacon", 70126)
	self:Log("SPELL_AURA_APPLIED", "Tombed", 70157)

	-- 70123, 71047, 71048, 71049 is the actual blistering cold
	self:Log("SPELL_CAST_SUCCESS", "Grip", 70117)

	self:RegisterEvent("PLAYER_REGEN_ENABLED", "CheckForWipe")
	self:Yell("Warmup", L["engage_trigger"], engage_trigger)
	self:Yell("AirPhase", L["airphase_trigger"], airphase_trigger)
	self:Yell("Phase2", L["phase2_trigger"], phase2_trigger)
	self:Death("Win", 36853)
end

function mod:Warmup()
	self:Bar("berserk", self.displayName, 10, "achievement_boss_sindragosa")
	self:ScheduleTimer(self.Engage, 10, self)
end

function mod:OnEngage()
	self:SetPhase(1)
	self:Berserk(600)
	self:Voice(70117, -1, 26)
	self:Bar(69762, L["unchained_bar"], random(9, 14), 69762)
	self:Bar(71047, L["grip_bar"], 33.5, 70117)
	self:Bar("airphase", L["airphase_bar"], 50, 23684)
end

function mod:Tombed(player)
	if UnitIsUnit(player, "player") then
		self:CloseProximity()
	end
end

do
	local scheduled, current = nil, 0
	local function baconWarn(spellName)
		mod:TargetMessage(70126, spellName, beaconTargets, "Urgent", 70126)
		mod:Bar(70126, spellName, 7, 70126)
		scheduled = nil
	end
	function mod:FrostBeacon(player, spellId, _, _, spellName)
		beaconTargets[#beaconTargets + 1] = player
		-- mark the player:
		current = current + 1
		SetRaidTarget(player, current)

		local max, diff = 2, GetInstanceDifficulty()
		if diff == 4 then -- 25hc
			max = 6
		elseif diff == 2 then -- 25nm
			max = 5
		end

		if UnitIsUnit(player, "player") then
			self:Voice(70126, true)
			self:Voice(70126, 0, 1.5)
			self:OpenProximity(10)
			self:FlashShake(70126)

			if max == 2 then
				self:Voice(current == 1 and "moveleft" or "moveright", -1, 1.5)
			elseif max == 5 then
				if current < 3 then
					self:Voice("moveleft", -1, 1.5)
				elseif current > 3 then
					self:Voice("moveright", -1, 1.5)
				else
					self:Voice("movecenter", -1, 1.5)
				end
			elseif max == 6 then
				if current < 3 then
					self:Voice("moveleft", -1, 1.5)
				elseif current > 4 then
					self:Voice("moveright", -1, 1.5)
				else
					self:Voice("movecenter", -1, 1.5)
				end
			end
		end

		-- reset when reaching the max
		if current == max then
			current = 0
		end

		if not scheduled then
			scheduled = true
			self:ScheduleTimer(baconWarn, 0.2, spellName)
		end
	end

	-- remove icons from players
	function mod:SafeBeacon(player)
		SetRaidTarget(player, 0)
	end
end

function mod:Grip()
	self:Voice("runaway")
	self:Message(71047, L["boom_message"], "Important", 71047, "Alarm")
	self:Bar(71047, L["boom_bar"], 5, 71047)
	if self.phase == 2 then
		self:Voice(70117, -1, 60)
		self:Bar(71047, L["grip_bar"], 67, 70117)
	end
end

function mod:AirPhase()
	self:Message("airphase", L["airphase_message"], "Positive")
	self:Bar("airphase", L["airphase_bar"], 110, 23684)
	self:Bar(71047, L["grip_bar"], 80, 70117)
	self:Bar(69762, L["unchained_bar"], 57, 69762)
end

function mod:Phase2()
	self:SetPhase(2)
	self:Voice("phase2")
	self:SendMessage("BigWigs_StopBar", self, L["airphase_bar"])
	self:Message("phase2", L["phase2_message"], "Positive", nil, "Long")
	self:Bar(71047, L["grip_bar"], 38, 70117)
end

function mod:Buffet(player, spellId, _, _, _, stack)
	self:Bar(70127, L["buffet_cd"], 6, 70127)
	if (stack % 2 == 0) and UnitIsUnit(player, "player") then
		self:LocalMessage(70127, L["buffet_message"]:format(stack), "Attention", spellId, "Info")
	end
end

function mod:Instability(player, spellId, _, _, _, stack)
	if stack >= 4 and UnitIsUnit(player, "player") and self.phase ~= 2 then
		self:Voice(69766, true)
		self:LocalMessage(69766, L["instability_message"]:format(stack), "Personal", spellId)
	end
end

function mod:Chilled(player, spellId, _, _, _, stack)
	if stack >= 6 and UnitIsUnit(player, "player") then
		if stack % 3 == 0 then
			self:Voice(70106, true)
		end
		self:LocalMessage(70106, L["chilled_message"]:format(stack), "Personal", spellId)
	end
end

function mod:Unchained(player, spellId)
	if self.phase == 1 then
		self:Bar(69762, L["unchained_bar"], random(30, 35), spellId)
	elseif self.phase == 2 then
		self:Bar(69762, L["unchained_bar"], 80, spellId)
	end
	if UnitIsUnit(player, "player") then
		self:LocalMessage(69762, L["unchained_message"], "Personal", spellId, "Alert")
		self:FlashShake(69762)
		if self:GetInstanceDifficulty() > 2 then
			self:Voice(69762)
			self:OpenProximity(20)
			self:ScheduleTimer(self.CloseProximity, 30, self)
		else
			self:Voice(69762, true)
		end
	end
end

function mod:UnchainedRemoved(player, spellId)
	self:CloseProximity()
end