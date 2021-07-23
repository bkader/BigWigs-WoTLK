-----------------------------------------------------------
-- Deathbringer Saurfang
--

local mod = BigWigs:NewBoss("Deathbringer Saurfang", "Icecrown Citadel")
if not mod then return end

-- Deathbringer Saurfang, Muradin, Marine, Overlord Saurfang, Kor'kron Reaver
mod:RegisterEnableMob(37813, 37200, 37830, 37187, 37920)
mod.toggleOptions = {
	"adds",
	72410,
	72385,
	72380,
	{72293, "WHISPER", "ICON", "FLASHSHAKE"},
	72737,
	"proximity",
	"berserk",
	"bosskill"
}

local bbTargets = mod:NewTargetList()
local killed = nil
local count = 1

local L = mod:NewLocale("enUS", true)
if L then
	L.adds = "Blood Beasts"
	L.adds_desc = "Shows a timer and messages for when Blood Beasts spawn."
	L.adds_warning = "Blood Beasts in 5 sec!"
	L.adds_message = "Blood Beasts!"

	L.adds_bar = "Next Blood Beasts"
	L.blood_bar = "Next Boiling Blood"
	L.nova_bar = "~Next Blood Nova"
	L.rune_bar = "~Next Rune of Blood"

	L.mark = "Mark %d"

	L.engage_trigger = "BY THE MIGHT OF THE LICH KING!"
	L.warmup_alliance = "For every Horde soldier that you killed -- for every Alliance dog that fell, the Lich King's armies grew. Even now the val'kyr work to raise your fallen as Scourge."
	L.warmup_horde = "Kor'kron, move out! Champions, watch your backs. The Scourge have been..."
end
L = mod:GetLocale()

function mod:OnBossEnable()
	self:Log("SPELL_CAST_SUCCESS", "Adds", 72173) --10man Id's: 72172, 72173; 25man Id's: 72172, 72173, 72356, 72357, 72358
	self:Log("SPELL_AURA_APPLIED", "BoilingBlood", 72385, 72442, 72441, 72443) --10/25
	self:Log("SPELL_AURA_APPLIED", "BloodNova", 72378, 72380, 72438, 72439, 73058) --10/25
	self:Log("SPELL_AURA_APPLIED", "Mark", 72293)
	self:Log("SPELL_AURA_APPLIED", "RuneofBlood", 72410)
	self:Log("SPELL_AURA_APPLIED", "Frenzy", 72737)
	self:Death("Deaths", 37813)

	self:RegisterEvent("PLAYER_REGEN_ENABLED", "CheckForWipe")
	self:Yell("Engage", L["engage_trigger"])
	self:Yell("Warmup", L["warmup_alliance"], L["warmup_horde"])
end

function mod:OnEngage(diff)
	self:OpenProximity(11)
	self:Berserk((diff > 2) and 360 or 480)
	self:DelayedMessage("adds", 25, L["adds_warning"], "Urgent")

	self:Bar(72385, L["blood_bar"], 15.5, 72385)
	self:Bar(73058, L["nova_bar"], 17, 72385)
	self:Bar(72410, L["rune_bar"], 20, 72410)
	self:Bar("adds", L["adds_bar"], 30, 72173)

	count = 1
end

function mod:Warmup(msg)
	self:OpenProximity(11)
	if msg == L["warmup_alliance"] then
		self:Bar("adds", self.displayName, 49, "achievement_boss_saurfang")
	else
		self:Bar("adds", self.displayName, 99, "achievement_boss_saurfang")
	end
end

function mod:VerifyEnable()
	SetMapToCurrentZone()
	if not killed and GetCurrentMapDungeonLevel() == 3 then
		return true
	end
end

do
	local scheduled = nil
	local function boilingWarn(spellName)
		mod:TargetMessage(72385, spellName, bbTargets, "Urgent", 72385)
		scheduled = nil
	end
	function mod:BoilingBlood(player, spellId, _, _, spellName)
		bbTargets[#bbTargets + 1] = player
		if not scheduled then
			scheduled = true
			self:ScheduleTimer(boilingWarn, 0.3, spellName)
		end
		self:Bar(72385, L["blood_bar"], 16, spellId)
	end
end

function mod:BloodNova(player, spellId)
	self:Bar(73058, L["nova_bar"], random(20, 25), spellId)
end

function mod:Adds(_, spellId)
	self:Message("adds", L["adds_message"], "Positive", spellId, "Alarm")
	self:DelayedMessage("adds", 35, L["adds_warning"], "Urgent")
	self:Voice("adds", -1, 30)
	self:Bar("adds", L["adds_bar"], 40, spellId)
end

function mod:RuneofBlood(player, spellId, _, _, spellName)
	self:TargetMessage(72410, spellName, player, "Attention", spellId)
	if UnitIsUnit(player, "player") then
		self:Voice(72410, true)
	end
	self:Bar(72410, L["rune_bar"], 20, spellId)
end

function mod:Mark(player, spellId, _, _, spellName)
	self:TargetMessage(72293, L["mark"]:format(count), player, "Attention", spellId, "Alert")
	count = count + 1
	self:Whisper(72293, player, spellName)
	self:PrimaryIcon(72293, player)
	if UnitIsUnit(player, "player") then
		self:Voice(72293, true)
		self:FlashShake(72293)
	else
		self:Voice(72293)
	end
end

function mod:Frenzy(_, spellId, _, _, spellName)
	self:Message(72737, spellName, "Important", spellId, "Long")
end

function mod:Deaths()
	killed = true
	self:Win()
end