--------------------------------------------------------------------------------
-- Halion
--

local mod = BigWigs:NewBoss("Halion", "The Ruby Sanctum")
if not mod then return end

mod.otherMenu = "Northrend"
mod:RegisterEnableMob(39863, 40142)
mod.toggleOptions = {
	{74562, "SAY", "ICON", "FLASHSHAKE", "WHISPER"},
	75879,
	{74792, "SAY", "ICON", "FLASHSHAKE", "WHISPER"},
	74769,
	75954,
	74525,
	"berserk",
	"bosskill"
}

--------------------------------------------------------------------------------
-- Locals
--

local phase = 1

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
	L.engage_trigger =
		"Your world teeters on the brink of annihilation. You will ALL bear witness to the coming of a new age of DESTRUCTION!"

	L.phase_two_trigger = "You will find only suffering within the realm of twilight! Enter if you dare!"
	L.twilight_cutter_trigger = "The orbiting spheres pulse with dark energy!"
	L.twilight_cutter_warning = "Laser beams incoming!"
	L.phase_warning = "Phase %d soon!"

	L.fire_damage_message = "Your feet are burning!"
	L.fire_message = "Fire bomb"
	L.fire_say = "Fire bomb on ME!"
	L.shadow_message = "Shadow bomb"
	L.shadow_say = "Shadow bomb on ME!"

	L.meteorstrike_yell = "The heavens burn!"
	L.meteor_warning_message = "Meteor incoming!"
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

local fire_bar = GetSpellInfo(74562)
local shadow_bar = GetSpellInfo(74792)
local meteorstrike_bar = GetSpellInfo(75879)

local firebreath_bar = GetSpellInfo(74525)
local shadowbreath_bar = GetSpellInfo(74806)
local twilight_cutter_bar = GetSpellInfo(74769)

function mod:OnBossEnable()
	self:Log("SPELL_AURA_APPLIED", "Fire", 74562)
	self:Log("SPELL_AURA_APPLIED", "Shadow", 74792)
	self:Log("SPELL_CAST_SUCCESS", "MeteorStrike", 75879, 74648, 75877)
	self:Log("SPELL_DAMAGE", "FireDamage", 75947, 75948, 75949, 75950, 75951, 75952)
	-- Dark breath 25m, flame breath 25m, dark breath 10m, flame breath 10m
	self:Log("SPELL_CAST_START", "ShadowBreath", 74806, 75954, 75955, 75956)
	self:Log("SPELL_CAST_START", "FireBreath", 74525, 74526, 74527, 74528)
	self:Death("Win", 39863, 40142)

	self:Emote("TwilightCutter", L["twilight_cutter_trigger"])
	self:Yell("Engage", L["engage_trigger"])
	self:Yell("PhaseTwo", L["phase_two_trigger"])
	self:Yell("MeteorInc", L["meteorstrike_yell"])

	-- self:RegisterEvent("UNIT_HEALTH")

	self:RegisterEvent("PLAYER_REGEN_ENABLED", "CheckForWipe")
end

function mod:OnEngage(diff)
	phase = 1
	self:Berserk(480)
	self:Bar(74525, firebreath_bar, 10, 74525)
	self:Bar(74562, fire_bar, 15, 74562)
	self:Bar(75879, meteorstrike_bar, 30, 75879)
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:UNIT_HEALTH(_, unit)
	if UnitName(unit) == self.displayName then
		local hp = math.floor(UnitHealth(unit) / UnitHealthMax(unit) * 100)
		if hp <= 78 and phase < 2 then
			self:Voice("phase2s")
			phase = 2
		elseif hp <= 53 and phase < 3 then
			self:Voice("phase3s")
			phase = 3
		elseif hp <= 50 then
			self:UnregisterEvent("UNIT_HEALTH")
		end
	end
end

function mod:FireDamage(player, spellId)
	if UnitIsUnit(player, "player") then
		self:LocalMessage(75879, L["fire_damage_message"], "Personal", spellId)
	end
end

function mod:Fire(player, spellId)
	if self:GetInstanceDifficulty() > 2 then
		self:Bar(74562, fire_bar, 20, spellId)
	else
		self:Bar(74562, fire_bar, 25, spellId)
	end
	if UnitIsUnit(player, "player") then
		self:Voice(74562, true)
		self:Say(74562, L["fire_say"])
		self:FlashShake(74562)
	end
	self:TargetMessage(74562, L["fire_message"], player, "Personal", spellId, "Info")
	self:Whisper(74562, player, L["fire_message"])
	self:PrimaryIcon(74562, player)
end

function mod:Shadow(player, spellId)
	if self:GetInstanceDifficulty() > 2 then
		self:Bar(74792, shadow_bar, 20, spellId)
	else
		self:Bar(74792, shadow_bar, 25, spellId)
	end
	if UnitIsUnit(player, "player") then
		self:Voice(74792, true)
		self:Say(74792, L["shadow_say"])
		self:FlashShake(74792)
	end
	self:TargetMessage(74792, L["shadow_message"], player, "Personal", spellId, "Info")
	self:Whisper(74792, player, L["shadow_message"])
	self:SecondaryIcon(74792, player)
end

function mod:ShadowBreath(_, spellId)
	self:Bar(75954, shadowbreath_bar, 21, spellId)
end

function mod:FireBreath(_, spellId)
	self:Bar(74525, firebreath_bar, 21, spellId)
end

function mod:TwilightCutter()
	self:Voice(74769)
	self:Voice(74769, -1, 25)
	self:Bar(74769, twilight_cutter_bar, 33, 74769)
	self:Message(74769, L["twilight_cutter_warning"], "Important", 74769, "Alert")
end

function mod:MeteorInc()
	self:Voice(75879)
	self:Message(75879, L["meteor_warning_message"], "Urgent", 75879, "Long")
end

function mod:MeteorStrike(_, spellId, _, _, spellName)
	self:Bar(75879, meteorstrike_bar, 38, spellId)
	self:Message(75879, spellName, "Important", spellId)
end

function mod:PhaseTwo()
	phase = 2
	self:Voice("phase2")
	self:Bar(74769, twilight_cutter_bar, 40, 74769)
end