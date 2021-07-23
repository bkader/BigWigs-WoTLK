-----------------------------------------------------------
-- Lady Deathwhisper
--

local mod = BigWigs:NewBoss("Lady Deathwhisper", "Icecrown Citadel")
if not mod then return end

mod:RegisterEnableMob(36855, 37949, 38010, 37890, 38009, 38135)
mod.toggleOptions = {"adds", 70842, 71204, 71426, 71289, {71001, "FLASHSHAKE"}, "berserk", "bosskill"}

local CL = LibStub("AceLocale-3.0"):GetLocale("Big Wigs: Common")
mod.optionHeaders = {
	adds = CL.phase:format(1),
	[71204] = CL.phase:format(2),
	[71289] = "general"
}

local handle_Adds = nil
local dmTargets = mod:NewTargetList()

local L = mod:NewLocale("enUS", true)
if L then
	L.engage_trigger = "What is this disturbance?"
	L.phase2_message = "Barrier DOWN - Phase 2!"

	L.dnd_message = "Death and Decay on YOU!"
	L.dnd_bar = "Next Death and Decay"

	L.adds = "Adds"
	L.adds_desc = "Show timers for when the adds spawn."
	L.adds_bar = "Next Adds"
	L.adds_warning = "New adds in 5 sec!"

	L.touch_message = "%2$dx Touch on %1$s"
	L.touch_bar = "Next Touch"

	L.deformed_fanatic = "Deformed Fanatic!"

	L.spirit_message = "Summon Spirit!"
	L.spirit_bar = "Next Spirit"

	L.dominate_bar = "~Next Dominate Mind"
end
L = mod:GetLocale()

function mod:OnBossEnable()
	self:Log("SPELL_AURA_APPLIED", "DnD", 71001, 72108, 72109, 72110) --??, 25, ??, ??
	self:Log("SPELL_AURA_REMOVED", "Barrier", 70842)
	self:Log("SPELL_AURA_APPLIED", "DominateMind", 71289)
	self:Log("SPELL_AURA_APPLIED", "Touch", 71204)
	self:Log("SPELL_AURA_APPLIED_DOSE", "Touch", 71204)
	self:Log("SPELL_CAST_START", "Deformed", 70900)
	self:Log("SPELL_SUMMON", "Spirit", 71426)
	self:Death("Win", 36855)

	self:RegisterEvent("PLAYER_REGEN_ENABLED", "CheckForWipe")
	self:Yell("Engage", L["engage_trigger"])
end

local function adds(seconds)
	mod:Voice("adds", -1, seconds - 10)
	mod:DelayedMessage("adds", seconds - 5, L["adds_warning"], "Attention")
	mod:Bar("adds", L["adds_bar"], seconds, 70768)
	handle_Adds = mod:ScheduleTimer(adds, seconds, seconds)
end

function mod:OnEngage(diff)
	self:Berserk(600)
	self:Bar("adds", L["adds_bar"], 7, 70768)
	self:Bar(71001, L["dnd_bar"], 12, 71001)
	if diff > 1 then
		self:Voice(71289, -1, 20)
		self:Bar(71289, L["dominate_bar"], 27, 71289)
	end
	handle_Adds = self:ScheduleTimer(adds, 7, (diff > 2) and 45 or 60)
end

function mod:DnD(player, spellId)
	self:Bar(71001, L["dnd_bar"], 28, spellId)
	if UnitIsUnit(player, "player") then
		self:Voice(71001, true)
		self:LocalMessage(71001, L["dnd_message"], "Personal", spellId, "Alarm")
		self:FlashShake(71001)
	end
end

function mod:Barrier(_, spellId)
	if self:GetInstanceDifficulty() < 3 then
		self:CancelTimer(handle_Adds, true)
		self:SendMessage("BigWigs_StopBar", self, L["adds_bar"])
		self:CancelDelayedMessage(L["adds_warning"])
	end
	self:Voice("phase2")
	self:Message(70842, L["phase2_message"], "Positive", spellId, "Info")
	self:Bar(71426, L["spirit_bar"], 30, 71426)
end

do
	local scheduled = nil
	local function dmWarn(spellName)
		mod:TargetMessage(71289, spellName, dmTargets, "Important", 71289, "Alert")
		scheduled = nil
	end
	function mod:DominateMind(player, spellId, _, _, spellName)
		dmTargets[#dmTargets + 1] = player
		if not scheduled then
			scheduled = true
			self:Voice(71289, -1, 28)
			self:Voice(71289, 0, 35)
			self:Bar(71289, L["dominate_bar"], random(40, 45), spellId)
			self:ScheduleTimer(dmWarn, 0.3, spellName)
		end
	end
end

function mod:Touch(player, spellId, _, _, _, stack)
	if stack and stack > 1 then
		self:TargetMessage(71204, L["touch_message"], player, "Urgent", spellId, nil, stack)
	end
	self:Bar(71204, L["touch_bar"], 7, spellId)
end

function mod:Deformed()
	self:Voice(70900)
	self:Message("adds", L["deformed_fanatic"], "Urgent", 70900)
end

do
	local t = 0
	function mod:Spirit(_, spellId)
		local seconds = GetTime()
		if (seconds - t) > 5 then
			t = seconds
			self:Message(71426, L["spirit_message"], "Attention", spellId)
			self:Voice(71426)
			self:Bar(71426, L["spirit_bar"], 13, spellId)
		end
	end
end