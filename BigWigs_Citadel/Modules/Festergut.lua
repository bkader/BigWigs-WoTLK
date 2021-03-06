-----------------------------------------------------------
-- Festergut
--

local mod = BigWigs:NewBoss("Festergut", "Icecrown Citadel")
if not mod then return end

mod:RegisterEnableMob(36626)
mod.toggleOptions = {{69279, "FLASHSHAKE"}, 69165, 71219, 72551, 71218, 72295, "proximity", "berserk", "bosskill"}
mod.optionHeaders = {
	[69279] = "normal",
	[72295] = "heroic",
	proximity = "general"
}

local sporeTargets = mod:NewTargetList()
local count = 0
local engage_trigger = "Fun time?"

local L = mod:NewLocale("enUS", true)
if L then
	L.engage_trigger = engage_trigger

	L.inhale_message = "Inhale Blight %d"
	L.inhale_bar = "Inhale %d"

	L.blight_warning = "Pungent Blight in ~5sec!"
	L.blight_bar = "Next Blight"
	L.vile_bar = "Next Vile Gas"

	L.bloat_message = "%2$dx Gastric Bloat on %1$s"
	L.bloat_bar = "~Gastric Bloat"

	L.spore_bar = "~Gas Spores"

	L.ball_message = "Goo ball incoming!"
end
L = mod:GetLocale()

function mod:OnBossEnable()
	self:Log("SPELL_CAST_START", "InhaleCD", 69165)
	self:Log("SPELL_CAST_START", "Blight", 69195, 71219, 73031, 73032)
	self:Log("SPELL_CAST_SUCCESS", "VileGas", 69240, 71218, 73020, 73019)
	self:Log("SPELL_AURA_APPLIED_DOSE", "Bloat", 72219, 72551, 72552, 72553)
	self:Death("Win", 36626)

	self:AddSyncListener("GooBall")
	self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "CheckForWipe")
	self:Yell("Engage", L["engage_trigger"], engage_trigger)

	self:Log("SPELL_AURA_APPLIED", "Spores", 69279)
end

function mod:OnEngage()
	count = 1
	self:Berserk(300, true)
	self:Bar(69165, L["inhale_bar"]:format(count), random(25, 30), 69165)
	self:Bar(69279, L["spore_bar"], random(20, 25), 69279)
	self:Bar(72551, L["bloat_bar"], random(12.5, 15), 72551)
	self:OpenProximity(9)
end

do
	local scheduled = nil
	local function sporeWarn(spellName)
		mod:TargetMessage(69279, spellName, sporeTargets, "Urgent", 69279, "Alert")
		scheduled = nil
		if mod:IsRanged() or mod:IsHealer() then
			mod:Bar(73019, L["vile_bar"], 20, 73019)
		end
	end
	local function sporeNext()
		mod:Voice(69279, nil, 20)
		mod:Bar(69279, L["spore_bar"], 28, 69279)
	end
	function mod:Spores(player, spellId, _, _, spellName)
		sporeTargets[#sporeTargets + 1] = player
		if UnitIsUnit(player, "player") then
			self:Voice(69279, true)
			self:FlashShake(69279)
		end
		if not scheduled then
			scheduled = true
			self:ScheduleTimer(sporeWarn, 0.2, spellName)
			self:ScheduleTimer(sporeNext, 12)
			local explodeName = GetSpellInfo(67729) --"Explode"
			self:Bar(69279, explodeName, 12, spellId)
		end
	end
end

function mod:InhaleCD(_, spellId, _, _, spellName)
	self:Message(69165, L["inhale_message"]:format(count), "Attention", spellId)
	count = count + 1
	if count == 4 then
		self:DelayedMessage(71219, 28.5, L["blight_warning"], "Attention")
		self:Bar(71219, L["blight_bar"], 33.5, 71219)
	else
		self:Bar(69165, L["inhale_bar"]:format(count), 33.5, spellId)
	end
end

function mod:Blight(_, spellId, _, _, spellName)
	count = 1
	self:Voice("defensives")
	self:Message(71219, spellName, "Attention", spellId)
	self:Bar(69165, L["inhale_bar"]:format(count), random(33.5, 35), 69165)
end

function mod:Bloat(player, spellId, _, _, _, stack)
	if stack > 2 then
		self:TargetMessage(72551, L["bloat_message"], player, "Positive", spellId, nil, stack)
		self:Bar(72551, L["bloat_bar"], 15, spellId)
	end
end

do
	local t = 0
	function mod:VileGas(player, spellId, _, _, spellName)
		local time = GetTime()
		if (time - t) > 2 then
			t = time
			self:Message(71218, spellName, "Important", spellId)
		end
		if UnitIsUnit(player, "player") then
			self:Voice(72272, true)
		end
		if self:IsRanged() or self:IsHealer() then
			self:Bar(73019, L["vile_bar"], 28, spellId)
		end
	end
end

do
	local goo = GetSpellInfo(72310)
	function mod:UNIT_SPELLCAST_SUCCEEDED(unit, spell)
		if spell == goo then
			self:Sync("GooBall")
		end
	end
end

function mod:OnSync(sync, rest, nick)
	if sync == "GooBall" then
		self:Voice(72295)
		self:Message(72295, L["ball_message"], "Important", 72295)
	end
end