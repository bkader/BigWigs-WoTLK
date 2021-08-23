-----------------------------------------------------------
-- Lord Marrowgar
--

local mod = BigWigs:NewBoss("Lord Marrowgar", "Icecrown Citadel")
if not mod then return end

mod:RegisterEnableMob(36612)
mod.toggleOptions = {69076, 69057, 69055, {69138, "FLASHSHAKE"}, "bosskill"}

local impaleTargets = mod:NewTargetList()
local engage_trigger = "The Scourge will wash over this world as a swarm of death and destruction!"

local L = mod:NewLocale("enUS", true)
if L then
	L.impale_cd = "~Next Impale"
	L.slice_cd = "~Next Cleave"
	L.bonestorm_cd = "~Next Bone Storm"
	L.bonestorm_warning = "Bone Storm in 5 sec!"
	L.coldflame_message = "Coldflame on YOU!"
	L.engage_trigger = engage_trigger
end
L = mod:GetLocale()

function mod:OnBossEnable()
	self:Log("SPELL_SUMMON", "Impale", 69062, 72669, 72670)
	self:Log("SPELL_CAST_START", "BonestormCast", 69076)
	self:Log("SPELL_AURA_APPLIED", "Bonestorm", 69076)
	self:Log("SPELL_AURA_APPLIED", "Coldflame", 70823, 69146, 70824, 70825)
	self:Death("Win", 36612)

	self:RegisterEvent("PLAYER_REGEN_ENABLED", "CheckForWipe")
	self:Yell("Engage", L["engage_trigger"], engage_trigger)
end

function mod:OnEngage()
	local rn = random(45, 50)
	self:Voice(69076, -1, rn - 10)
	self:Bar(69076, L["bonestorm_cd"], rn, 69076)
	self:Bar(69057, L["impale_cd"], 15, 69057)
	self:DelayedMessage(69076, 43, L["bonestorm_warning"], "Attention")
end

do
	local scheduled = nil
	local achievName = select(2, GetAchievementInfo(4534))
	achievName = (achievName):gsub("%(.*%)", "")
	local function impaleWarn(spellName)
		mod:TargetMessage(69057, spellName, impaleTargets, "Urgent", 69062, "Alert")
		scheduled = nil
	end
	function mod:Impale(_, spellId, player, _, spellName)
		impaleTargets[#impaleTargets + 1] = player
		if not scheduled then
			scheduled = true
			self:ScheduleTimer(impaleWarn, 0.3, spellName)
			self:Bar(69057, achievName, 8, "achievement_boss_lordmarrowgar")
			self:Voice(69057, -1, 8)
			self:Bar(69057, L["impale_cd"], random(15, 20), 69057)
		end
	end
end

function mod:Coldflame(player, spellId)
	if UnitIsUnit(player, "player") then
		self:Voice(69138, true)
		self:LocalMessage(69138, L["coldflame_message"], "Personal", spellId, "Alarm")
		self:FlashShake(69138)
	end
end

local function afterTheStorm()
	if mod:IsHeroic() then
		mod:Voice(69076, -1, 70)
		mod:Bar(69076, L["bonestorm_cd"], 80, 69076)
		mod:DelayedMessage(69076, 75, L["bonestorm_warning"], "Attention")
	else
		mod:Voice(69076, -1, 60)
		mod:Bar(69076, L["bonestorm_cd"], 70, 69076)
		mod:DelayedMessage(69076, 65, L["bonestorm_warning"], "Attention")
		mod:Voice(69057, -1, 8)
		mod:Bar(69057, L["impale_cd"], 15, 69057)
	end
	mod:Voice(69055, 0, 5)
	mod:Bar(69055, L["slice_cd"], 10, 69055)
end

function mod:Bonestorm(_, spellId, _, _, spellName)
	local seconds = 20
	if self:IsHeroic() then
		seconds = 30
	else
		self:SendMessage("BigWigs_StopBar", self, L["impale_cd"])
	end
	self:Bar(69076, spellName, seconds, spellId)
	self:ScheduleTimer(afterTheStorm, seconds)
end

function mod:BonestormCast(_, spellId, _, _, spellName)
	self:Voice(69076)
	self:Message(69076, spellName, "Attention", spellId)
end