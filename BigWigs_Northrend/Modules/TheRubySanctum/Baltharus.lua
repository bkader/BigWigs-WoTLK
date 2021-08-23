--------------------------------------------------------------------------------
-- Baltharus the Warborn
--

local mod = BigWigs:NewBoss("Baltharus the Warborn", "The Ruby Sanctum")
if not mod then return end

mod.otherMenu = "Northrend"
mod:RegisterEnableMob(39751)
mod.toggleOptions = {40504, 74505, 75125, "bosskill"}

local engage_trigger = "Ah, the entertainment has arrived."

local L = mod:NewLocale("enUS", true)
if L then
	L.engage_trigger = engage_trigger
end

L = mod:NewLocale("frFR")
if L then
	L.engage_trigger = "Ah, mon petit divertissement est arrivé."
end

L = mod:GetLocale()

local cleave = GetSpellInfo(40504)
local brand = GetSpellInfo(74505)
local tempest = GetSpellInfo(75125)

local brandTargets = mod:NewTargetList()

function mod:OnBossEnable()
	self:Log("SPELL_CAST_START", "Tempest", 75125)
	self:Log("SPELL_AURA_APPLIED", "Brand", 74505)
	self:Yell("Engage", L.engage_trigger, engage_trigger)
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "CheckForWipe")
end

function mod:OnEngage()
	self:Bar(40504, cleave, 12, 40504)
	self:Bar(74505, brand, 12, 74505)
	self:Bar(75125, tempest, 17, 75125)
end

do
	local scheduled
	local function brandWarn(spellName)
		mod:TargetMessage(74505, spellName, brandTargets, "Personal", 74505)
		scheduled = nil
	end

	function mod:Brand(player, spellId)
		brandTargets[#brandTargets+1] = player
		if not scheduled then
			scheduled = true
			self:ScheduleTimer(brandWarn, 0.3, brand)
			self:Bar(74505, brand, 26, spellId)
		end
	end
end

function mod:Tempest(_, spellId)
	self:Message(75125, tempest, "Important", spellId)
	self:Voice(75125)
	self:Bar(75125, tempest, 4, spellId)
end