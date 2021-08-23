--------------------------------------------------------------------------------
-- Saviana Ragefire
--

local mod = BigWigs:NewBoss("Saviana Ragefire", "The Ruby Sanctum")
if not mod then return end

mod.otherMenu = "Northrend"
mod:RegisterEnableMob(39747)
mod.toggleOptions = {"airphase", 78722, 74403, 74453, "bosskill"}

local engage_trigger = "You will sssuffer for this intrusion!"
local airphase_trigger = "Burn in the master's flame!"

local L = mod:NewLocale("enUS", true)
if L then
	L.engage_trigger = engage_trigger

	L.airphase = "Air phase"
	L.airphase_desc = "Warn when Saviana Ragefire will lift off."
	L.airphase_trigger = airphase_trigger
	L.airphase_bar = "Next Air Phase"
end
L = mod:GetLocale()

local beaconTargets = mod:NewTargetList()

local breath = GetSpellInfo(74403)
local enrage = GetSpellInfo(78722)
local beacon = GetSpellInfo(74453)

function mod:OnBossEnable()
	self:Log("SPELL_CAST_START", "Breath", 74403, 74404)
	self:Log("SPELL_AURA_APPLIED", "Enrage", 78722)
	self:Log("SPELL_AURA_APPLIED", "FireBeacon", 74453)
	self:Log("SPELL_AURA_REMOVED", "SafeBeacon", 74453)

	self:RegisterEvent("PLAYER_REGEN_ENABLED", "CheckForWipe")
	self:Yell("Engage", L.engage_trigger, engage_trigger)
	self:Yell("AirPhase", L.airphase_trigger, airphase_trigger)
end

function mod:OnEngage()
	self:Bar(74403, breath, 12, 74403)
	self:Bar(78722, enrage, 15, 78722)
	self:Bar("airphase", L.airphase_bar, 30, 23684)
end

function mod:Breath(_, spellId)
	self:Bar(74403, breath, random(22, 28), spellId)
end

function mod:Enrage(_, spellId)
	self:Bar(78722, enrage, 20, spellId)
end

do
	local scheduled, current = nil, 0
	local function baconWarn(spellName)
		mod:TargetMessage(74453, spellName, beaconTargets, "Urgent", 74453)
		mod:Bar(74453, spellName, 5, 74453)
		scheduled = nil
	end

	function mod:FireBeacon(player, spellId, _, _, spellName)
		beaconTargets[#beaconTargets + 1] = player
		-- mark the player:
		current = current + 1
		SetRaidTarget(player, current)

		local max, diff = 3, GetInstanceDifficulty()
		if (diff == 4 or diff == 2) then
			max = 6
		end

		if UnitIsUnit(player, "player") then
			self:FlashShake(74453)
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
		current = current - 1
		if current < 0 then
			current = 0
		end
	end
end

function mod:AirPhase()
	self:Bar(78722, enrage, 12, 78722)
	self:Bar(74403, breath, 16, 74403)
	self:Bar("airphase", L.airphase_bar, 60, 23684)
end